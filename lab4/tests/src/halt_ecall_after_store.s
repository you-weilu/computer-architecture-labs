# Family k: ecall immediately after a store
    lui  x20, 2
    addi x1, x0, 0x77
    addi x2, x1, 10
    sw   x2, 0(x20)
    ecall
    sw   x1, 4(x20)
