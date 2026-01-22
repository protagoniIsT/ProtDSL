#ifndef SIMLIB_ELF_LOADER_H
#define SIMLIB_ELF_LOADER_H

#include <elfio/elfio.hpp>
#include <cstring>
#include "defs.h"
#include "memory.h"

class ElfLoader {
public:
    static bool load(const char* filename, Memory& mem, word_t& entry) {
        ELFIO::elfio reader;
        
        if (!reader.load(filename)) {
            fprintf(stderr, "Cannot open file: %s\n", filename);
            return false;
        }

        if (reader.get_class() != ELFIO::ELFCLASS32) {
            fprintf(stderr, "Not a 32-bit ELF\n");
            return false;
        }

        entry = static_cast<word_t>(reader.get_entry());

        for (const auto& seg : reader.segments) {
            if (seg->get_type() != ELFIO::PT_LOAD) continue;

            word_t vaddr = static_cast<word_t>(seg->get_virtual_address());
            word_t filesz = static_cast<word_t>(seg->get_file_size());
            word_t memsz = static_cast<word_t>(seg->get_memory_size());

            word_t phys = mem.translate_addr(vaddr, 0);
            
            if (filesz > 0) {
                memcpy(mem.raw() + phys, seg->get_data(), filesz);
            }
            
            if (memsz > filesz) {
                memset(mem.raw() + phys + filesz, 0, memsz - filesz);
            }
        }

        find_tohost(reader, mem);

        return true;
    }

private:
    static void find_tohost(const ELFIO::elfio& reader, Memory& mem) {
        for (const auto& sec : reader.sections) {
            if (sec->get_type() != ELFIO::SHT_SYMTAB) continue;

            ELFIO::symbol_section_accessor symbols(reader, sec.get());
            
            for (ELFIO::Elf_Xword i = 0; i < symbols.get_symbols_num(); i++) {
                std::string name;
                ELFIO::Elf64_Addr value = 0;
                ELFIO::Elf_Xword size;
                unsigned char bind, type, other;
                ELFIO::Elf_Half section_index;
                
                symbols.get_symbol(i, name, value, size, bind, type, section_index, other);
                
                if (name == "tohost") {
                    mem.set_tohost_addr(static_cast<word_t>(value));
                    return;
                }
            }
        }
    }
};

#endif // SIMLIB_ELF_LOADER_H
