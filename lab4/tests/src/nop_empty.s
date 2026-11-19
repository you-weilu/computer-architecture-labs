# NOP-only program followed by ecall (catches ungated fault on reset bubbles)
    addi x0, x0, 0
    addi x0, x0, 0
    ecall
