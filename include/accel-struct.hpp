#pragma once
#include <cstdint>
#include <vector>
#include <geom.hpp>
#include <bvh.hpp>

namespace gpumagi {

enum TraversablePreference {
  L_TRAVERSABLE_PREFERENCE_DEFAULT = 0,
  L_TRAVERSABLE_PREFERENCE_FAST_BUILD = 1,
  L_TRAVERSABLE_PREFERENCE_FAST_TRAVERSAL = 2,
};
struct Traversable {
  Bvh bvh;
};

Traversable create_trav(const TraversablePreference& pref) {
  u32 vol_ndiv = (pref & L_TRAVERSABLE_PREFERENCE_FAST_TRAVERSAL) ? 16 : 4;
  Dim vol_size { vol_ndiv, vol_ndiv, vol_ndiv };
  Bvh bvh = create_bvh(vol_size);
  return Traversable { bvh };
}

void build_trav(
  Traversable& trav,
  const std::vector<Triangle>& tris
) {
  build_bvh(trav.bvh, tris);
}

} // namespace gpumagi
