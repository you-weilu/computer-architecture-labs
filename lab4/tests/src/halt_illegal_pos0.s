# Family k: Illegal all-zero instruction (0x00000000) at position 0 (PC = 0x00000000, 0 instructions retire)
    .word 0x00000000
    addi x1, x0, 1
    lui  x2, 0x12345
    ecall
