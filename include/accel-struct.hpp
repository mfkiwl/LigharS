#include <cstdint>
#include "geom.hpp"

namespace gpumagi {

using u32 = unsigned;
using f32 = float;

struct BlasBuildConfig {
  u32 ntri;
  const u32* idxs;
  u32 nvert;
  const f32* verts;
};
struct BlasMemoryRequirement {
  u32 scratch_size;
  u32 blas_size;
  u32 compacted_size;
};

struct PlainBlas {
  Triangle* tris;
};
BlasMemoryRequirement get_plain_blas_mem_req(const BlasBuildConfig& build_cfg) {
  return BlasMemoryRequirement {
    0,
    build_cfg.ntri * sizeof(Triangle),
    build_cfg.ntri * sizeof(Triangle),
  };
}
PlainBlas build_plain_blas(const BlasBuildConfig* tris, Triangle* blas_mem) {
  throw 0;
}

} // namespace gpumagi
