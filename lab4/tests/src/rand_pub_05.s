# Seeded random straight-line Milestone A test (seed=4069, body=75, mem_heavy=False)
    lui  x20, 2
    addi x1, x0, -408
    addi x2, x0, -22
    addi x3, x0, -288
    addi x4, x0, 461
    addi x6, x0, 474
    sw   x1, 0(x20)
    sw   x1, 4(x20)
    sw   x4, 8(x20)
    sw   x1, 12(x20)
    sw   x6, 16(x20)
    sw   x6, 20(x20)
    sw   x6, 24(x20)
    sw   x2, 28(x20)
    sw   x3, 32(x20)
    sw   x3, 36(x20)
    sw   x2, 40(x20)
    sw   x3, 44(x20)
    sw   x3, 48(x20)
    sw   x1, 52(x20)
    sw   x1, 56(x20)
    sw   x4, 60(x20)
    addi x25, x20, 0
    sw   x25, 128(x20)
    addi x25, x20, 8
    sw   x25, 132(x20)
    addi x25, x20, 16
    sw   x25, 136(x20)
    addi x25, x20, 24
    sw   x25, 140(x20)
    lbu   x3, 2(x20)
    sltu  x6, x6, x2
    slti  x4, x1, -1003
    or    x6, x6, x6
    lui   x3, 0x186a9
    andi  x25, x4, 0x18
    add   x25, x20, x25
    lb    x1, 30(x25)
    slti  x6, x2, -502
    slli  x4, x4, 3
    xor   x3, x1, x2
    ori   x2, x2, -990
    or    x2, x1, x1
    lui   x25, 2
    lw    x2, 4(x25)
    lb    x1, 27(x20)
    sb    x4, 52(x20)
    sll   x2, x1, x1
    lhu   x6, 42(x20)
    sub   x4, x6, x2
    lbu   x3, 60(x20)
    lui   x25, 2
    lhu   x2, 8(x25)
    xor   x1, x6, x4
    ori   x6, x3, -972
    and   x3, x6, x1
    andi  x4, x4, -1019
    addi  x25, x20, 16
    lh    x2, 28(x25)
    sra   x2, x3, x4
    lui   x1, 0xffbde
    lhu   x3, 4(x20)
    lhu   x4, 42(x20)
    ori   x6, x4, 1806
    ori   x0, x3, 1910
    xori  x2, x1, -963
    sltu  x2, x1, x6
    sub   x3, x4, x6
    lb    x4, 1(x20)
    xor   x6, x0, x4
    sltiu x3, x2, -187
    sltu  x0, x6, x6
    slti  x1, x1, -964
    srli  x4, x3, 3
    slli  x4, x0, 12
    slti  x4, x4, -1017
    srl   x6, x3, x1
    sb    x0, 28(x20)
    add   x2, x3, x1
    xori  x6, x6, -243
    lhu   x3, 26(x20)
    srl   x2, x4, x3
    sw    x1, 44(x20)
    andi  x2, x2, -1013
    add   x6, x0, x0
    xori  x1, x4, 1150
    srai  x1, x4, 29
    xori  x1, x6, 1066
    sltiu x3, x3, 276
    srai  x1, x2, 7
    add   x3, x0, x4
    lui   x1, 0x1d613
    and   x1, x2, x2
    sh    x3, 24(x20)
    sll   x3, x2, x2
    lw    x2, 24(x20)
    lb    x6, 33(x20)
    srai  x0, x2, 0
    sra   x3, x3, x2
    lui   x3, 0x1b273
    slti  x3, x6, -920
    slti  x6, x0, -564
    sw    x2, 24(x20)
    or    x6, x2, x1
    srl   x4, x6, x3
    sh    x2, 18(x20)
    lw    x25, 140(x20)
    lbu   x2, 28(x25)
    sub   x6, x4, x4
    xor   x3, x3, x3
    andi  x25, x6, 0x18
    add   x25, x20, x25
    lw    x1, 4(x25)
    ecall
