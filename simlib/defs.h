#ifndef SIMLIB_DEFS_H
#define SIMLIB_DEFS_H

#include <cstdint>

using word_t = uint32_t;
using sword_t = int32_t;
using dword_t = uint64_t;
using sdword_t = int64_t;

constexpr word_t INSN_SIZE = sizeof(word_t);

constexpr int NUM_REGS = 32;

#endif // SIMLIB_DEFS_H
