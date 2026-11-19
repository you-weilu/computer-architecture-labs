# Family g: Non-zero writes to x0 followed by x0 consumers at distances 0, 1, 2, 3, 4+
    lui  x20, 2
    addi x1, x0, 77
    addi x2, x0, 99
    sw   x1, 0(x20)
    # addi  x0, x1, 123 -> x0 consumers at distance 0
    addi  x0, x1, 123
    add  x3, x0, x1
    addi  x0, x1, 123
    add  x4, x1, x0
    # lw    x0, 0(x20) -> x0 consumers at distance 0
    lw    x0, 0(x20)
    add  x4, x1, x0
    lw    x0, 0(x20)
    add  x5, x0, x0
    # add   x0, x1, x2 -> x0 consumers at distance 0
    add   x0, x1, x2
    add  x5, x0, x0
    add   x0, x1, x2
    addi x6, x0, 42
    # lui   x0, 0x12345 -> x0 consumers at distance 0
    lui   x0, 0x12345
    addi x6, x0, 42
    lui   x0, 0x12345
    sw   x0, 4(x20)
    # auipc x0, 1 -> x0 consumers at distance 0
    auipc x0, 1
    sw   x0, 4(x20)
    auipc x0, 1
    add  x3, x0, x1
    lw   x7, 4(x20)
    # addi  x0, x1, 123 -> x0 consumers at distance 1
    addi  x0, x1, 123
    addi x0, x0, 0
    add  x4, x1, x0
    addi  x0, x1, 123
    addi x0, x0, 0
    add  x5, x0, x0
    # lw    x0, 0(x20) -> x0 consumers at distance 1
    lw    x0, 0(x20)
    addi x0, x0, 0
    add  x5, x0, x0
    lw    x0, 0(x20)
    addi x0, x0, 0
    addi x6, x0, 42
    # add   x0, x1, x2 -> x0 consumers at distance 1
    add   x0, x1, x2
    addi x0, x0, 0
    addi x6, x0, 42
    add   x0, x1, x2
    addi x0, x0, 0
    sw   x0, 4(x20)
    # lui   x0, 0x12345 -> x0 consumers at distance 1
    lui   x0, 0x12345
    addi x0, x0, 0
    sw   x0, 4(x20)
    lui   x0, 0x12345
    addi x0, x0, 0
    add  x3, x0, x1
    # auipc x0, 1 -> x0 consumers at distance 1
    auipc x0, 1
    addi x0, x0, 0
    add  x3, x0, x1
    auipc x0, 1
    addi x0, x0, 0
    add  x4, x1, x0
    lw   x7, 4(x20)
    # addi  x0, x1, 123 -> x0 consumers at distance 2
    addi  x0, x1, 123
    addi x0, x0, 0
    addi x0, x0, 0
    add  x5, x0, x0
    addi  x0, x1, 123
    addi x0, x0, 0
    addi x0, x0, 0
    addi x6, x0, 42
    # lw    x0, 0(x20) -> x0 consumers at distance 2
    lw    x0, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x6, x0, 42
    lw    x0, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x0, 4(x20)
    # add   x0, x1, x2 -> x0 consumers at distance 2
    add   x0, x1, x2
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x0, 4(x20)
    add   x0, x1, x2
    addi x0, x0, 0
    addi x0, x0, 0
    add  x3, x0, x1
    # lui   x0, 0x12345 -> x0 consumers at distance 2
    lui   x0, 0x12345
    addi x0, x0, 0
    addi x0, x0, 0
    add  x3, x0, x1
    lui   x0, 0x12345
    addi x0, x0, 0
    addi x0, x0, 0
    add  x4, x1, x0
    # auipc x0, 1 -> x0 consumers at distance 2
    auipc x0, 1
    addi x0, x0, 0
    addi x0, x0, 0
    add  x4, x1, x0
    auipc x0, 1
    addi x0, x0, 0
    addi x0, x0, 0
    add  x5, x0, x0
    lw   x7, 4(x20)
    # addi  x0, x1, 123 -> x0 consumers at distance 3
    addi  x0, x1, 123
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x6, x0, 42
    addi  x0, x1, 123
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x0, 4(x20)
    # lw    x0, 0(x20) -> x0 consumers at distance 3
    lw    x0, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x0, 4(x20)
    lw    x0, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x3, x0, x1
    # add   x0, x1, x2 -> x0 consumers at distance 3
    add   x0, x1, x2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x3, x0, x1
    add   x0, x1, x2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x4, x1, x0
    # lui   x0, 0x12345 -> x0 consumers at distance 3
    lui   x0, 0x12345
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x4, x1, x0
    lui   x0, 0x12345
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x5, x0, x0
    # auipc x0, 1 -> x0 consumers at distance 3
    auipc x0, 1
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x5, x0, x0
    auipc x0, 1
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x6, x0, 42
    lw   x7, 4(x20)
    # addi  x0, x1, 123 -> x0 consumers at distance 4
    addi  x0, x1, 123
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x0, 4(x20)
    addi  x0, x1, 123
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x3, x0, x1
    # lw    x0, 0(x20) -> x0 consumers at distance 4
    lw    x0, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x3, x0, x1
    lw    x0, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x4, x1, x0
    # add   x0, x1, x2 -> x0 consumers at distance 4
    add   x0, x1, x2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x4, x1, x0
    add   x0, x1, x2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x5, x0, x0
    # lui   x0, 0x12345 -> x0 consumers at distance 4
    lui   x0, 0x12345
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x5, x0, x0
    lui   x0, 0x12345
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x6, x0, 42
    # auipc x0, 1 -> x0 consumers at distance 4
    auipc x0, 1
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x6, x0, 42
    auipc x0, 1
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x0, 4(x20)
    lw   x7, 4(x20)
    ecall
