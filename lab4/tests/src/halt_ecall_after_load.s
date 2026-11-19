# Family k: ecall immediately after a load
    lui  x20, 2
    addi x1, x0, 0x55
    sw   x1, 0(x20)
    lw   x2, 0(x20)
    ecall
    addi x3, x0, 1
