# Family f: Store followed by same-width load of the same address (d=0..4+)
    lui  x20, 2
    lui  x1, 0x89abc
    addi x1, x1, -559
    # sw -> lw at distance 0
    addi x2, x1, 0
    sw   x2, 0(x20)
    lw   x3, 0(x20)
    # sh -> lh and lhu at distance 0
    sh   x2, 4(x20)
    lh   x4, 4(x20)
    sh   x2, 6(x20)
    lhu  x5, 6(x20)
    # sb -> lb and lbu at distance 0
    sb   x2, 8(x20)
    lb   x6, 8(x20)
    sb   x2, 9(x20)
    lbu  x7, 9(x20)
    # sw -> lw at distance 1
    addi x2, x1, 1
    sw   x2, 16(x20)
    addi x0, x0, 0
    lw   x3, 16(x20)
    # sh -> lh and lhu at distance 1
    sh   x2, 20(x20)
    addi x0, x0, 0
    lh   x4, 20(x20)
    sh   x2, 22(x20)
    addi x0, x0, 0
    lhu  x5, 22(x20)
    # sb -> lb and lbu at distance 1
    sb   x2, 24(x20)
    addi x0, x0, 0
    lb   x6, 24(x20)
    sb   x2, 25(x20)
    addi x0, x0, 0
    lbu  x7, 25(x20)
    # sw -> lw at distance 2
    addi x2, x1, 2
    sw   x2, 32(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    lw   x3, 32(x20)
    # sh -> lh and lhu at distance 2
    sh   x2, 36(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    lh   x4, 36(x20)
    sh   x2, 38(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    lhu  x5, 38(x20)
    # sb -> lb and lbu at distance 2
    sb   x2, 40(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    lb   x6, 40(x20)
    sb   x2, 41(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    lbu  x7, 41(x20)
    # sw -> lw at distance 3
    addi x2, x1, 3
    sw   x2, 48(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lw   x3, 48(x20)
    # sh -> lh and lhu at distance 3
    sh   x2, 52(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lh   x4, 52(x20)
    sh   x2, 54(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lhu  x5, 54(x20)
    # sb -> lb and lbu at distance 3
    sb   x2, 56(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lb   x6, 56(x20)
    sb   x2, 57(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lbu  x7, 57(x20)
    # sw -> lw at distance 4
    addi x2, x1, 4
    sw   x2, 64(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lw   x3, 64(x20)
    # sh -> lh and lhu at distance 4
    sh   x2, 68(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lh   x4, 68(x20)
    sh   x2, 70(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lhu  x5, 70(x20)
    # sb -> lb and lbu at distance 4
    sb   x2, 72(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lb   x6, 72(x20)
    sb   x2, 73(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lbu  x7, 73(x20)
    ecall
