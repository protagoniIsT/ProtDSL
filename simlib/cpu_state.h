#ifndef SIMLIB_CPU_STATE_H
#define SIMLIB_CPU_STATE_H

#include "defs.h"
#include "memory.h"

struct CpuState {
    word_t regs[NUM_REGS];
    word_t pc;
    word_t next_pc;
    
    bool running;
    int exit_code;
    uint64_t insn_count;

    Memory* mem;

    CpuState() : running(false), exit_code(0), insn_count(0), mem(nullptr) {
        reset();
    }

    void reset() {
        for (int i = 0; i < NUM_REGS; i++) regs[i] = 0;
        pc = Memory::MEM_BASE;
        next_pc = pc + INSN_SIZE;
        running = true;
        exit_code = 0;
        insn_count = 0;
    }

    void write_reg(int rd, word_t val) {
        if (rd != 0) regs[rd] = val;
    }

    word_t read_reg(int rs) const {
        return (rs == 0) ? 0 : regs[rs];
    }

    uint8_t load8(word_t addr) const { return mem->load8(addr, pc); }
    uint16_t load16(word_t addr) const { return mem->load16(addr, pc); }
    uint32_t load32(word_t addr) const { return mem->load32(addr, pc); }
    
    void store8(word_t addr, uint8_t val) { mem->store8(addr, val, pc); }
    void store16(word_t addr, uint16_t val) { mem->store16(addr, val, pc); }
    void store32(word_t addr, word_t val) { mem->store32(addr, val, pc); }
};

#endif // SIMLIB_CPU_STATE_H
