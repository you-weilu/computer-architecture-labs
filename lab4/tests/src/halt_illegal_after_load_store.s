# Family k: Reserved store funct3=4 after load, store, and load-use in flight
    lui  x20, 2
    addi x1, x0, 88
    sw   x1, 0(x20)
    lw   x2, 0(x20)
    addi x3, x2, 12
    sw   x3, 4(x20)
    .word 0x001a4023
    addi x4, x0, 77
    ecall
