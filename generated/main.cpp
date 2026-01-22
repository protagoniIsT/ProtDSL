// Auto generated from ProtDSL
#include <cstdio>
#include "machine.h"

int main(int argc, char* argv[]) {
    if (argc < 2) { fprintf(stderr, "Usage: %s <elf>\n", argv[0]); return 1; }
    Machine m;
    if (!m.load_elf(argv[1])) { fprintf(stderr, "Failed to load: %s\n", argv[1]); return 1; }
    return m.run();
}
