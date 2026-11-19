# Family a: ALU producer -> ALU consumer on rs1 (distances 0, 1, 2, 3, 4+)
    addi x1, x0, 17
    addi x2, x0, -9
    addi x3, x0, 5
    addi x4, x0, 3
    # Distance 0 (R-type consumer on rs1)
    add x10, x1, x2
    add x11, x10, x3
    # Distance 0 (I-type consumer on rs1)
    xor x12, x1, x2
    xori x13, x12, 0x3f
    # Distance 1 (R-type consumer on rs1)
    sub x10, x1, x2
    addi x0, x0, 0
    add x11, x10, x3
    # Distance 1 (I-type consumer on rs1)
    srl x12, x2, x4
    addi x0, x0, 0
    xori x13, x12, 0x3f
    # Distance 2 (R-type consumer on rs1)
    sll x10, x1, x4
    addi x0, x0, 0
    addi x0, x0, 0
    add x11, x10, x3
    # Distance 2 (I-type consumer on rs1)
    sra x12, x2, x4
    addi x0, x0, 0
    addi x0, x0, 0
    xori x13, x12, 0x3f
    # Distance 3 (R-type consumer on rs1)
    slt x10, x2, x1
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add x11, x10, x3
    # Distance 3 (I-type consumer on rs1)
    or x12, x1, x3
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    xori x13, x12, 0x3f
    # Distance 4 (R-type consumer on rs1)
    sltu x10, x1, x2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add x11, x10, x3
    # Distance 4 (I-type consumer on rs1)
    and x12, x1, x2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    xori x13, x12, 0x3f
    add x14, x1, x2
    addi x15, x14, 7
    sub x1, x15, x4
    sub x14, x1, x2
    addi x15, x14, 7
    sub x1, x15, x4
    sll x14, x1, x4
    addi x15, x14, 7
    sub x1, x15, x4
    slt x14, x2, x1
    addi x15, x14, 7
    sub x1, x15, x4
    sltu x14, x1, x2
    addi x15, x14, 7
    sub x1, x15, x4
    xor x14, x1, x2
    addi x15, x14, 7
    sub x1, x15, x4
    srl x14, x2, x4
    addi x15, x14, 7
    sub x1, x15, x4
    sra x14, x2, x4
    addi x15, x14, 7
    sub x1, x15, x4
    or x14, x1, x3
    addi x15, x14, 7
    sub x1, x15, x4
    and x14, x1, x2
    addi x15, x14, 7
    sub x1, x15, x4
    addi x14, x1, -1024
    addi x15, x14, 7
    sub x1, x15, x4
    slti x14, x2, -5
    addi x15, x14, 7
    sub x1, x15, x4
    sltiu x14, x2, 20
    addi x15, x14, 7
    sub x1, x15, x4
    xori x14, x1, 0x155
    addi x15, x14, 7
    sub x1, x15, x4
    ori x14, x3, 0x2aa
    addi x15, x14, 7
    sub x1, x15, x4
    andi x14, x1, 0x0ff
    addi x15, x14, 7
    sub x1, x15, x4
    slli x14, x3, 4
    addi x15, x14, 7
    sub x1, x15, x4
    srli x14, x2, 2
    addi x15, x14, 7
    sub x1, x15, x4
    srai x14, x2, 3
    addi x15, x14, 7
    sub x1, x15, x4
    ecall
