// Auto generated from ProtDSL
#ifndef EXECUTOR_H
#define EXECUTOR_H

#include "defs.h"
#include "cpu_state.h"
#include "memory.h"
#include "decoder.h"

class Executor {
public:
    static void execute(CpuState& cpu, const DecodedInsn& d, Memory& mem);
};

#endif // EXECUTOR_H
