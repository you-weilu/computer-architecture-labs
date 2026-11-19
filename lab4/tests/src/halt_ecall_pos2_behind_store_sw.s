# Family k: ecall at position 2 with sw and addi directly behind it
    lui  x20, 2
    addi x1, x0, 91
    ecall
    sw   x1, 0(x20)
    addi x2, x0, 33
    ecall
