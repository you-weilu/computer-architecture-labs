# Family k: ecall at position 1 with lui and auipc directly behind it
    addi  x1, x0, 19
    ecall
    lui   x5, 0x12345
    auipc x6, 1
    ecall
