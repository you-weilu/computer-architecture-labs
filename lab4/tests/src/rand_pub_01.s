# Seeded random straight-line Milestone A test (seed=4001, body=35, mem_heavy=False)
    lui  x20, 2
    addi x1, x0, -75
    addi x2, x0, 180
    addi x3, x0, -360
    addi x4, x0, -64
    addi x6, x0, -302
    sw   x4, 0(x20)
    sw   x4, 4(x20)
    sw   x4, 8(x20)
    sw   x6, 12(x20)
    sw   x2, 16(x20)
    sw   x3, 20(x20)
    sw   x6, 24(x20)
    sw   x4, 28(x20)
    sw   x4, 32(x20)
    sw   x3, 36(x20)
    sw   x2, 40(x20)
    sw   x1, 44(x20)
    sw   x1, 48(x20)
    sw   x4, 52(x20)
    sw   x1, 56(x20)
    sw   x1, 60(x20)
    addi x25, x20, 0
    sw   x25, 128(x20)
    addi x25, x20, 8
    sw   x25, 132(x20)
    addi x25, x20, 16
    sw   x25, 136(x20)
    addi x25, x20, 24
    sw   x25, 140(x20)
    lbu   x3, 21(x20)
    xori  x3, x0, 794
    andi  x6, x6, -1003
    sra   x0, x2, x1
    lh    x1, 2(x20)
    add   x6, x0, x0
    slt   x2, x4, x3
    sub   x6, x6, x6
    lw    x4, 44(x20)
    and   x2, x4, x6
    sb    x3, 30(x20)
    sltiu x2, x6, -973
    slli  x4, x2, 4
    or    x6, x1, x3
    srli  x1, x3, 12
    sh    x3, 58(x20)
    slli  x1, x2, 16
    and   x4, x6, x6
    sw    x4, 48(x20)
    sltu  x4, x2, x2
    sub   x0, x2, x1
    lui   x3, 0xf9a38
    sltiu x4, x0, -229
    andi  x4, x3, -733
    srai  x3, x1, 12
    lw    x6, 40(x20)
    ori   x1, x6, -961
    lui   x25, 2
    lh    x4, 26(x25)
    sltu  x2, x1, x3
    add   x6, x3, x4
    ori   x4, x6, 1351
    xori  x3, x3, -1678
    andi  x6, x1, -966
    sra   x1, x2, x2
    xor   x3, x2, x3
    ecall
