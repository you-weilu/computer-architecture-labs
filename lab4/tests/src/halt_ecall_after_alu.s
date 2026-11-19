# Family k: ecall immediately after in-flight ALU ops
    addi x1, x0, 15
    addi x2, x0, 27
    add  x3, x1, x2
    sub  x4, x3, x1
    ecall
    addi x5, x0, 99
