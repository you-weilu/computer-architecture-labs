# Family k: Illegal R-type funct7 at position 3 after in-flight store, with sb and auipc behind it
    lui   x20, 2
    addi  x1, x0, 0x7b
    sw    x1, 0(x20)
    .word 0x4010c1b3
    sb    x1, 12(x20)
    auipc x6, 2
    ecall
