// Auto generated from ProtDSL
#ifndef CPU_STATE_H
#define CPU_STATE_H

#include "defs.h"

class Memory;

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
        pc = RESET_PC;
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
};

#endif
