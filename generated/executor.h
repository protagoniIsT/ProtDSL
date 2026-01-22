// Auto generated from ProtDSL
#ifndef EXECUTOR_H
#define EXECUTOR_H

#include "../simlib/defs.h"
#include "../simlib/cpu_state.h"
#include "../simlib/memory.h"
#include "decoder.h"

class Executor {
public:
    static void execute(CpuState& cpu, const DecodedInsn& d, Memory& mem);
};

#endif // EXECUTOR_H
