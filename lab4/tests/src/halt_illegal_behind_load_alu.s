# Family k: Illegal store funct3=4 with younger lw into trace-read register and addi behind it
    lui  x20, 2
    addi x1, x0, 35
    addi x4, x0, 99
    sw   x1, 0(x20)
    sw   x4, 4(x20)
    lw   x2, 0(x20)
    add  x3, x2, x1
    .word 0x001a4023
    lw   x2, 4(x20)
    addi x5, x2, 7
    ecall
