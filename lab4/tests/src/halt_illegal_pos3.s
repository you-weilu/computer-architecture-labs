# Family k: Reserved load funct3=3 at position 3 after store in flight
    lui  x20, 2
    addi x1, x0, 55
    sw   x1, 0(x20)
    .word 0x000a3183
    addi x2, x0, 66
    ecall
