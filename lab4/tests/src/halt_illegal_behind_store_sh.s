# Family k: Illegal shift funct7 directly after in-flight load, with sh and lui behind it
    lui  x20, 2
    addi x1, x0, 0x234
    sw   x1, 0(x20)
    lw   x2, 0(x20)
    .word 0x40111193
    sh   x1, 6(x20)
    lui  x5, 0xabcde
    ecall
