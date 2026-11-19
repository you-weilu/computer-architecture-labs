# Family a: ALU producer -> ALU consumer on rs2 (distances 0, 1, 2, 3, 4+)
    addi x1, x0, 123
    addi x2, x0, -45
    addi x3, x0, 6
    addi x4, x0, 0x33
    # Distance 0 on rs2
    add x10, x1, x2
    sub x11, x1, x10
    addi x12, x1, -1024
    add x13, x2, x12
    # Distance 1 on rs2
    sub x10, x1, x2
    addi x0, x0, 0
    add x11, x1, x10
    xori x12, x2, 0x123
    addi x0, x0, 0
    sub x13, x2, x12
    # Distance 2 on rs2
    xor x10, x1, x4
    addi x0, x0, 0
    addi x0, x0, 0
    or x11, x1, x10
    slli x12, x3, 5
    addi x0, x0, 0
    addi x0, x0, 0
    slt x13, x2, x12
    # Distance 3 on rs2
    sll x10, x1, x3
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    xor x11, x1, x10
    srli x12, x1, 2
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sltu x13, x2, x12
    # Distance 4 on rs2
    sra x10, x2, x3
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    and x11, x1, x10
    srai x12, x2, 1
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sll x13, x2, x12
    ecall
