#pragma once
#include <algorithm>
#include <limits>
#include "geom.hpp"

namespace gpumagi {

// bounding box (AABB) and all the primitives inside or intersecting it.
struct Volumn { 
  Aabb aabb;
  std::vector<Triangle> tris;
};




struct Bvh {
  Aabb aabb;
  Dim vol_size;
  std::vector<Volumn> vols;
};

// BVH created hare has to be built before being traversed.
Bvh create_bvh(const Dim& vol_size) {
  Aabb init_aabb {
      Point {
        std::numeric_limits<f32>::max(),
        std::numeric_limits<f32>::max(),
        std::numeric_limits<f32>::max(),
      },
      Point {
        std::numeric_limits<f32>::min(),
        std::numeric_limits<f32>::min(),
        std::numeric_limits<f32>::min(),
      },
  };
  std::vector<Volumn> vols(vol_size.x * vol_size.y * vol_size.z);
  return Bvh { init_aabb, vol_size, vols };
}

void build_bvh(Bvh& bvh, const std::vector<Triangle>& tris) {
  // Inflate BVH's AABB to contain all primitives in the BVH.
  for (u32 i = 0; i < tris.size(); ++i) {
    bvh.aabb = extend(bvh.aabb, make_aabb(tris[i]));
  }

  const Dim& vol_size = bvh.vol_size;
  Vector diag = bvh.aabb.max_pt - bvh.aabb.min_pt;
  // TODO: The following three loops can be parallelized.
  for (u32 i = 0; i < vol_size.z; ++i) {
    for (u32 j = 0; j < vol_size.y; ++j) {
      for (u32 k = 0; k < vol_size.x; ++k) {
        u32 idx = vol_size.x * (vol_size.y * i + j) + k;
        Volumn& vol = bvh.vols[idx];

        Vector min_offset {
          k * diag.x / bvh.vol_size.x,
          j * diag.y / bvh.vol_size.y,
          i * diag.z / bvh.vol_size.z,
        };
        Vector max_offset {
          (k + 1) * diag.x / bvh.vol_size.x,
          (j + 1) * diag.y / bvh.vol_size.y,
          (i + 1) * diag.z / bvh.vol_size.z,
        };
        vol.aabb = Aabb {
          bvh.aabb.min_pt + min_offset,
          bvh.aabb.min_pt + max_offset,
        };

        for (int l = 0; l < tris.size(); ++l) {
          if (intersect(vol.aabb, make_aabb(tris[l]))) {
            // if the triangle's AABB intersects with volumn's AABB, put the
            // triangle in the volumn as one of its primitive.
            vol.tris.push_back(tris[l]);
          }
        }

      }
    }
  }
}



} // namespace gpumagi
