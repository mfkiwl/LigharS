#include <cmath>
#include <cassert>

namespace gpumagi {

using u32 = unsigned;
using f32 = float;

struct Point {
  f32 x, y, z;
};
inline Point make_pt(f32 x, f32 y, f32 z) {
  return Point { x, y, z };
}

struct Vector {
  f32 x, y, z;
};
inline Vector make_vec(f32 x, f32 y, f32 z) {
  return Vector { x, y, z };
}

inline Vector operator+(const Vector& a, const Vector& b) {
  return { a.x + b.x, a.y + b.y, a.z + b.z };
}
inline Vector operator-(const Vector& a, const Vector& b) {
  return { a.x - b.x, a.y - b.y, a.z - b.z };
}
inline Vector operator*(const Vector& a, f32 b) {
  return { a.x * b, a.y * b, a.z * b };
}
inline Vector operator/(const Vector& a, f32 b) {
  return { a.x / b, a.y / b, a.z / b };
}

inline Point operator+(const Point& a, const Vector& b) {
  return { a.x + b.x, a.y + b.y, a.z + b.z };
}
inline Point operator-(const Point& a, const Vector& b) {
  return { a.x - b.x, a.y - b.y, a.z - b.z };
}

inline Vector operator-(const Point& a, const Point& b) {
  return { a.x - b.x, a.y - b.y, a.z - b.z };
}

inline f32 dot(const Vector& a, const Vector& b) {
  return a.x * b.x + a.y * b.y + a.z * b.z;
}
inline Vector cross(const Vector& a, const Vector& b) {
  return Vector {
    a.y * b.z - a.z * b.y,
    a.z * b.x - a.x * b.z,
    a.x * b.y - a.y * b.x,
  };
}
inline f32 magnitude(const Vector& a) {
  return std::sqrt(dot(a, a));
}
inline Vector normalize(const Vector& a) {
  return a / magnitude(a);
}



struct Ray {
  Point o;
  Vector v;
};
inline Ray make_ray(const Point& o, const Vector& v) {
  return Ray { o, v };
}



struct Triangle {
  Point o;
  Vector u;
  Vector v;
};
inline Triangle make_tri(const Point& a, const Point& b, const Point& c) {
  Vector u = b - a;
  Vector v = c - a;
  return Triangle { a, u, v };
}



struct Barycentric {
  f32 u, v;
};
Barycentric make_bary(const Point& p_, const Triangle& tri) {
  Vector a = tri.u;
  Vector b = tri.v;
  Vector p = p_ - tri.o;
  // See: https://gamedev.stackexchange.com/questions/23743/whats-the-most-efficient-way-to-find-barycentric-coordinates
  f32 d00 = dot(a, a);
  f32 d01 = dot(a, b);
  f32 d11 = dot(b, b);
  f32 d20 = dot(p, a);
  f32 d21 = dot(p, b);
  f32 denom = d00 * d11 - d01 * d01;
  f32 u = (d11 * d20 - d01 * d21) / denom;
  f32 v = (d00 * d21 - d01 * d20) / denom;
  return Barycentric { u, v };
}
inline bool is_valid_bary(const Barycentric& bary) {
  return bary.u >= 0 || bary.v >= 0 && bary.u + bary.v <= 1;
}



enum HitKind {
  L_HIT_KIND_NONE  = 0,
  L_HIT_KIND_FRONT = 1,
  L_HIT_KIND_BACK  = 2,
};
// Returns positive ray time if the ray intersects the triangle plane at front;
// negative ray time if the ray intersects the triangle plane at back; NaN if
// the ray doesn't intersect the triangle.
f32 ray_cast_tri(const Ray& ray, const Triangle& tri) {
  Vector n = normalize(cross(tri.u, tri.v));
  // Distance from the ray origin to the triangle plane.
  f32 r1 = dot(tri.o - ray.o, n);
  // Length of projection of the ray direction vector in normal direction.
  f32 r2 = dot(ray.v, n);
  if (r1 * r2 <= 0.0) { return NAN; }
  // Distance from the ray origin to the triangle.
  f32 t = r1 / r2;
  return r2 < 0.0 ? t : -t;
}




} // namespace gpumagi
