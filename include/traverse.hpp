#include "geom.hpp"

struct Intersection {
  Barycentric bary;
  HitKind kind;
  Point p;
  f32 t;
  u32 itri;
};

bool traverse(const Ray& ray, const std::vector<Triangle>& tris, Intersection& inters) {
  for (size_t i = 0; i < tris.size(); ++i) {
    const auto& tri = tris[i];
    f32 t = ray_cast_tri(ray, tri);
    if (std::isnan(t)) { continue; }

    HitKind kind = t < 0 ? L_HIT_KIND_BACK : L_HIT_KIND_FRONT;
    t = abs(t);
    Point p = ray.o + ray.v * t;
    Barycentric bary = make_bary(p, tri);
    if (bary.u < 0 || bary.v < 0 || bary.u + bary.v > 1) { continue; }

    inters.bary = bary;
    inters.kind = kind;
    inters.p = p;
    inters.t = t;
    inters.itri = i;
    return true;
  }
  return false;
}