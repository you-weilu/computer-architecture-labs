# Family k: Illegal mul directly after lw of its operand (load-use stall context), with sw + addi behind it
    lui  x20, 2
    addi x1, x0, 63
    sw   x1, 0(x20)
    lw   x2, 0(x20)
    .word 0x022101b3
    sw   x1, 4(x20)
    addi x4, x2, 10
    ecall
