#include <vector>
#include <iostream>
#include "geom.hpp"
#include "rt.hpp"
#include "impl-ctxts.hpp"

using namespace gpumagi;


const int FRAMEBUF_EDGE = 4;



struct RGData {
  const Traversable* trav;
  std::vector<uint8_t>* framebuf;
};
struct Result {
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
  Traversable trav = make_trav(tris);

  const int FRAMEBUF_EDGE = 4;
  std::vector<uint8_t> framebuf;
  framebuf.resize(FRAMEBUF_EDGE * FRAMEBUF_EDGE);

  Pipeline pipe = make_pipe(raygen, { closest_hit }, { miss });
  ShaderBindingTable sbt = make_sbt(pipe);

  RGData rg_data {};
  rg_data.trav = &trav;
  rg_data.framebuf = &framebuf;
  bind_sbt(sbt, L_SHADER_STAGE_RAY_GENERATION, 0, &rg_data);

  launch(pipe, sbt, { FRAMEBUF_EDGE, FRAMEBUF_EDGE, 1 });

  for (auto j = 0; j < FRAMEBUF_EDGE; ++j) {
    for (auto i = 0; i < FRAMEBUF_EDGE; ++i) {
      std::cout << (int)framebuf[i + j * FRAMEBUF_EDGE] << " ";
    }
    std::cout << std::endl;
  }

  return 0;
}
