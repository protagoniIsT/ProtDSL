#ifndef SIMLIB_SEXT_H
#define SIMLIB_SEXT_H

#include <cstdint>
#include <type_traits>
#include "defs.h"

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

inline constexpr sdword_t sext64(word_t val) { return static_cast<sdword_t>(static_cast<sword_t>(val)); }
inline constexpr dword_t zext64(word_t val) { return static_cast<dword_t>(val); }

template<typename T>
inline constexpr word_t trunc32(T val) { return static_cast<word_t>(val); }

#endif // SIMLIB_SEXT_H
