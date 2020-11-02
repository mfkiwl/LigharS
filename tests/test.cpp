#include "geom.hpp"
#include <vector>
#include <iostream>

using namespace gpumagi;

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

  std::vector<uint8_t> framebuf;
  framebuf.resize(64 * 64);

  Intersection inters;

  for (auto i = 0; i < 64; ++i) {
    for (auto j = 0; j < 64; ++j) {
      auto ray = make_ray(
        make_pt(float(i) / 64, float(j) / 64, 1),
        make_vec(0, 0, -1)
      );
      if (traverse(ray, tris, inters)) {
        framebuf[i * 64 + j] = 1;
        std::cout << 1;
      } else {
        std::cout << 0;
      }
    }
    std::cout << std::endl;
  }

  return 0;
}
