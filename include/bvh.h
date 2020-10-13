#include <stdint.h>

struct uint3 {
    uint32_t x, y, z;
};
struct float3 {
    float x, y, z;
};

uint3 pi3add(uint3 a, uint3 b) {
    return uint3 {
        .x = a.x + b.x,
        .y = a.y + b.y,
        .z = a.z + b.z,
    };
}
float3 ps3add(float3 a, float3 b);

struct Ray {
    float3 o;
    float3 v;
};

struct Triangle {
    float3 o;
    float3 u;
    float3 v;
};
Triangle make_tri(float3 a, float3 b, float3 c) {

}

enum AabbFacingMask {
    L_AABB_FACING_X_MIN = 0,
    L_AABB_FACING_X_MAX = 1,
    L_AABB_FACING_Y_MIN = 2,
    L_AABB_FACING_Y_MAX = 3,
    L_AABB_FACING_Z_MIN = 4,
    L_AABB_FACING_Z_MAX = 5,
    L_AABB_FACING_BEGIN_RANGE = L_AABB_FACING_X_MAX,
    L_AABB_FACING_END_RANGE = L_AABB_FACING_Z_MIN,
    L_AABB_FACING_RANGE_SIZE = (L_AABB_FACING_END_RANGE - L_AABB_FACING_BEGIN_RANGE) + 1,
};
struct Aabb {
    float facing[L_AABB_FACING_RANGE_SIZE];
};
bool intersect_aabb(const Aabb* aabb, , float* tmax) {
    
}

struct BvhNode {
};

struct Bvh {

}

BvhNode create_bvh() {

}

