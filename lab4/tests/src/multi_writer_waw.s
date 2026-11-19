# Family h: 2 or 3 writers of the same register in flight -> reader at d=0..4+
    lui  x20, 2
    addi x1, x0, 10
    addi x2, x0, 20
    addi x3, x0, 30
    addi x4, x0, 99
    sw   x4, 0(x20)
    # 2 ALU writers to x10 -> read at distance 0
    addi x10, x1, 1
    addi x10, x2, 2
    add  x11, x10, x1
    add  x12, x1, x10
    # 3 ALU writers to x10 -> read at distance 0
    addi x10, x1, 5
    addi x10, x2, 6
    addi x10, x3, 7
    add  x13, x10, x10
    # Load followed by independent ALU op writing same x10 -> read at distance 0
    lw   x10, 0(x20)
    addi x10, x3, 15
    add  x14, x10, x2
    # ALU op followed by Load writing same x10 -> read at distance 0
    addi x10, x1, 7
    lw   x10, 0(x20)
    add  x15, x10, x3
    # 2 ALU writers to x10 -> read at distance 1
    addi x10, x1, 1
    addi x10, x2, 2
    addi x0, x0, 0
    add  x11, x10, x1
    add  x12, x1, x10
    # 3 ALU writers to x10 -> read at distance 1
    addi x10, x1, 5
    addi x10, x2, 6
    addi x10, x3, 7
    addi x0, x0, 0
    add  x13, x10, x10
    # Load followed by independent ALU op writing same x10 -> read at distance 1
    lw   x10, 0(x20)
    addi x10, x3, 15
    addi x0, x0, 0
    add  x14, x10, x2
    # ALU op followed by Load writing same x10 -> read at distance 1
    addi x10, x1, 7
    lw   x10, 0(x20)
    addi x0, x0, 0
    add  x15, x10, x3
    # 2 ALU writers to x10 -> read at distance 2
    addi x10, x1, 1
    addi x10, x2, 2
    addi x0, x0, 0
    addi x0, x0, 0
    add  x11, x10, x1
    add  x12, x1, x10
    # 3 ALU writers to x10 -> read at distance 2
    addi x10, x1, 5
    addi x10, x2, 6
    addi x10, x3, 7
    addi x0, x0, 0
    addi x0, x0, 0
    add  x13, x10, x10
    # Load followed by independent ALU op writing same x10 -> read at distance 2
    lw   x10, 0(x20)
    addi x10, x3, 15
    addi x0, x0, 0
    addi x0, x0, 0
    add  x14, x10, x2
    # ALU op followed by Load writing same x10 -> read at distance 2
    addi x10, x1, 7
    lw   x10, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    add  x15, x10, x3
    # 2 ALU writers to x10 -> read at distance 3
    addi x10, x1, 1
    addi x10, x2, 2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x11, x10, x1
    add  x12, x1, x10
    # 3 ALU writers to x10 -> read at distance 3
    addi x10, x1, 5
    addi x10, x2, 6
    addi x10, x3, 7
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x13, x10, x10
    # Load followed by independent ALU op writing same x10 -> read at distance 3
    lw   x10, 0(x20)
    addi x10, x3, 15
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x14, x10, x2
    # ALU op followed by Load writing same x10 -> read at distance 3
    addi x10, x1, 7
    lw   x10, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x15, x10, x3
    # 2 ALU writers to x10 -> read at distance 4
    addi x10, x1, 1
    addi x10, x2, 2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x11, x10, x1
    add  x12, x1, x10
    # 3 ALU writers to x10 -> read at distance 4
    addi x10, x1, 5
    addi x10, x2, 6
    addi x10, x3, 7
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x13, x10, x10
    # Load followed by independent ALU op writing same x10 -> read at distance 4
    lw   x10, 0(x20)
    addi x10, x3, 15
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x14, x10, x2
    # ALU op followed by Load writing same x10 -> read at distance 4
    addi x10, x1, 7
    lw   x10, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x15, x10, x3
    ecall
