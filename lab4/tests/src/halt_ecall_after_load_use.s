# Family k: ecall immediately after a load-use pair
    lui  x20, 2
    addi x1, x0, 42
    sw   x1, 0(x20)
    lw   x2, 0(x20)
    addi x3, x2, 8
    ecall
    addi x4, x0, 99
