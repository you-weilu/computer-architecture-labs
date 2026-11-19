# Family k: Unsupported fence instruction after in-flight ALU and store
    lui  x20, 2
    addi x1, x0, 33
    sw   x1, 0(x20)
    addi x2, x1, 11
    .word 0x0ff0000f
    addi x3, x0, 99
    ecall
