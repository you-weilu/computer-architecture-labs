# Family f: Overlapping store/load widths, triples, and 4x sb -> lw
    lui  x20, 2
    lui  x1, 0xa5b6c
    addi x1, x1, 0x7d8
    # 1. sw then lb/lbu at each byte offset 0, 1, 2, 3 and lh/lhu at 0, 2
    sw   x1, 0(x20)
    lb   x2, 0(x20)
    lb   x3, 1(x20)
    lb   x4, 2(x20)
    lb   x5, 3(x20)
    lbu  x6, 0(x20)
    lbu  x7, 1(x20)
    lbu  x8, 2(x20)
    lbu  x9, 3(x20)
    lh   x10, 0(x20)
    lh   x11, 2(x20)
    lhu  x12, 0(x20)
    lhu  x13, 2(x20)
    # 2. sb at each byte offset then lw; sh then lhu and lw
    addi x14, x0, 0x5a
    sb   x14, 1(x20)
    lw   x15, 0(x20)
    addi x16, x0, -17
    sh   x16, 2(x20)
    lhu  x17, 2(x20)
    lw   x18, 0(x20)
    # 3. (load, store, load) triple to SAME address
    lw   x2, 0(x20)
    addi x3, x2, 9
    sw   x3, 0(x20)
    lw   x4, 0(x20)
    # 4. (load, store, load) triple to DIFFERENT addresses
    lw   x5, 0(x20)
    sw   x5, 16(x20)
    lw   x6, 0(x20)
    # 5. (store, load, store) triple to SAME address
    addi x7, x0, 0x123
    sw   x7, 8(x20)
    lw   x8, 8(x20)
    addi x9, x8, 1
    sw   x9, 8(x20)
    lw   x10, 8(x20)
    # 6. (store, load, store) triple to DIFFERENT addresses
    sw   x7, 12(x20)
    lw   x11, 8(x20)
    sw   x11, 16(x20)
    lw   x12, 16(x20)
    # 7. Back-to-back stores to 4 adjacent bytes then a word load
    addi x2, x0, 0xef
    addi x3, x0, 0xbe
    addi x4, x0, 0xad
    addi x5, x0, 0xde
    sb   x2, 24(x20)
    sb   x3, 25(x20)
    sb   x4, 26(x20)
    sb   x5, 27(x20)
    lw   x6, 24(x20)
    addi x7, x6, 1
    ecall
