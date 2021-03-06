#pragma once
#include <vector>
#include <geom.hpp>
#include <accel-struct.hpp>
#include <bvh.hpp>

namespace gpumagi {

enum ShaderStage {
  L_SHADER_STAGE_RAY_GENERATION,
  L_SHADER_STAGE_CLOSEST_HIT,
  L_SHADER_STAGE_MISS,
};
typedef void (*Shader)();

struct Pipeline {
  std::vector<Shader> shaders;
  u32 rg_offset;
  u32 ch_offset;
  u32 ms_offset;
};
Pipeline make_pipe(Shader rg, const std::vector<Shader>& chs, const std::vector<Shader>& mss) {
  std::vector<Shader> shaders;
  u32 rg_offset = shaders.size();
  shaders.push_back(rg);
  u32 ch_offset = shaders.size();
  for (auto ch : chs) { shaders.push_back(ch); }
  u32 ms_offset = shaders.size();
  for (auto ms : mss) { shaders.push_back(ms); }

  return Pipeline { std::move(shaders), rg_offset, ch_offset, ms_offset };
}

struct ShaderBindingTable {
  std::vector<const void*> datas;
  u32 rg_offset;
  u32 ch_offset;
  u32 ms_offset;
};
ShaderBindingTable make_sbt(const Pipeline& pipe) {
  return ShaderBindingTable {
    std::vector<const void*>(pipe.shaders.size()),
    pipe.rg_offset,
    pipe.ch_offset,
    pipe.ms_offset,
  };
}
void bind_sbt(ShaderBindingTable& sbt, ShaderStage stage, u32 i, const void* data) {
  u32 offset;
  switch(stage) {
  case L_SHADER_STAGE_RAY_GENERATION:
    sbt.datas[sbt.rg_offset + i] = data;
  case L_SHADER_STAGE_CLOSEST_HIT:
    sbt.datas[sbt.ch_offset + i] = data;
  case L_SHADER_STAGE_MISS:
    sbt.datas[sbt.ms_offset + i] = data;
  }
}



struct TraversalPassContext {
  // Set during draw calls.
  const Pipeline* pipe;
  const ShaderBindingTable* sbt;
  Dim launch_size;
};
struct TraversalThreadContext {
  // Set by scheduler during thread launch.
  Dim launch_id;
  ShaderStage stage; // Current execution stage.
};
struct TraversalTraceContext {
  // Set by shader during trace calls.
  const Traversable* trav;
  Ray ray;
  void* payload;

  // Set by the ray-tracing accelerator during trace calls.
  TriangleHit hit;
  u32 itri;
  u32 ich_data;
  u32 ims_data;
};

//
// Execution contexts. (Currently global variables.)
extern              TraversalPassContext   pass_ctxt;
extern thread_local TraversalThreadContext thread_ctxt;
extern thread_local TraversalTraceContext  trace_ctxt; // Only used during trace calls.



//
// Device-side procedures.

// Trace a ray in `trav`.
void trace(const Traversable* trav, const Ray& ray, f32 tmin, f32 tmax, u32 ich, u32 ims, void* payload) {
  auto cur_stage = thread_ctxt.stage;
  trace_ctxt.trav = trav;
  trace_ctxt.ray = ray;
  trace_ctxt.payload = payload;
  trace_ctxt.ray = ray;
  for (size_t i = 0; i < trav->bvh.vols.size(); ++i) {
    const Volumn& vol = trav->bvh.vols[i];
    AabbHit aabb_hit;
    if (ray_cast_aabb(ray, vol.aabb, aabb_hit)) {
      // Hit a AABB. Check the primitives inside.
      TriangleHit hit;
      for (size_t j = 0; j < vol.tris.size(); ++j) {
        if (ray_cast_tri(ray, vol.tris[j], hit) && tmin <= hit.t && hit.t < tmax) {
          trace_ctxt.hit = hit;
          trace_ctxt.itri = i;
          // Successful hit an triangle within t-range.
          thread_ctxt.stage = L_SHADER_STAGE_CLOSEST_HIT;
          pass_ctxt.pipe->shaders[pass_ctxt.pipe->ch_offset + ich]();
          thread_ctxt.stage = cur_stage;
          return;
        }
      }
    }
  }
  // Failed to hit any triangle.
  thread_ctxt.stage = L_SHADER_STAGE_MISS;
  pass_ctxt.pipe->shaders[pass_ctxt.pipe->ms_offset + ims]();
  thread_ctxt.stage = cur_stage;
}

const void* get_sbt_data() {
  switch (thread_ctxt.stage) {
  case L_SHADER_STAGE_RAY_GENERATION:
    return pass_ctxt.sbt->datas[pass_ctxt.pipe->rg_offset];
  case L_SHADER_STAGE_CLOSEST_HIT:
    return pass_ctxt.sbt->datas[pass_ctxt.pipe->ch_offset + trace_ctxt.ich_data];
  case L_SHADER_STAGE_MISS:
    return pass_ctxt.sbt->datas[pass_ctxt.pipe->ms_offset + trace_ctxt.ims_data];
  }
}

inline const Traversable& get_traversable() { return *trace_ctxt.trav; }
inline const Ray&         get_ray() { return trace_ctxt.ray; }
inline f32                get_ray_tmin() { return trace_ctxt.hit.t; }
inline HitKind            get_hit_kind() { return trace_ctxt.hit.kind; }
inline const Barycentric& get_bary() { return trace_ctxt.hit.bary; }
inline u32                get_itri() { return trace_ctxt.itri; }
inline void*              get_payload() { return trace_ctxt.payload; }
inline const Dim&         get_launch_size() { return pass_ctxt.launch_size; }
inline const Dim&         get_launch_id() { return thread_ctxt.launch_id; }
inline bool               is_front_face_hit() { return trace_ctxt.hit.kind == L_HIT_KIND_FRONT; }
inline bool               is_back_face_hit() { return trace_ctxt.hit.kind == L_HIT_KIND_BACK; }


struct FilmCoordinates {
  f32 x, y;
};
FilmCoordinates get_film_coord_n1p1() {
  const Dim& launch_size = get_launch_size();
  const Dim& launch_id = get_launch_id();
  auto x = ((f32)(launch_id.x) * 2 + 1 - launch_size.x) / launch_size.x;
  auto y = ((f32)(launch_id.y) * 2 + 1 - launch_size.y) / launch_size.y;
  return { x, y };
}
struct CameraCoordinates {
  Point o;
  Vector right;
  Vector up;
};
CameraCoordinates make_cam_coord(const Transform& trans) {
  auto o = trans.apply_pt(make_pt(0, 0, 0));
  auto right = trans.apply_vec(make_vec(1, 0, 0));
  auto up = trans.apply_vec(make_vec(0, 1, 0));
  return { o, right, up };
}
// Get a orthogonally projected ray for this raygen shader invocation.
Ray gen_ortho_ray(
  const Transform& trans
) {
  auto cam_coord = make_cam_coord(trans);
  // Let the rays shoot into the screen.
  Vector front = normalize(cross(cam_coord.up, cam_coord.right));
  FilmCoordinates uv = get_film_coord_n1p1();
  cam_coord.o = cam_coord.o + (uv.x * cam_coord.right + uv.y * cam_coord.up);
  return Ray { cam_coord.o, front };
}



//
// Host-side procedures.

void launch(const Pipeline& pipe, const ShaderBindingTable& sbt, Dim launch_size) {
  pass_ctxt.pipe = &pipe;
  pass_ctxt.sbt = &sbt;
  pass_ctxt.launch_size = launch_size;
  thread_ctxt.stage = L_SHADER_STAGE_RAY_GENERATION;
  for (auto k = 0; k < launch_size.z; ++k) {
    thread_ctxt.launch_id.z = k;
    for (auto j = 0; j < launch_size.y; ++j) {
      thread_ctxt.launch_id.y = j;
      for (auto i = 0; i < launch_size.x; ++i) {
        thread_ctxt.launch_id.x = i;
        pipe.shaders[pipe.rg_offset]();
      }
    }
  }
}

} // namespace gpumagi
