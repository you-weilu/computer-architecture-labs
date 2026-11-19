# Family i: Distance-2 and Distance-3 dependences (WB->ID bypass with ALU and Load producers)
    lui  x20, 2
    addi x1, x0, -42
    addi x2, x0, 0x123
    sw   x1, 0(x20)
    sw   x2, 4(x20)
    # ALU producer at distance 2 (rs1, rs2, both, store data)
    add  x10, x1, x2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 5
    sub  x12, x2, x1
    addi x0, x0, 0
    addi x0, x0, 0
    add  x13, x1, x12
    xor  x14, x1, x2
    addi x0, x0, 0
    addi x0, x0, 0
    add  x15, x14, x14
    addi x16, x2, 19
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x16, 8(x20)
    lw   x17, 8(x20)
    # Load producer (lw, lh, lb) at distance 2 (must forward post-mux load data, not ALU addr!)
    lw   x10, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    add  x11, x10, x2
    lh   x12, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    sub  x13, x2, x12
    lb   x14, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    add  x15, x14, x14
    # ALU producer at distance 3 (rs1, rs2, both, store data)
    add  x10, x1, x2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 5
    sub  x12, x2, x1
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x13, x1, x12
    xor  x14, x1, x2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x15, x14, x14
    addi x16, x2, 19
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x16, 8(x20)
    lw   x17, 8(x20)
    # Load producer (lw, lh, lb) at distance 3 (must forward post-mux load data, not ALU addr!)
    lw   x10, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x11, x10, x2
    lh   x12, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sub  x13, x2, x12
    lb   x14, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x15, x14, x14
    ecall
