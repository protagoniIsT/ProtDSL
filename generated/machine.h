// Auto generated from ProtDSL
#ifndef MACHINE_H
#define MACHINE_H

#include "defs.h"
#include "memory.h"
#include "../simlib/elf_loader.h"
#include "hart.h"

class Machine {
public:
    Machine() : hart_(mem_) {}

    bool load_elf(const char* filename) {
        word_t entry = 0;
        if (!ElfLoader::load(filename, mem_, entry)) return false;
        hart_.set_pc(entry);
        return true;
    }

    int run() {
        while (hart_.step()) {
            if (mem_.was_tohost_written()) {
                word_t tohost = mem_.load32(mem_.get_tohost_addr(), 0);
                if (tohost & 1) { hart_.cpu().exit_code = tohost >> 1; break; }
                mem_.clear_tohost_written();
            }
        }
        return hart_.cpu().exit_code;
    }

    Hart& hart() { return hart_; }
    Memory& memory() { return mem_; }

private:
    Memory mem_;
    Hart hart_;
};

#endif // MACHINE_H
