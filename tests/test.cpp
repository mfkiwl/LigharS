#include "geom.hpp"
#include <vector>
#include <iostream>

using namespace gpumagi;

struct Traversable {
  std::vector<Triangle> tris;
};

typedef void (*Shader)();

struct Pipeline {
  Shader* shaders;
  u32 rg_offset;
  u32 ch_offset;
  u32 ms_offset;
};
struct ShaderBindingTable {
  const void** datas;
};

struct LaunchDim {
  u32 x, y, z;
};

enum ShaderStage {
  L_SHADER_STAGE_RAY_GENERATION,
  L_SHADER_STAGE_CLOSEST_HIT,
  L_SHADER_STAGE_MISS,
};



struct TraversalPassContext {
  // Set during draw calls.
  const Pipeline* pipe;
  const ShaderBindingTable* sbt;
  LaunchDim launch_size;
};
struct TraversalThreadContext {
  // Set by scheduler during thread launch.
  LaunchDim launch_id;
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
static       TraversalPassContext   pass_ctxt;
thread_local TraversalThreadContext thread_ctxt;
thread_local TraversalTraceContext  trace_ctxt; // Only used during trace calls.



//
// Device-side procedures.

// Trace a ray in `trav`.
void trace(const Traversable* trav, const Ray& ray, f32 tmin, f32 tmax, u32 ich, u32 ims, void* payload) {
  trace_ctxt.trav = trav;
  trace_ctxt.ray = ray;
  trace_ctxt.payload = payload;
  trace_ctxt.ray = ray;
  for (size_t i = 0; i < trav->tris.size(); ++i) {
    TriangleHit hit;
    if (ray_cast_tri(ray, trav->tris[i], hit) && tmin <= hit.t && hit.t < tmax) {
      trace_ctxt.hit = hit;
      trace_ctxt.itri = i;
      // Successful hit an triangle within t-range.
      thread_ctxt.stage = L_SHADER_STAGE_MISS;
      pass_ctxt.pipe->shaders[pass_ctxt.pipe->ch_offset + ich]();
      thread_ctxt.stage = L_SHADER_STAGE_RAY_GENERATION;
    }
  }
  // Failed to hit any triangle.
  thread_ctxt.stage = L_SHADER_STAGE_MISS;
  pass_ctxt.pipe->shaders[pass_ctxt.pipe->ms_offset + ims]();
  thread_ctxt.stage = L_SHADER_STAGE_RAY_GENERATION;
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

const Traversable& get_traversable()   { return *trace_ctxt.trav; }
const Ray&         get_ray()           { return trace_ctxt.ray; }
f32                get_ray_tmin()      { return trace_ctxt.hit.t; }
HitKind            get_hit_kind()      { return trace_ctxt.hit.kind; }
Barycentric        get_bary()          { return trace_ctxt.hit.bary; }
u32                get_itri()          { return trace_ctxt.itri; }
void*              get_payload()       { return trace_ctxt.payload; }
const LaunchDim&   get_launch_size()   { return pass_ctxt.launch_size; }
const LaunchDim&   get_launch_id()     { return thread_ctxt.launch_id; }
bool               is_front_face_hit() { return trace_ctxt.hit.kind == L_HIT_KIND_FRONT; }
bool               is_back_face_hit()  { return trace_ctxt.hit.kind == L_HIT_KIND_BACK; }




//
// Host-side procedures.

void launch(const Pipeline& pipe, const ShaderBindingTable& sbt, LaunchDim launch_size) {
  pass_ctxt.pipe = &pipe;
  pass_ctxt.sbt = &sbt;
  pass_ctxt.launch_size = launch_size;
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



const int FRAMEBUF_EDGE = 4;



struct RGData {
  const Traversable* trav;
  std::vector<uint8_t>* framebuf;
};
void raygen() {
  const auto& data = *(const RGData*)get_sbt_data();

  LaunchDim launch_size = get_launch_size();
  LaunchDim launch_id = get_launch_id();
  Ray ray = make_ray(
    make_pt(float(launch_id.x) / FRAMEBUF_EDGE, float(launch_id.y) / FRAMEBUF_EDGE, 1),
    make_vec(0, 0, -1)
  );

  bool hit;
  trace(data.trav, ray, 1e-3, 1e5, 0, 0, &hit);
  (*data.framebuf)[launch_id.x + launch_id.y * launch_size.x] = hit;
}
void closest_hit() {
  *(bool*)get_payload() = true;
}
void miss() {
  *(bool*)get_payload() = false;
}


int main(int argc, const char** argv) {
  // Test your code here for now. We will have to write a lot of tests so you
  // better keep your testing code until we establish our testing framework.

  std::vector<Triangle> tris = {
    make_tri(
      make_pt(0, 0, 0),
      make_pt(1, 0, 0),
      make_pt(0, 1, 0)
    ),
  };
  Traversable trav { tris };

  const int FRAMEBUF_EDGE = 4;
  std::vector<uint8_t> framebuf;
  framebuf.resize(FRAMEBUF_EDGE * FRAMEBUF_EDGE);

  Shader shaders[3] = { raygen, closest_hit, miss };
  Pipeline pipe;
  pipe.shaders = shaders;
  pipe.rg_offset = 0;
  pipe.ch_offset = 1;
  pipe.ms_offset = 2;


  RGData rg_data {};
  rg_data.trav = &trav;
  rg_data.framebuf = &framebuf;
  const void* sbt_datas[3] = { &rg_data, nullptr, nullptr };
  ShaderBindingTable sbt;
  sbt.datas = sbt_datas;

  launch(pipe, sbt, { FRAMEBUF_EDGE, FRAMEBUF_EDGE });

  for (auto j = 0; j < FRAMEBUF_EDGE; ++j) {
    for (auto i = 0; i < FRAMEBUF_EDGE; ++i) {
      std::cout << (int)framebuf[i + j * FRAMEBUF_EDGE] << " ";
    }
    std::cout << std::endl;
  }

  return 0;
}
