.section .text
.globl _start

_start:
    # Test: exit with code 42
    li a0, 42       # exit code = 42
    li a7, 93       # syscall number for exit
    ecall           # call exit(42)
