# Seeded random straight-line Milestone A test (seed=4018, body=45, mem_heavy=True)
    lui  x20, 2
    addi x3, x0, -108
    addi x4, x0, -422
    addi x6, x0, 58
    addi x7, x0, -104
    addi x8, x0, 272
    addi x9, x0, 233
    sw   x8, 0(x20)
    sw   x7, 4(x20)
    sw   x3, 8(x20)
    sw   x8, 12(x20)
    sw   x9, 16(x20)
    sw   x8, 20(x20)
    sw   x3, 24(x20)
    sw   x3, 28(x20)
    sw   x9, 32(x20)
    sw   x9, 36(x20)
    sw   x4, 40(x20)
    sw   x9, 44(x20)
    sw   x9, 48(x20)
    sw   x7, 52(x20)
    sw   x7, 56(x20)
    sw   x9, 60(x20)
    addi x25, x20, 0
    sw   x25, 128(x20)
    addi x25, x20, 8
    sw   x25, 132(x20)
    addi x25, x20, 16
    sw   x25, 136(x20)
    addi x25, x20, 24
    sw   x25, 140(x20)
    add   x4, x6, x7
    addi  x25, x20, 16
    sh    x8, 8(x25)
    slti  x0, x9, -592
    ori   x7, x6, 834
    sb    x0, 49(x20)
    sra   x6, x3, x7
    sh    x9, 42(x20)
    lb    x4, 39(x20)
    lw    x25, 140(x20)
    lhu   x7, 0(x25)
    sltiu x9, x7, -1216
    xori  x8, x6, 1517
    sw    x9, 36(x20)
    sub   x3, x6, x8
    sh    x8, 46(x20)
    lui   x3, 0x53fdf
    sw    x9, 0(x20)
    lw    x25, 136(x20)
    lbu   x6, 1(x25)
    lui   x9, 0x4c59c
    sb    x9, 38(x20)
    andi  x25, x3, 0x18
    add   x25, x20, x25
    lhu   x0, 30(x25)
    andi  x25, x3, 0x18
    add   x25, x20, x25
    sw    x4, 24(x25)
    lw    x25, 136(x20)
    lb    x7, 17(x25)
    lw    x7, 24(x20)
    lw    x25, 136(x20)
    lb    x9, 16(x25)
    sw    x6, 16(x20)
    xori  x9, x7, -978
    andi  x25, x7, 0x18
    add   x25, x20, x25
    sb    x8, 4(x25)
    srai  x6, x7, 23
    lui   x25, 2
    lhu   x6, 2(x25)
    lbu   x6, 29(x20)
    lh    x8, 58(x20)
    sltu  x8, x3, x3
    sh    x8, 32(x20)
    lw    x25, 128(x20)
    sh    x3, 30(x25)
    lw    x25, 140(x20)
    lhu   x3, 26(x25)
    lhu   x7, 6(x20)
    andi  x25, x8, 0x18
    add   x25, x20, x25
    lhu   x3, 0(x25)
    andi  x25, x3, 0x18
    add   x25, x20, x25
    lbu   x4, 20(x25)
    lhu   x8, 2(x20)
    add   x3, x0, x0
    lhu   x4, 34(x20)
    sb    x7, 15(x20)
    lui   x3, 0x8faa7
    andi  x25, x0, 0x18
    add   x25, x20, x25
    lbu   x8, 21(x25)
    add   x3, x4, x3
    ecall
