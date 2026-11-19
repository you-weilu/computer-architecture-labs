# Family k: ecall at position 3 after in-flight store, with sh and addi behind it
    lui  x20, 2
    addi x1, x0, 0x123
    sw   x1, 0(x20)
    ecall
    sh   x1, 4(x20)
    addi x3, x1, 5
    ecall
