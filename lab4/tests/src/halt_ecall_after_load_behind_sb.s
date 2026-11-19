# Family k: ecall directly after in-flight load, with sb and add behind it
    lui  x20, 2
    addi x1, x0, 0x5a
    sw   x1, 0(x20)
    lw   x2, 0(x20)
    ecall
    sb   x1, 8(x20)
    add  x4, x2, x1
    ecall
