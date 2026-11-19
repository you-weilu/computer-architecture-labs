# Family d2: lui/auipc producer -> load-address, store-address, store-data (d=0..4+)
    lui  x20, 2
    lui  x1, 0xdeadb
    addi x1, x1, 0x6ef
    sw   x1, 0(x20)
    sw   x1, 4(x20)
    sw   x1, 8(x20)
    sw   x1, 12(x20)
    sw   x1, 16(x20)
    # Distance 0: 4x lui -> store_addr, 4x lui -> load_addr, 2x lui -> store_data
    lui  x5, 2
    sw   x1, 32(x5)
    lui  x6, 2
    sh   x1, 64(x6)
    lui  x7, 2
    sb   x1, 80(x7)
    lui  x8, 3
    sw   x1, 0(x8)
    lui  x9, 2
    lw   x13, 0(x9)
    lui  x10, 2
    lh   x14, 0(x10)
    lui  x11, 2
    lbu  x15, 0(x11)
    lui  x12, 3
    lhu  x16, 0(x12)
    lui  x17, 16
    sw   x17, 96(x20)
    lui  x18, 32
    sh   x18, 128(x20)
    lui  x19, 48
    sb   x19, 160(x20)
    lui  x21, 64
    sw   x21, 176(x20)
    # Distance 1: 4x lui -> store_addr, 4x lui -> load_addr, 2x lui -> store_data
    lui  x5, 2
    addi x0, x0, 0
    sw   x1, 36(x5)
    lui  x6, 2
    addi x0, x0, 0
    sh   x1, 66(x6)
    lui  x7, 2
    addi x0, x0, 0
    sb   x1, 81(x7)
    lui  x8, 3
    addi x0, x0, 0
    sw   x1, 4(x8)
    lui  x9, 2
    addi x0, x0, 0
    lw   x13, 4(x9)
    lui  x10, 2
    addi x0, x0, 0
    lh   x14, 2(x10)
    lui  x11, 2
    addi x0, x0, 0
    lbu  x15, 1(x11)
    lui  x12, 3
    addi x0, x0, 0
    lhu  x16, 4(x12)
    lui  x17, 17
    addi x0, x0, 0
    sw   x17, 100(x20)
    lui  x18, 33
    addi x0, x0, 0
    sh   x18, 130(x20)
    lui  x19, 49
    addi x0, x0, 0
    sb   x19, 161(x20)
    lui  x21, 65
    addi x0, x0, 0
    sw   x21, 180(x20)
    # Distance 2: 4x lui -> store_addr, 4x lui -> load_addr, 2x lui -> store_data
    lui  x5, 2
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x1, 40(x5)
    lui  x6, 2
    addi x0, x0, 0
    addi x0, x0, 0
    sh   x1, 68(x6)
    lui  x7, 2
    addi x0, x0, 0
    addi x0, x0, 0
    sb   x1, 82(x7)
    lui  x8, 3
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x1, 8(x8)
    lui  x9, 2
    addi x0, x0, 0
    addi x0, x0, 0
    lw   x13, 8(x9)
    lui  x10, 2
    addi x0, x0, 0
    addi x0, x0, 0
    lh   x14, 4(x10)
    lui  x11, 2
    addi x0, x0, 0
    addi x0, x0, 0
    lbu  x15, 2(x11)
    lui  x12, 3
    addi x0, x0, 0
    addi x0, x0, 0
    lhu  x16, 8(x12)
    lui  x17, 18
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x17, 104(x20)
    lui  x18, 34
    addi x0, x0, 0
    addi x0, x0, 0
    sh   x18, 132(x20)
    lui  x19, 50
    addi x0, x0, 0
    addi x0, x0, 0
    sb   x19, 162(x20)
    lui  x21, 66
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x21, 184(x20)
    # Distance 3: 4x lui -> store_addr, 4x lui -> load_addr, 2x lui -> store_data
    lui  x5, 2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x1, 44(x5)
    lui  x6, 2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sh   x1, 70(x6)
    lui  x7, 2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sb   x1, 83(x7)
    lui  x8, 3
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x1, 12(x8)
    lui  x9, 2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lw   x13, 12(x9)
    lui  x10, 2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lh   x14, 6(x10)
    lui  x11, 2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lbu  x15, 3(x11)
    lui  x12, 3
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lhu  x16, 12(x12)
    lui  x17, 19
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x17, 108(x20)
    lui  x18, 35
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sh   x18, 134(x20)
    lui  x19, 51
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sb   x19, 163(x20)
    lui  x21, 67
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x21, 188(x20)
    # Distance 4: 4x lui -> store_addr, 4x lui -> load_addr, 2x lui -> store_data
    lui  x5, 2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x1, 48(x5)
    lui  x6, 2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sh   x1, 72(x6)
    lui  x7, 2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sb   x1, 84(x7)
    lui  x8, 3
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x1, 16(x8)
    lui  x9, 2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lw   x13, 16(x9)
    lui  x10, 2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lh   x14, 8(x10)
    lui  x11, 2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lbu  x15, 4(x11)
    lui  x12, 3
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lhu  x16, 16(x12)
    lui  x17, 20
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x17, 112(x20)
    lui  x18, 36
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sh   x18, 136(x20)
    lui  x19, 52
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sb   x19, 164(x20)
    lui  x21, 68
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x21, 192(x20)
    ecall
