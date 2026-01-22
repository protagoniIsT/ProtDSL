// Auto generated from ProtDSL
#ifndef HART_H
#define HART_H

#include "../simlib/cpu_state.h"
#include "../simlib/memory.h"
#include "decoder.h"
#include "executor.h"

class Hart {
public:
    Hart(Memory& mem) : mem_(mem) { reset(); }
    
    void reset() { cpu_.reset(); }
    void set_pc(word_t pc) { cpu_.pc = pc; cpu_.next_pc = pc + INSN_SIZE; }
    
    bool step() {
        if (!cpu_.running) return false;
        word_t raw = mem_.load32(cpu_.pc, cpu_.pc);
        DecodedInsn d = Decoder::decode(raw);
        cpu_.next_pc = cpu_.pc + INSN_SIZE;
        Executor::execute(cpu_, d, mem_);
        cpu_.pc = cpu_.next_pc;
        return cpu_.running;
    }
    
    CpuState& cpu() { return cpu_; }

private:
    CpuState cpu_;
    Memory& mem_;
};

#endif // HART_H
