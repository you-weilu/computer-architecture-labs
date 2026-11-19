# Family b: Pointer-chasing load -> load-address consumer across distances 0, 1, 2, 3, 4+
    lui  x20, 2
    addi x21, x20, 32
    addi x22, x20, 64
    addi x23, x20, 96
    addi x24, x20, 128
    lui  x1, 0x13579
    addi x1, x1, 0x246
    lui  x2, 0xfedcb
    addi x2, x2, -109
    sw   x21, 0(x20)
    sw   x22, 4(x20)
    sw   x23, 8(x20)
    sw   x22, 0(x21)
    sw   x23, 4(x21)
    sw   x24, 0(x22)
    sw   x21, 0(x23)
    sw   x1,  8(x22)
    sw   x2,  12(x22)
    sw   x1,  8(x23)
    sw   x2,  4(x24)
    sw   x1,  8(x24)
    # 3-hop pointer chase #1 at distance 0 (2x load->load_addr)
    lw   x5, 0(x20)
    lw   x6, 0(x5)
    lw   x7, 8(x6)
    # 3-hop pointer chase #2 at distance 0 (2x load->load_addr)
    lw   x14, 4(x20)
    lw   x15, 0(x14)
    lw   x16, 4(x15)
    # 3-hop pointer chase #3 at distance 0 with lhu pointer (2x load->load_addr)
    lhu  x17, 0(x20)
    lw   x18, 4(x17)
    lhu  x19, 8(x18)
    # 3-hop pointer chase #1 at distance 1 (2x load->load_addr)
    lw   x8, 0(x20)
    addi x0, x0, 0
    lw   x9, 0(x8)
    addi x0, x0, 0
    lh   x10, 10(x9)
    # 3-hop pointer chase #2 at distance 1 (2x load->load_addr)
    lw   x14, 4(x20)
    addi x0, x0, 0
    lw   x15, 0(x14)
    addi x0, x0, 0
    lw   x16, 4(x15)
    # 3-hop pointer chase #3 at distance 1 with lhu pointer (2x load->load_addr)
    lhu  x17, 0(x20)
    addi x0, x0, 0
    lw   x18, 4(x17)
    addi x0, x0, 0
    lb   x19, 5(x18)
    # 3-hop pointer chase #1 at distance 2 (2x load->load_addr)
    lw   x11, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    lw   x12, 0(x11)
    addi x0, x0, 0
    addi x0, x0, 0
    lhu  x13, 12(x12)
    # 3-hop pointer chase #2 at distance 2 (2x load->load_addr)
    lw   x14, 4(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    lw   x15, 0(x14)
    addi x0, x0, 0
    addi x0, x0, 0
    lw   x16, 4(x15)
    # 3-hop pointer chase #3 at distance 2 with lhu pointer (2x load->load_addr)
    lhu  x17, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    lw   x18, 4(x17)
    addi x0, x0, 0
    addi x0, x0, 0
    lbu  x19, 7(x18)
    # 3-hop pointer chase #1 at distance 3 (2x load->load_addr)
    lw   x5, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lw   x6, 0(x5)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lb   x7, 9(x6)
    # 3-hop pointer chase #2 at distance 3 (2x load->load_addr)
    lw   x14, 4(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lw   x15, 0(x14)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lw   x16, 4(x15)
    # 3-hop pointer chase #3 at distance 3 with lhu pointer (2x load->load_addr)
    lhu  x17, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lw   x18, 4(x17)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lw   x19, 4(x18)
    # 3-hop pointer chase #1 at distance 4 (2x load->load_addr)
    lw   x8, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lw   x9, 0(x8)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lbu  x10, 11(x9)
    # 3-hop pointer chase #2 at distance 4 (2x load->load_addr)
    lw   x14, 4(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lw   x15, 0(x14)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lw   x16, 4(x15)
    # 3-hop pointer chase #3 at distance 4 with lhu pointer (2x load->load_addr)
    lhu  x17, 0(x20)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lw   x18, 4(x17)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    lh   x19, 6(x18)
    ecall
