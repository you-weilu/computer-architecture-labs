# Family b: Load producer -> store-address consumer across distances 0, 1, 2, 3, 4+
    lui  x20, 2
    addi x21, x20, 64
    addi x22, x20, 96
    addi x23, x20, 128
    addi x24, x20, 160
    sw   x21, 0(x20)
    sw   x22, 4(x20)
    sw   x23, 8(x20)
    sw   x24, 12(x20)
    lui  x1, 0xabcde
    addi x1, x1, 0x123
    addi x2, x0, -99
    # Distance 0: 6x load -> store address across sw, sh, sb
    lw   x5, 0(x20)
    sw   x1, 0(x5)
    lw   x6, 4(x20)
    sh   x2, 0(x6)
    lw   x7, 8(x20)
    sb   x1, 0(x7)
    lhu  x8, 12(x20)
    sw   x2, 0(x8)
    lw   x9, 12(x20)
    sw   x1, -4(x9)
    lhu  x10, 8(x20)
    sh   x1, 16(x10)
    # Distance 1: 6x load -> store address across sw, sh, sb
    lw   x5, 0(x20)
    addi x0, x0, 0
    sw   x1, 4(x5)
    lw   x6, 4(x20)
    addi x0, x0, 0
    sh   x2, 2(x6)
    lw   x7, 8(x20)
    addi x0, x0, 0
    sb   x1, 1(x7)
    lhu  x8, 12(x20)
    addi x0, x0, 0
    sw   x2, 4(x8)
    lw   x9, 12(x20)
    addi x0, x0, 0
    sw   x1, -4(x9)
    lhu  x10, 8(x20)
    addi x0, x0, 0
    sh   x1, 18(x10)
    # Distance 2: 6x load -> store address across sw, sh, sb
    lw   x5, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x1, 8(x5)
    lw   x6, 4(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    sh   x2, 4(x6)
    lw   x7, 8(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    sb   x1, 2(x7)
    lhu  x8, 12(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x2, 8(x8)
    lw   x9, 12(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x1, -4(x9)
    lhu  x10, 8(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    sh   x1, 20(x10)
    # Distance 3: 6x load -> store address across sw, sh, sb
    lw   x5, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x1, 12(x5)
    lw   x6, 4(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sh   x2, 6(x6)
    lw   x7, 8(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sb   x1, 3(x7)
    lhu  x8, 12(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x2, 12(x8)
    lw   x9, 12(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x1, -4(x9)
    lhu  x10, 8(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sh   x1, 22(x10)
    # Distance 4: 6x load -> store address across sw, sh, sb
    lw   x5, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x1, 16(x5)
    lw   x6, 4(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sh   x2, 8(x6)
    lw   x7, 8(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sb   x1, 4(x7)
    lhu  x8, 12(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x2, 16(x8)
    lw   x9, 12(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x1, -4(x9)
    lhu  x10, 8(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sh   x1, 24(x10)
    lw   x11, 0(x21)
    lw   x12, 0(x22)
    lw   x13, 0(x23)
    lw   x14, -4(x24)
    ecall
