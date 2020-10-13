#include <cstdint>

namespace gpumagi {

// Unit representation of binary information.
struct bit {
  // MUST BE EITHER 0 OR 1.
  uint8_t x;

  template<typename T>
  explicit operator T() { return T(x); }
};
inline bit operator&(bit a, bit b) { return bit { uint8_t(a.x & b.x) }; }
inline bit operator|(bit a, bit b) { return bit { uint8_t(a.x | b.x) }; }
inline bit operator^(bit a, bit b) { return bit { uint8_t(a.x ^ b.x) }; }
inline bit operator~(bit a) { return bit { uint8_t(1 ^ a.x) }; }

// A collection of bits sorted in in little-endian order.
struct b32 {
  union {
    uint32_t _word;
    struct {
      uint32_t _0: 1;
      uint32_t _1: 1;
      uint32_t _2: 1;
      uint32_t _3: 1;
      uint32_t _4: 1;
      uint32_t _5: 1;
      uint32_t _6: 1;
      uint32_t _7: 1;
      uint32_t _8: 1;
      uint32_t _9: 1;
      uint32_t _10: 1;
      uint32_t _11: 1;
      uint32_t _12: 1;
      uint32_t _13: 1;
      uint32_t _14: 1;
      uint32_t _15: 1;
      uint32_t _16: 1;
      uint32_t _17: 1;
      uint32_t _18: 1;
      uint32_t _19: 1;
      uint32_t _20: 1;
      uint32_t _21: 1;
      uint32_t _22: 1;
      uint32_t _23: 1;
      uint32_t _24: 1;
      uint32_t _25: 1;
      uint32_t _26: 1;
      uint32_t _27: 1;
      uint32_t _28: 1;
      uint32_t _29: 1;
      uint32_t _30: 1;
      uint32_t _31: 1;
    };
  };

  // Set the bit at `idx` to `v`.
  inline void set(uint32_t idx, bit v) {
    _word = (_word & ~(1 << idx)) | (static_cast<uint32_t>(v) << idx);
  }
  constexpr bit get(uint32_t idx) const {
    return bit { (_word >> idx) & 1 };
  }
};
static_assert(sizeof(b32) == 4, "b32 is not 32-bit long");





// Represent a signed 32-bit integer.
struct i32 { b32 bits; };

#define L_DEFINE_LOGICAL_BINARY_OP(op)                                         \
  inline i32 operator op(i32 a, i32 b) {                                       \
    i32 z;                                                                     \
    for (auto i = 0; i < 32; ++i) {                                            \
      bit cur = a.bits.get(i) op b.bits.get(i);                                \
      z.bits.set(i, cur);                                                      \
    }                                                                          \
    return z;                                                                  \
  }

L_DEFINE_LOGICAL_BINARY_OP(&);
L_DEFINE_LOGICAL_BINARY_OP(|);
L_DEFINE_LOGICAL_BINARY_OP(^);

#undef L_DEFINE_LOGICAL_BINARY_OP

inline i32 operator~(i32 a) {
  i32 z;
  for (auto i = 0; i < 32; ++i) {
    z.bits.set(i, ~a.bits.get(i));
  }
  return z;
}





// Represent a 32-bit single-precision floating-point number.
struct f32 {
  b32 bits;
};

} // namespace gpumagi
