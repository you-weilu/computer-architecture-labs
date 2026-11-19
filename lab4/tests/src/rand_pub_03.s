# Seeded random straight-line Milestone A test (seed=4035, body=55, mem_heavy=False)
    lui  x20, 2
    addi x1, x0, -187
    addi x2, x0, 287
    addi x7, x0, -356
    addi x8, x0, -462
    addi x12, x0, -69
    sw   x1, 0(x20)
    sw   x1, 4(x20)
    sw   x1, 8(x20)
    sw   x2, 12(x20)
    sw   x2, 16(x20)
    sw   x7, 20(x20)
    sw   x2, 24(x20)
    sw   x2, 28(x20)
    sw   x12, 32(x20)
    sw   x2, 36(x20)
    sw   x8, 40(x20)
    sw   x8, 44(x20)
    sw   x1, 48(x20)
    sw   x7, 52(x20)
    sw   x7, 56(x20)
    sw   x8, 60(x20)
    addi x25, x20, 0
    sw   x25, 128(x20)
    addi x25, x20, 8
    sw   x25, 132(x20)
    addi x25, x20, 16
    sw   x25, 136(x20)
    addi x25, x20, 24
    sw   x25, 140(x20)
    andi  x25, x8, 0x18
    add   x25, x20, x25
    lbu   x12, 9(x25)
    lui   x1, 0x42000
    addi  x25, x20, 16
    sw    x7, 4(x25)
    lw    x7, 56(x20)
    xor   x0, x12, x0
    add   x12, x1, x12
    addi  x0, x12, -1013
    add   x2, x12, x7
    lui   x8, 0x46bf7
    and   x2, x0, x7
    srl   x2, x1, x8
    and   x1, x8, x12
    slt   x1, x7, x12
    sltu  x12, x2, x12
    lbu   x2, 58(x20)
    srli  x1, x12, 20
    sra   x2, x2, x2
    sltu  x12, x1, x1
    sltiu x1, x2, -686
    slt   x2, x12, x8
    lw    x7, 44(x20)
    sh    x8, 58(x20)
    sltiu x12, x12, 1430
    ori   x12, x1, 141
    xori  x7, x7, 527
    sltu  x12, x0, x2
    sb    x2, 28(x20)
    sb    x1, 28(x20)
    addi  x25, x20, 16
    sw    x8, 0(x25)
    sltu  x12, x0, x2
    andi  x0, x12, -1011
    sub   x8, x7, x7
    lui   x7, 0x299c2
    and   x12, x12, x2
    sb    x7, 21(x20)
    lui   x25, 2
    sw    x2, 12(x25)
    lui   x8, 0x8d3e4
    lw    x1, 16(x20)
    xor   x8, x0, x0
    lhu   x12, 46(x20)
    lhu   x12, 46(x20)
    addi  x1, x8, -559
    lui   x1, 0xb6541
    lui   x12, 0x7a266
    slli  x1, x8, 9
    sb    x1, 46(x20)
    srai  x2, x2, 19
    sw    x1, 28(x20)
    addi  x25, x20, 24
    lhu   x1, 24(x25)
    sb    x7, 14(x20)
    lw    x25, 140(x20)
    lb    x7, 7(x25)
    and   x0, x1, x1
    sltiu x1, x12, -970
    xori  x8, x0, -966
    sub   x2, x0, x7
    ecall
