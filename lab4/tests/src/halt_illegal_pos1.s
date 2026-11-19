# Family k: Illegal shift funct7 at position 1 after 1 ALU op
    addi x1, x0, 42
    .word 0x40109113
    addi x2, x0, 99
    ecall
