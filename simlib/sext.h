#ifndef SIMLIB_SEXT_H
#define SIMLIB_SEXT_H

#include <cstdint>
#include <type_traits>

template<int BITS, typename T = int32_t>
constexpr T sext(uint32_t val) {
    static_assert(BITS > 0 && BITS <= 32, "BITS must be between 1 and 32");
    constexpr uint32_t sign_bit = 1U << (BITS - 1);
    constexpr uint32_t mask = (1U << BITS) - 1;
    val &= mask;
    if (val & sign_bit) {
        if constexpr (BITS < 32) {
            return static_cast<T>(val | (~mask));
        }
    }
    return static_cast<T>(val);
}

inline constexpr int64_t sext64(uint32_t val) { return static_cast<int64_t>(static_cast<int32_t>(val)); }
inline constexpr uint64_t zext64(uint32_t val) { return static_cast<uint64_t>(val); }

template<typename T>
inline constexpr uint32_t trunc32(T val) { return static_cast<uint32_t>(val); }

#endif
