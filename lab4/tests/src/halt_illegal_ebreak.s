# Family k: ebreak instruction after in-flight store, load, and ALU
    lui  x20, 2
    addi x1, x0, 91
    sw   x1, 0(x20)
    lw   x2, 0(x20)
    add  x3, x2, x1
    .word 0x00100073
    addi x4, x0, 1
    ecall
