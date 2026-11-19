# Family b: ALU producer -> load-address & store-address consumers across distances 0, 1, 2, 3, 4+
    lui  x20, 2
    addi x21, x20, 256
    addi x1, x0, 32
    addi x2, x0, 64
    lui  x3, 0x55aa5
    addi x3, x3, 0x5aa
    addi x4, x0, 0x7bc
    andi x4, x4, 0x0fc
    sw   x3, 0(x20)
    sw   x3, 32(x20)
    sw   x3, 64(x20)
    sw   x3, 96(x20)
    sw   x3, 188(x20)
    # Distance 0: 5x ALU -> store address + 5x ALU -> load address
    addi x5, x20, 128
    sw   x3, 0(x5)
    add  x6, x20, x1
    sh   x3, 0(x6)
    sub  x7, x21, x1
    sb   x3, 0(x7)
    ori  x8, x20, 144
    sw   x3, 0(x8)
    add  x9, x20, x4
    sw   x3, 4(x9)
    addi x10, x20, 128
    lw   x15, 0(x10)
    add  x11, x20, x1
    lh   x16, 0(x11)
    sub  x12, x21, x1
    lbu  x17, 0(x12)
    ori  x13, x20, 144
    lhu  x18, 0(x13)
    add  x14, x20, x4
    lb   x19, 0(x14)
    # Distance 1: 5x ALU -> store address + 5x ALU -> load address
    addi x5, x20, 132
    addi x0, x0, 0
    sw   x3, 0(x5)
    add  x6, x20, x1
    addi x0, x0, 0
    sh   x3, 2(x6)
    sub  x7, x21, x1
    addi x0, x0, 0
    sb   x3, 1(x7)
    ori  x8, x20, 144
    addi x0, x0, 0
    sw   x3, 4(x8)
    add  x9, x20, x4
    addi x0, x0, 0
    sw   x3, 4(x9)
    addi x10, x20, 132
    addi x0, x0, 0
    lw   x15, 0(x10)
    add  x11, x20, x1
    addi x0, x0, 0
    lh   x16, 2(x11)
    sub  x12, x21, x1
    addi x0, x0, 0
    lbu  x17, 1(x12)
    ori  x13, x20, 144
    addi x0, x0, 0
    lhu  x18, 4(x13)
    add  x14, x20, x4
    addi x0, x0, 0
    lb   x19, 0(x14)
    # Distance 2: 5x ALU -> store address + 5x ALU -> load address
    addi x5, x20, 136
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x3, 0(x5)
    add  x6, x20, x1
    addi x0, x0, 0
    addi x0, x0, 0
    sh   x3, 4(x6)
    sub  x7, x21, x1
    addi x0, x0, 0
    addi x0, x0, 0
    sb   x3, 2(x7)
    ori  x8, x20, 144
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x3, 8(x8)
    add  x9, x20, x4
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x3, 4(x9)
    addi x10, x20, 136
    addi x0, x0, 0
    addi x0, x0, 0
    lw   x15, 0(x10)
    add  x11, x20, x1
    addi x0, x0, 0
    addi x0, x0, 0
    lh   x16, 4(x11)
    sub  x12, x21, x1
    addi x0, x0, 0
    addi x0, x0, 0
    lbu  x17, 2(x12)
    ori  x13, x20, 144
    addi x0, x0, 0
    addi x0, x0, 0
    lhu  x18, 8(x13)
    add  x14, x20, x4
    addi x0, x0, 0
    addi x0, x0, 0
    lb   x19, 0(x14)
    # Distance 3: 5x ALU -> store address + 5x ALU -> load address
    addi x5, x20, 140
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x3, 0(x5)
    add  x6, x20, x1
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sh   x3, 6(x6)
    sub  x7, x21, x1
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sb   x3, 3(x7)
    ori  x8, x20, 144
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x3, 12(x8)
    add  x9, x20, x4
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x3, 4(x9)
    addi x10, x20, 140
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lw   x15, 0(x10)
    add  x11, x20, x1
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lh   x16, 6(x11)
    sub  x12, x21, x1
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lbu  x17, 3(x12)
    ori  x13, x20, 144
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lhu  x18, 12(x13)
    add  x14, x20, x4
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lb   x19, 0(x14)
    # Distance 4: 5x ALU -> store address + 5x ALU -> load address
    addi x5, x20, 144
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x3, 0(x5)
    add  x6, x20, x1
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sh   x3, 8(x6)
    sub  x7, x21, x1
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sb   x3, 4(x7)
    ori  x8, x20, 144
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x3, 16(x8)
    add  x9, x20, x4
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x3, 4(x9)
    addi x10, x20, 144
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lw   x15, 0(x10)
    add  x11, x20, x1
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lh   x16, 8(x11)
    sub  x12, x21, x1
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lbu  x17, 4(x12)
    ori  x13, x20, 144
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lhu  x18, 16(x13)
    add  x14, x20, x4
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lb   x19, 0(x14)
    ecall
