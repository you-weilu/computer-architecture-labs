# Family k: Illegal R-type funct7 at position 2 after 2 ALU ops
    addi x1, x0, 10
    addi x2, x1, 20
    .word 0x4020c1b3
    addi x3, x0, 30
    ecall
