// Auto generated from ProtDSL
#ifndef MEMORY_H
#define MEMORY_H

#include <cstdint>
#include <cstring>
#include <cstdio>
#include "defs.h"

class Memory {
public:
    static constexpr word_t BASE = MEM_BASE;
    static constexpr word_t SIZE = MEM_SIZE;

private:
    uint8_t* data;
    word_t tohost_addr;
    bool tohost_written;

public:
    Memory() : tohost_addr(0), tohost_written(false) {
        data = new uint8_t[SIZE];
        memset(data, 0, SIZE);
    }

    ~Memory() { delete[] data; }
    Memory(const Memory&) = delete;
    Memory& operator=(const Memory&) = delete;

    void reset() {
        memset(data, 0, SIZE);
        tohost_written = false;
    }

    uint8_t* raw() { return data; }
    const uint8_t* raw() const { return data; }

    void set_tohost_addr(word_t addr) { tohost_addr = addr; }
    word_t get_tohost_addr() const { return tohost_addr; }
    bool was_tohost_written() const { return tohost_written; }
    void clear_tohost_written() { tohost_written = false; }

    word_t translate_addr(word_t addr, word_t pc) const {
        if (addr >= BASE && addr < BASE + SIZE) return addr - BASE;
        if (addr < SIZE) return addr;
        fprintf(stderr, "Invalid memory access at 0x%08x (PC=0x%08x)\n", addr, pc);
        return 0;
    }

    uint8_t load8(word_t addr, word_t pc) const {
        word_t phys = translate_addr(addr, pc);
        return data[phys];
    }

    uint16_t load16(word_t addr, word_t pc) const {
        word_t phys = translate_addr(addr, pc);
        return data[phys] | (data[phys + 1] << 8);
    }

    uint32_t load32(word_t addr, word_t pc) const {
        word_t phys = translate_addr(addr, pc);
        return data[phys] | (data[phys + 1] << 8) |
               (data[phys + 2] << 16) | (data[phys + 3] << 24);
    }

    void store8(word_t addr, uint8_t val, word_t pc) {
        word_t phys = translate_addr(addr, pc);
        data[phys] = val;
        check_tohost(addr);
    }

    void store16(word_t addr, uint16_t val, word_t pc) {
        word_t phys = translate_addr(addr, pc);
        data[phys] = val & 0xFF;
        data[phys + 1] = (val >> 8) & 0xFF;
        check_tohost(addr);
    }

    void store32(word_t addr, word_t val, word_t pc) {
        word_t phys = translate_addr(addr, pc);
        data[phys] = val & 0xFF;
        data[phys + 1] = (val >> 8) & 0xFF;
        data[phys + 2] = (val >> 16) & 0xFF;
        data[phys + 3] = (val >> 24) & 0xFF;
        check_tohost(addr);
    }

private:
    void check_tohost(word_t addr) {
        if (tohost_addr != 0 && addr == tohost_addr) tohost_written = true;
    }
};

#endif
