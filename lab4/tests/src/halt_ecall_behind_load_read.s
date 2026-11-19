# Family k: ecall with younger lw into a trace-read register and consumer add behind it
    lui  x20, 2
    addi x1, x0, 44
    addi x5, x0, 88
    sw   x1, 0(x20)
    sw   x5, 4(x20)
    lw   x2, 0(x20)
    add  x3, x2, x1
    ecall
    lw   x2, 4(x20)
    add  x6, x2, x1
    ecall
