# Family a: ALU producer -> both operands and duplicate operand (rs1 == rs2)
    addi x1, x0, 25
    addi x2, x0, -7
    addi x3, x0, 11
    # Same register used twice (rs1 == rs2 == x10) at distance 0
    add x10, x1, x3
    add x11, x10, x10
    xor x12, x11, x11
    sub x13, x10, x10
    # Both operands from two consecutive producers (distances 1 and 0)
    addi x14, x1, 9
    sub  x15, x2, x3
    add  x16, x14, x15
    sub  x17, x15, x14
    # Same register used twice (rs1 == rs2 == x10) at distance 1
    add x10, x1, x3
    addi x0, x0, 0
    add x11, x10, x10
    xor x12, x11, x11
    sub x13, x10, x10
    # Both operands from two consecutive producers (distances 2 and 1)
    addi x14, x1, 9
    sub  x15, x2, x3
    addi x0, x0, 0
    add  x16, x14, x15
    sub  x17, x15, x14
    # Same register used twice (rs1 == rs2 == x10) at distance 2
    add x10, x1, x3
    addi x0, x0, 0
    addi x0, x0, 0
    add x11, x10, x10
    xor x12, x11, x11
    sub x13, x10, x10
    # Both operands from two consecutive producers (distances 3 and 2)
    addi x14, x1, 9
    sub  x15, x2, x3
    addi x0, x0, 0
    addi x0, x0, 0
    add  x16, x14, x15
    sub  x17, x15, x14
    # Same register used twice (rs1 == rs2 == x10) at distance 3
    add x10, x1, x3
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add x11, x10, x10
    xor x12, x11, x11
    sub x13, x10, x10
    # Both operands from two consecutive producers (distances 4 and 3)
    addi x14, x1, 9
    sub  x15, x2, x3
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x16, x14, x15
    sub  x17, x15, x14
    # Same register used twice (rs1 == rs2 == x10) at distance 4
    add x10, x1, x3
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add x11, x10, x10
    xor x12, x11, x11
    sub x13, x10, x10
    # Both operands from two consecutive producers (distances 5 and 4)
    addi x14, x1, 9
    sub  x15, x2, x3
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x16, x14, x15
    sub  x17, x15, x14
    # I-type with imm[4:0] == 5 matching previous rd=x5 (must NOT forward x5 into imm)
    addi x5, x0, 999
    addi x6, x1, 5
    addi x7, x6, -1019
    ecall
