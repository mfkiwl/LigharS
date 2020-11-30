#include <vector>
#include <iostream>
#include <geom.hpp>
#include <rt.hpp>
#include <io.hpp>
#include <impl-ctxts.hpp>

using namespace gpumagi;


const int FRAMEBUF_EDGE = 4;



struct Color {
  f32 r, g, b, a;
};
inline Color make_color(f32 r, f32 g, f32 b, f32 a) {
  return Color { r, g, b, a };
}
inline Color make_color(f32 r, f32 g, f32 b) {
  return Color { r, g, b, 1.0f };
}

inline Color operator+(const Color& a, const Color& b) {
  return { a.r + b.r, a.g + b.g, a.b + b.b, a.a + b.a };
}
inline Color operator*(const Color& a, f32 b) {
  return { a.r * b, a.g * b, a.b * b, a.a * b };
}
inline Color operator*(f32 a, const Color& b) {
  return { a * b.r, a * b.g, a * b.b, a * b.a };
}
inline Color clamp(const Color& c, f32 min, f32 max) {
  return {
    std::fmax(std::fmin(c.r, max), min),
    std::fmax(std::fmin(c.g, max), min),
    std::fmax(std::fmin(c.b, max), min),
    std::fmax(std::fmin(c.a, max), min),
  };
}







u32 pack_unorm4_rgba(Color x) {
  x = clamp(x, 0, 1);
  return ((uint32_t)(x.r * 255.999)) |
    ((uint32_t)(x.g * 255.999) << 8) |
    ((uint32_t)(x.b * 255.999) << 16) |
    ((uint32_t)(x.a * 255.999) << 24);
}
Color unquant_unorm8_rgb(u8 r, u8 g, u8 b) {
  return make_color((f32)r / 255.999, (f32)g / 255.999, (f32)b / 255.999);
}

struct RGData {
  const Traversable* trav;
  std::vector<u32>* framebuf;
};
void raygen() {
  const auto& data = *(const RGData*)get_sbt_data();

  auto trans = Transform()
    .scale(0.5, 0.5, 0.5)
    .rotate({ 0.0, 1.0, 0.0 }, deg2rad(45.0f))
    .rotate({ 1.0, 0.0, 0.0 }, deg2rad(45.0f))
    .translate(0, 0.5, -2)
    .inverse();
  Ray ray = gen_ortho_ray(trans);

  Color color;
  trace(data.trav, ray, 1e-5, 1e5, 0, 0, &color);

  const Dim& launch_size = get_launch_size();
  const Dim& launch_id = get_launch_id();
  (*data.framebuf)[launch_id.x + launch_id.y * launch_size.x] = pack_unorm4_rgba(color);
}
void closest_hit() {
  *(Color*)get_payload() = unquant_unorm8_rgb(245, 228, 0);
}
void miss() {
  *(Color*)get_payload() = unquant_unorm8_rgb(25, 25, 25);
}








Traversable l_create_cube_cfg(const Transform& world2obj) {
  const float p = 0.5;
  const float n = -0.5;
  static const Point verts[] = {
    make_pt(n, p, n),
    make_pt(n, p, p),
    make_pt(p, p, p),
    make_pt(p, p, n),
    make_pt(n, n, n),
    make_pt(n, n, p),
    make_pt(p, n, p),
    make_pt(p, n, n),
  };
  const uint32_t a = 0;
  const uint32_t b = 1;
  const uint32_t c = 2;
  const uint32_t d = 3;
  const uint32_t e = 4;
  const uint32_t f = 5;
  const uint32_t g = 6;
  const uint32_t h = 7;
  static const uint16_t idxs[] = {
    f, e, a,   f, a, b,
    g, f, b,   g, b, c,
    h, g, c,   h, c, d,
    e, h, d,   e, d, a,
    a, d, c,   a, c, b,
    e, f, g,   e, g, h
  };

  std::vector<Triangle> tris;
  for (auto i = 0; i < 36; i += 3) {
    Point v0 = verts[idxs[i + 0]];
    Point v1 = verts[idxs[i + 1]];
    Point v2 = verts[idxs[i + 2]];
    v0 = world2obj.apply_pt(v0);
    v1 = world2obj.apply_pt(v1);
    v2 = world2obj.apply_pt(v2);
    tris.push_back(make_tri(v0, v1, v2));
  }

  Traversable trav = create_trav(L_TRAVERSABLE_PREFERENCE_FAST_BUILD);
  build_trav(trav, tris);
  return trav;
}







int main(int argc, const char** argv) {
  // Test your code here for now. We will have to write a lot of tests so you
  // better keep your testing code until we establish our testing framework.

  auto trans = Transform()
    .translate(-1, 0.75, 0);
  Traversable trav = l_create_cube_cfg(trans);

  const int FRAMEBUF_EDGE = 256;
  std::vector<u32> framebuf;
  framebuf.resize(FRAMEBUF_EDGE * FRAMEBUF_EDGE);

  Pipeline pipe = make_pipe(raygen, { closest_hit }, { miss });
  ShaderBindingTable sbt = make_sbt(pipe);

  RGData rg_data {};
  rg_data.trav = &trav;
  rg_data.framebuf = &framebuf;
  bind_sbt(sbt, L_SHADER_STAGE_RAY_GENERATION, 0, &rg_data);

  launch(pipe, sbt, { FRAMEBUF_EDGE, FRAMEBUF_EDGE, 1 });

  snapshot_framebuf_bmp(framebuf, FRAMEBUF_EDGE, FRAMEBUF_EDGE, "x.bmp");

  return 0;
}
