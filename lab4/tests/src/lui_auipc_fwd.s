# Family d: lui and auipc producers forwarded to all consumer operand roles (d=0..4+)
    lui  x20, 2
    addi x1, x0, 55
    sw   x1, 0(x20)
    sw   x1, 4(x20)
    sw   x1, 8(x20)
    sw   x1, 12(x20)
    sw   x1, 16(x20)
    # lui -> rs1 (distance 0)
    lui  x5, 0x12345
    addi x6, x5, 0x678
    # lui -> rs2 (distance 0)
    lui  x7, 0x00abc
    add  x8, x1, x7
    # lui -> same register twice (distance 0)
    lui  x9, 0x00011
    add  x10, x9, x9
    # auipc -> rs1 and rs2 (distance 0)
    auipc x11, 0
    addi  x12, x11, 16
    auipc x13, 1
    add   x14, x1, x13
    # lui + auipc -> both operands (distance 0)
    lui   x15, 3
    auipc x16, 0
    add   x17, x15, x16
    # lui -> store data (distance 0)
    lui   x18, 0x54321
    sw    x18, 32(x20)
    # lui -> load address (distance 0)
    lui   x19, 2
    lw    x21, 0(x19)
    # lui -> store address (distance 0)
    lui   x22, 2
    sw    x1, 64(x22)
    # lui -> rs1 (distance 1)
    lui  x5, 0x12345
    addi x0, x0, 0
    addi x6, x5, 0x678
    # lui -> rs2 (distance 1)
    lui  x7, 0x00abc
    addi x0, x0, 0
    add  x8, x1, x7
    # lui -> same register twice (distance 1)
    lui  x9, 0x00011
    addi x0, x0, 0
    add  x10, x9, x9
    # auipc -> rs1 and rs2 (distance 1)
    auipc x11, 0
    addi x0, x0, 0
    addi  x12, x11, 16
    auipc x13, 1
    addi x0, x0, 0
    add   x14, x1, x13
    # lui + auipc -> both operands (distance 1)
    lui   x15, 3
    auipc x16, 0
    addi x0, x0, 0
    add   x17, x15, x16
    # lui -> store data (distance 1)
    lui   x18, 0x54321
    addi x0, x0, 0
    sw    x18, 36(x20)
    # lui -> load address (distance 1)
    lui   x19, 2
    addi x0, x0, 0
    lw    x21, 4(x19)
    # lui -> store address (distance 1)
    lui   x22, 2
    addi x0, x0, 0
    sw    x1, 68(x22)
    # lui -> rs1 (distance 2)
    lui  x5, 0x12345
    addi x0, x0, 0
    addi x0, x0, 0
    addi x6, x5, 0x678
    # lui -> rs2 (distance 2)
    lui  x7, 0x00abc
    addi x0, x0, 0
    addi x0, x0, 0
    add  x8, x1, x7
    # lui -> same register twice (distance 2)
    lui  x9, 0x00011
    addi x0, x0, 0
    addi x0, x0, 0
    add  x10, x9, x9
    # auipc -> rs1 and rs2 (distance 2)
    auipc x11, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi  x12, x11, 16
    auipc x13, 1
    addi x0, x0, 0
    addi x0, x0, 0
    add   x14, x1, x13
    # lui + auipc -> both operands (distance 2)
    lui   x15, 3
    auipc x16, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add   x17, x15, x16
    # lui -> store data (distance 2)
    lui   x18, 0x54321
    addi x0, x0, 0
    addi x0, x0, 0
    sw    x18, 40(x20)
    # lui -> load address (distance 2)
    lui   x19, 2
    addi x0, x0, 0
    addi x0, x0, 0
    lw    x21, 8(x19)
    # lui -> store address (distance 2)
    lui   x22, 2
    addi x0, x0, 0
    addi x0, x0, 0
    sw    x1, 72(x22)
    # lui -> rs1 (distance 3)
    lui  x5, 0x12345
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x6, x5, 0x678
    # lui -> rs2 (distance 3)
    lui  x7, 0x00abc
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x8, x1, x7
    # lui -> same register twice (distance 3)
    lui  x9, 0x00011
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x10, x9, x9
    # auipc -> rs1 and rs2 (distance 3)
    auipc x11, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi  x12, x11, 16
    auipc x13, 1
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add   x14, x1, x13
    # lui + auipc -> both operands (distance 3)
    lui   x15, 3
    auipc x16, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add   x17, x15, x16
    # lui -> store data (distance 3)
    lui   x18, 0x54321
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw    x18, 44(x20)
    # lui -> load address (distance 3)
    lui   x19, 2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lw    x21, 12(x19)
    # lui -> store address (distance 3)
    lui   x22, 2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw    x1, 76(x22)
    # lui -> rs1 (distance 4)
    lui  x5, 0x12345
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x6, x5, 0x678
    # lui -> rs2 (distance 4)
    lui  x7, 0x00abc
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x8, x1, x7
    # lui -> same register twice (distance 4)
    lui  x9, 0x00011
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x10, x9, x9
    # auipc -> rs1 and rs2 (distance 4)
    auipc x11, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi  x12, x11, 16
    auipc x13, 1
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add   x14, x1, x13
    # lui + auipc -> both operands (distance 4)
    lui   x15, 3
    auipc x16, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add   x17, x15, x16
    # lui -> store data (distance 4)
    lui   x18, 0x54321
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw    x18, 48(x20)
    # lui -> load address (distance 4)
    lui   x19, 2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lw    x21, 16(x19)
    # lui -> store address (distance 4)
    lui   x22, 2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw    x1, 80(x22)
    ecall
