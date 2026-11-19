# Family e: Store data from just-computed or just-loaded register for sb, sh, sw (d=0..4+)
    lui  x20, 2
    lui  x1, 0x11223
    addi x1, x1, 0x344
    sw   x1, 0(x20)
    # ALU -> sb, sh, sw at distance 0
    addi x10, x1, 1
    sb   x10, 16(x20)
    addi x11, x1, 2
    sh   x11, 18(x20)
    addi x12, x1, 3
    sw   x12, 20(x20)
    # Load -> sb, sh, sw at distance 0
    lb   x13, 0(x20)
    sb   x13, 24(x20)
    lh   x14, 0(x20)
    sh   x14, 26(x20)
    lw   x15, 0(x20)
    sw   x15, 28(x20)
    lw   x16, 16(x20)
    lw   x17, 20(x20)
    lw   x18, 24(x20)
    lw   x19, 28(x20)
    # ALU -> sb, sh, sw at distance 1
    addi x10, x1, 2
    addi x0, x0, 0
    sb   x10, 32(x20)
    addi x11, x1, 3
    addi x0, x0, 0
    sh   x11, 34(x20)
    addi x12, x1, 4
    addi x0, x0, 0
    sw   x12, 36(x20)
    # Load -> sb, sh, sw at distance 1
    lb   x13, 0(x20)
    addi x0, x0, 0
    sb   x13, 40(x20)
    lh   x14, 0(x20)
    addi x0, x0, 0
    sh   x14, 42(x20)
    lw   x15, 0(x20)
    addi x0, x0, 0
    sw   x15, 44(x20)
    lw   x16, 32(x20)
    lw   x17, 36(x20)
    lw   x18, 40(x20)
    lw   x19, 44(x20)
    # ALU -> sb, sh, sw at distance 2
    addi x10, x1, 3
    addi x0, x0, 0
    addi x0, x0, 0
    sb   x10, 48(x20)
    addi x11, x1, 4
    addi x0, x0, 0
    addi x0, x0, 0
    sh   x11, 50(x20)
    addi x12, x1, 5
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x12, 52(x20)
    # Load -> sb, sh, sw at distance 2
    lb   x13, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    sb   x13, 56(x20)
    lh   x14, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    sh   x14, 58(x20)
    lw   x15, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x15, 60(x20)
    lw   x16, 48(x20)
    lw   x17, 52(x20)
    lw   x18, 56(x20)
    lw   x19, 60(x20)
    # ALU -> sb, sh, sw at distance 3
    addi x10, x1, 4
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sb   x10, 64(x20)
    addi x11, x1, 5
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sh   x11, 66(x20)
    addi x12, x1, 6
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x12, 68(x20)
    # Load -> sb, sh, sw at distance 3
    lb   x13, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sb   x13, 72(x20)
    lh   x14, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sh   x14, 74(x20)
    lw   x15, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x15, 76(x20)
    lw   x16, 64(x20)
    lw   x17, 68(x20)
    lw   x18, 72(x20)
    lw   x19, 76(x20)
    # ALU -> sb, sh, sw at distance 4
    addi x10, x1, 5
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sb   x10, 80(x20)
    addi x11, x1, 6
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sh   x11, 82(x20)
    addi x12, x1, 7
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x12, 84(x20)
    # Load -> sb, sh, sw at distance 4
    lb   x13, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sb   x13, 88(x20)
    lh   x14, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sh   x14, 90(x20)
    lw   x15, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x15, 92(x20)
    lw   x16, 80(x20)
    lw   x17, 84(x20)
    lw   x18, 88(x20)
    lw   x19, 92(x20)
    ecall
