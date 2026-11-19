# Family c: lb, lbu, lh, lhu, lw forwarded to consumers (d=0..4+)
    lui  x20, 2
    lui  x1, 0xdeadc
    addi x1, x1, -273
    lui  x2, 0x76543
    addi x2, x2, 0x210
    sw   x1, 0(x20)
    sw   x2, 4(x20)
    lb x10, 0(x20)
    addi x11, x10, 1
    lb x12, 1(x20)
    add  x13, x1, x12
    lb x10, 2(x20)
    addi x11, x10, 1
    lb x12, 3(x20)
    add  x13, x1, x12
    lbu x10, 0(x20)
    addi x11, x10, 1
    lbu x12, 1(x20)
    add  x13, x1, x12
    lbu x10, 2(x20)
    addi x11, x10, 1
    lbu x12, 3(x20)
    add  x13, x1, x12
    lh x10, 0(x20)
    addi x11, x10, 1
    lh x12, 2(x20)
    add  x13, x1, x12
    lhu x10, 0(x20)
    addi x11, x10, 1
    lhu x12, 2(x20)
    add  x13, x1, x12
    lw x10, 0(x20)
    addi x11, x10, 1
    lb x12, 0(x20)
    addi x0, x0, 0
    add  x13, x1, x12
    lb x10, 1(x20)
    addi x0, x0, 0
    addi x11, x10, 1
    lb x12, 2(x20)
    addi x0, x0, 0
    add  x13, x1, x12
    lb x10, 3(x20)
    addi x0, x0, 0
    addi x11, x10, 1
    lbu x12, 0(x20)
    addi x0, x0, 0
    add  x13, x1, x12
    lbu x10, 1(x20)
    addi x0, x0, 0
    addi x11, x10, 1
    lbu x12, 2(x20)
    addi x0, x0, 0
    add  x13, x1, x12
    lbu x10, 3(x20)
    addi x0, x0, 0
    addi x11, x10, 1
    lh x12, 0(x20)
    addi x0, x0, 0
    add  x13, x1, x12
    lh x10, 2(x20)
    addi x0, x0, 0
    addi x11, x10, 1
    lhu x12, 0(x20)
    addi x0, x0, 0
    add  x13, x1, x12
    lhu x10, 2(x20)
    addi x0, x0, 0
    addi x11, x10, 1
    lw x12, 0(x20)
    addi x0, x0, 0
    add  x13, x1, x12
    lb x10, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 1
    lb x12, 1(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    add  x13, x1, x12
    lb x10, 2(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 1
    lb x12, 3(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    add  x13, x1, x12
    lbu x10, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 1
    lbu x12, 1(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    add  x13, x1, x12
    lbu x10, 2(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 1
    lbu x12, 3(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    add  x13, x1, x12
    lh x10, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 1
    lh x12, 2(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    add  x13, x1, x12
    lhu x10, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 1
    lhu x12, 2(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    add  x13, x1, x12
    lw x10, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 1
    lb x12, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x13, x1, x12
    lb x10, 1(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 1
    lb x12, 2(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x13, x1, x12
    lb x10, 3(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 1
    lbu x12, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x13, x1, x12
    lbu x10, 1(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 1
    lbu x12, 2(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x13, x1, x12
    lbu x10, 3(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 1
    lh x12, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x13, x1, x12
    lh x10, 2(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 1
    lhu x12, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x13, x1, x12
    lhu x10, 2(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 1
    lw x12, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x13, x1, x12
    lb x10, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 1
    lb x12, 1(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x13, x1, x12
    lb x10, 2(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 1
    lb x12, 3(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x13, x1, x12
    lbu x10, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 1
    lbu x12, 1(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x13, x1, x12
    lbu x10, 2(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 1
    lbu x12, 3(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x13, x1, x12
    lh x10, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 1
    lh x12, 2(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x13, x1, x12
    lhu x10, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 1
    lhu x12, 2(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x13, x1, x12
    lw x10, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 1
    lb x14, 0(x20)
    add  x15, x14, x14
    lb x14, 1(x20)
    add  x15, x14, x14
    lb x14, 2(x20)
    add  x15, x14, x14
    lb x14, 3(x20)
    add  x15, x14, x14
    lbu x14, 0(x20)
    add  x15, x14, x14
    lbu x14, 1(x20)
    add  x15, x14, x14
    ecall
