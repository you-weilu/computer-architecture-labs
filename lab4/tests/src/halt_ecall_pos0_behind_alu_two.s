# Family k: ecall at position 0 with two real ALU instructions directly behind it
    ecall
    addi x3, x0, 77
    add  x4, x3, x3
    ecall
