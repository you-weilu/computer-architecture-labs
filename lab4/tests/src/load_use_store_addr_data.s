# Family b: Load & ALU producers -> store-address and store-data consumers (d=0..4+)
    lui  x20, 2
    addi x21, x20, 64
    addi x22, x20, 128
    sw   x21, 0(x20)
    sw   x22, 4(x20)
    addi x1, x0, 0x111
    addi x2, x0, 0x222
    sw   x1, 8(x20)
    sw   x2, 12(x20)
    # Load producer -> store-address consumer at distance 0
    lw   x10, 0(x20)
    sw   x1, 0(x10)
    lw   x11, 0(x10)
    # Load producer -> store-data consumer at distance 0
    lw   x12, 8(x20)
    sw   x12, 0(x22)
    lw   x13, 0(x22)
    # ALU producer -> store-address consumer at distance 0
    addi x14, x20, 160
    sw   x2, 0(x14)
    lw   x15, 0(x14)
    # ALU producer -> store-data consumer at distance 0
    addi x16, x1, 10
    sw   x16, 32(x21)
    lw   x17, 32(x21)
    # Load producer -> store-address consumer at distance 1
    lw   x10, 0(x20)
    addi x0, x0, 0
    sw   x1, 4(x10)
    lw   x11, 4(x10)
    # Load producer -> store-data consumer at distance 1
    lw   x12, 8(x20)
    addi x0, x0, 0
    sw   x12, 4(x22)
    lw   x13, 4(x22)
    # ALU producer -> store-address consumer at distance 1
    addi x14, x20, 164
    addi x0, x0, 0
    sw   x2, 0(x14)
    lw   x15, 0(x14)
    # ALU producer -> store-data consumer at distance 1
    addi x16, x1, 11
    addi x0, x0, 0
    sw   x16, 36(x21)
    lw   x17, 36(x21)
    # Load producer -> store-address consumer at distance 2
    lw   x10, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x1, 8(x10)
    lw   x11, 8(x10)
    # Load producer -> store-data consumer at distance 2
    lw   x12, 8(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x12, 8(x22)
    lw   x13, 8(x22)
    # ALU producer -> store-address consumer at distance 2
    addi x14, x20, 168
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x2, 0(x14)
    lw   x15, 0(x14)
    # ALU producer -> store-data consumer at distance 2
    addi x16, x1, 12
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x16, 40(x21)
    lw   x17, 40(x21)
    # Load producer -> store-address consumer at distance 3
    lw   x10, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x1, 12(x10)
    lw   x11, 12(x10)
    # Load producer -> store-data consumer at distance 3
    lw   x12, 8(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x12, 12(x22)
    lw   x13, 12(x22)
    # ALU producer -> store-address consumer at distance 3
    addi x14, x20, 172
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x2, 0(x14)
    lw   x15, 0(x14)
    # ALU producer -> store-data consumer at distance 3
    addi x16, x1, 13
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x16, 44(x21)
    lw   x17, 44(x21)
    # Load producer -> store-address consumer at distance 4
    lw   x10, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x1, 16(x10)
    lw   x11, 16(x10)
    # Load producer -> store-data consumer at distance 4
    lw   x12, 8(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x12, 16(x22)
    lw   x13, 16(x22)
    # ALU producer -> store-address consumer at distance 4
    addi x14, x20, 176
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x2, 0(x14)
    lw   x15, 0(x14)
    # ALU producer -> store-data consumer at distance 4
    addi x16, x1, 14
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x16, 48(x21)
    lw   x17, 48(x21)
    ecall
