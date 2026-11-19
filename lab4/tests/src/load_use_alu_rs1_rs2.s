# Family b: Load producer -> ALU consumer (rs1, rs2, both, duplicate) across d=0..4+
    lui  x20, 2
    addi x1, x0, 105
    addi x2, x0, -37
    addi x3, x0, 0x234
    sw   x1, 0(x20)
    sw   x2, 4(x20)
    sw   x3, 8(x20)
    # Load -> ALU rs1 (distance 0)
    lw   x10, 0(x20)
    addi x11, x10, 13
    # Load -> ALU rs1 R-type (distance 0)
    lw   x10, 4(x20)
    add  x12, x10, x1
    # Load -> ALU rs2 (distance 0)
    lw   x10, 8(x20)
    sub  x13, x1, x10
    # Load -> ALU same register twice (distance 0)
    lw   x10, 0(x20)
    add  x14, x10, x10
    # Two loads -> ALU both operands (distances 1 and 0)
    lw   x15, 0(x20)
    lw   x16, 4(x20)
    add  x17, x15, x16
    # Load -> ALU rs1 (distance 1)
    lw   x10, 0(x20)
    addi x0, x0, 0
    addi x11, x10, 13
    # Load -> ALU rs1 R-type (distance 1)
    lw   x10, 4(x20)
    addi x0, x0, 0
    add  x12, x10, x1
    # Load -> ALU rs2 (distance 1)
    lw   x10, 8(x20)
    addi x0, x0, 0
    sub  x13, x1, x10
    # Load -> ALU same register twice (distance 1)
    lw   x10, 0(x20)
    addi x0, x0, 0
    add  x14, x10, x10
    # Two loads -> ALU both operands (distances 2 and 1)
    lw   x15, 0(x20)
    lw   x16, 4(x20)
    addi x0, x0, 0
    add  x17, x15, x16
    # Load -> ALU rs1 (distance 2)
    lw   x10, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 13
    # Load -> ALU rs1 R-type (distance 2)
    lw   x10, 4(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    add  x12, x10, x1
    # Load -> ALU rs2 (distance 2)
    lw   x10, 8(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    sub  x13, x1, x10
    # Load -> ALU same register twice (distance 2)
    lw   x10, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    add  x14, x10, x10
    # Two loads -> ALU both operands (distances 3 and 2)
    lw   x15, 0(x20)
    lw   x16, 4(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    add  x17, x15, x16
    # Load -> ALU rs1 (distance 3)
    lw   x10, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 13
    # Load -> ALU rs1 R-type (distance 3)
    lw   x10, 4(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x12, x10, x1
    # Load -> ALU rs2 (distance 3)
    lw   x10, 8(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sub  x13, x1, x10
    # Load -> ALU same register twice (distance 3)
    lw   x10, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x14, x10, x10
    # Two loads -> ALU both operands (distances 4 and 3)
    lw   x15, 0(x20)
    lw   x16, 4(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x17, x15, x16
    # Load -> ALU rs1 (distance 4)
    lw   x10, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x11, x10, 13
    # Load -> ALU rs1 R-type (distance 4)
    lw   x10, 4(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x12, x10, x1
    # Load -> ALU rs2 (distance 4)
    lw   x10, 8(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    sub  x13, x1, x10
    # Load -> ALU same register twice (distance 4)
    lw   x10, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x14, x10, x10
    # Two loads -> ALU both operands (distances 5 and 4)
    lw   x15, 0(x20)
    lw   x16, 4(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    add  x17, x15, x16
    ecall
