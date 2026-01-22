// Auto generated from ProtDSL
#ifndef DEFS_H
#define DEFS_H

#include <cstdint>

using word_t = uint32_t;
using sword_t = int32_t;
using dword_t = uint64_t;
using sdword_t = int64_t;

constexpr word_t INSN_SIZE = 4;
constexpr int NUM_REGS = 32;
constexpr word_t MEM_BASE = 0x80000000u;
constexpr word_t MEM_SIZE = 134217728u;
constexpr word_t RESET_PC = 0x80000000u;

#endif
