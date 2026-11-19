# Family k: Unsupported M-extension mul after in-flight load and ALU op
    lui  x20, 2
    addi x1, x0, 6
    sw   x1, 0(x20)
    lw   x2, 0(x20)
    .word 0x022081b3
    addi x4, x0, 1
    ecall
