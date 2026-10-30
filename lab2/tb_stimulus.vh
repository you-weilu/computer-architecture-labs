// Auto-generated from test_vectors.csv by csv_to_tb.py -- DO NOT EDIT MANUALLY
doExecute(32'd1, "ADD ", 3'h0, 7'h00, 32'h00000005, 32'h00000003); // Line 3: 101 + 011 = 1000
doExecute(32'd2, "ADD ", 3'h0, 7'h00, 32'h7fffffff, 32'h00000001); // Line 4: Positive overflow boundary check
doExecute(32'd3, "ADD ", 3'h0, 7'h00, 32'h80000000, 32'hffffffff); // Line 5: Negative underflow boundary check
doExecute(32'd4, "ADD ", 3'h0, 7'h00, 32'h80000000, 32'h80000000); // Line 6: Carry out discarded
doExecute(32'd5, "ADD ", 3'h0, 7'h00, 32'hffffffff, 32'h00000001); // Line 7: Carry chain check
doExecute(32'd6, "ADD ", 3'h0, 7'h00, 32'h00000000, 32'h00000000); // Line 8: zeros
doExecute(32'd7, "ADD ", 3'h0, 7'h00, 32'h55555555, 32'haaaaaaaa); // Line 9: all ones
doExecute(32'd8, "SUB ", 3'h0, 7'h20, 32'h00000008, 32'h00000003); // Line 10: 1000 - 011 = 101
doExecute(32'd9, "SUB ", 3'h0, 7'h20, 32'h80000000, 32'h00000001); // Line 11: Negative underflow boundary check
doExecute(32'd10, "SUB ", 3'h0, 7'h20, 32'h7fffffff, 32'hffffffff); // Line 12: Positive overflow boundary check
doExecute(32'd11, "SUB ", 3'h0, 7'h20, 32'h00000000, 32'h00000001); // Line 13: Borrows from beyond top bit then discards
doExecute(32'd12, "SUB ", 3'h0, 7'h20, 32'hffffffff, 32'hffffffff); // Line 14: all zeroes
doExecute(32'd13, "SLT ", 3'h2, 7'h00, 32'hffffffff, 32'h00000001); // Line 15: Signed comparison across zero boundary (-1 < 1)
doExecute(32'd14, "SLT ", 3'h2, 7'h00, 32'h00000001, 32'hffffffff); // Line 16: 1 < -1 (false)
doExecute(32'd15, "SLT ", 3'h2, 7'h00, 32'h80000000, 32'h00000001); // Line 17: A - B overflows (most negative - 1)
doExecute(32'd16, "SLT ", 3'h2, 7'h00, 32'h7fffffff, 32'hffffffff); // Line 18: A - B overflow (most positive - (-1))
doExecute(32'd17, "SLT ", 3'h2, 7'h00, 32'h55555555, 32'h55555555); // Line 19: Equal
doExecute(32'd18, "SLT ", 3'h2, 7'h00, 32'h00000003, 32'h00000004); // Line 20: 3 < 4 (true)
doExecute(32'd19, "SLTU", 3'h3, 7'h00, 32'hffffffff, 32'h00000001); // Line 21: Unsigned comparison across zero boundary (4294967295 > 1)
doExecute(32'd20, "SLTU", 3'h3, 7'h00, 32'h00000001, 32'hffffffff); // Line 22: 1 < max unsigned
doExecute(32'd21, "SLTU", 3'h3, 7'h00, 32'h80000000, 32'h00000001); // Line 23: MSB set vs small value
doExecute(32'd22, "SLTU", 3'h3, 7'h00, 32'h7fffffff, 32'hffffffff); // Line 24: Comparison across MSB boundary
doExecute(32'd23, "SLTU", 3'h3, 7'h00, 32'hfffffffe, 32'hffffffff); // Line 25: Differs in LSB
doExecute(32'd24, "SLTU", 3'h3, 7'h00, 32'h55555555, 32'h55555555); // Line 26: Equal
doExecute(32'd25, "SLTU", 3'h3, 7'h00, 32'h00000003, 32'h00000004); // Line 27: 3 < 4 (true)
doExecute(32'd26, "SRA ", 3'h5, 7'h20, 32'hdeadbeef, 32'h00000001); // Line 28: Shift 1 sign fill (0xEF56DF77)
doExecute(32'd27, "SRA ", 3'h5, 7'h20, 32'hdeadbeef, 32'h00000002); // Line 29: Shift 2 sign fill (0xF7AB6FBB)
doExecute(32'd28, "SRA ", 3'h5, 7'h20, 32'hdeadbeef, 32'h00000004); // Line 30: Shift 4 sign fill (0xFDEADBEE)
doExecute(32'd29, "SRA ", 3'h5, 7'h20, 32'hdeadbeef, 32'h00000008); // Line 31: Shift 8 sign fill (0xFFDEADBE)
doExecute(32'd30, "SRA ", 3'h5, 7'h20, 32'hdeadbeef, 32'h00000010); // Line 32: Shift 16 sign fill (0xFFFFDEAD)
doExecute(32'd31, "SRA ", 3'h5, 7'h20, 32'h7fffffff, 32'h00000001); // Line 33: Positive input fills with 0 (0x3FFFFFFF)
doExecute(32'd32, "SRA ", 3'h5, 7'h20, 32'h80000000, 32'h0000001f); // Line 34: Shift by 31 fills all sign bits (all ones)
doExecute(32'd33, "SRA ", 3'h5, 7'h20, 32'hffffffff, 32'h00000001); // Line 35: All ones stays all ones
doExecute(32'd34, "SRA ", 3'h5, 7'h20, 32'h00000001, 32'h00000000); // Line 36: Shift by 0 (no change)
doExecute(32'd35, "SRA ", 3'h5, 7'h20, 32'h80000000, 32'h00000020); // Line 37: Lower 5 bits of 32 = 0 (no change)
doExecute(32'd36, "SLL ", 3'h1, 7'h00, 32'hdeadbeef, 32'h00000001); // Line 38: Shift 1 (0xBD5B7DDE)
doExecute(32'd37, "SLL ", 3'h1, 7'h00, 32'hdeadbeef, 32'h00000002); // Line 39: Shift 2 (0x7AB6FBBC)
doExecute(32'd38, "SLL ", 3'h1, 7'h00, 32'hdeadbeef, 32'h00000004); // Line 40: Shift 4 (0xEADBEEF0)
doExecute(32'd39, "SLL ", 3'h1, 7'h00, 32'hdeadbeef, 32'h00000008); // Line 41: Shift 8 (0xADBEEF00)
doExecute(32'd40, "SLL ", 3'h1, 7'h00, 32'hdeadbeef, 32'h00000010); // Line 42: Shift 16 (0xBEEF0000)
doExecute(32'd41, "SLL ", 3'h1, 7'h00, 32'h00000001, 32'h00000020); // Line 43: Shift amount uses only lower 5 bits (shamt=32 wraps to 0)
doExecute(32'd42, "SLL ", 3'h1, 7'h00, 32'h00000001, 32'h0000001f); // Line 44: Shift 1 left by 31 (0x80000000)
doExecute(32'd43, "SLL ", 3'h1, 7'h00, 32'hffffffff, 32'h00000001); // Line 45: Shift all ones left by 1 drops MSB
doExecute(32'd44, "SLL ", 3'h1, 7'h00, 32'h00000001, 32'h00000000); // Line 46: Shift by 0
doExecute(32'd45, "SLL ", 3'h1, 7'h00, 32'h55555555, 32'h00000001); // Line 47: Alternating pattern shifted left by 1
doExecute(32'd46, "SRL ", 3'h5, 7'h00, 32'hdeadbeef, 32'h00000001); // Line 48: Shift 1 zero fill (0x6F56DF77)
doExecute(32'd47, "SRL ", 3'h5, 7'h00, 32'hdeadbeef, 32'h00000002); // Line 49: Shift 2 zero fill (0x37AB6FBB)
doExecute(32'd48, "SRL ", 3'h5, 7'h00, 32'hdeadbeef, 32'h00000004); // Line 50: Shift 4 zero fill (0x0DEADBEE)
doExecute(32'd49, "SRL ", 3'h5, 7'h00, 32'hdeadbeef, 32'h00000008); // Line 51: Shift 8 zero fill (0x00DEADBE)
doExecute(32'd50, "SRL ", 3'h5, 7'h00, 32'hdeadbeef, 32'h00000010); // Line 52: Shift 16 zero fill (0x0000DEAD)
doExecute(32'd51, "SRL ", 3'h5, 7'h00, 32'h80000000, 32'h0000001f); // Line 53: Logical shift 0x80000000 right 31 gives 1
doExecute(32'd52, "SRL ", 3'h5, 7'h00, 32'hffffffff, 32'h00000001); // Line 54: All ones logical right shift inserts 0 at MSB
doExecute(32'd53, "SRL ", 3'h5, 7'h00, 32'h00000001, 32'h00000001); // Line 55: Shift 1 right by 1
doExecute(32'd54, "SRL ", 3'h5, 7'h00, 32'h00000001, 32'h00000000); // Line 56: Shift by 0
doExecute(32'd55, "SRL ", 3'h5, 7'h00, 32'h00000001, 32'h00000020); // Line 57: Lower 5 bits of 32 --> 0
doExecute(32'd56, "XOR ", 3'h4, 7'h00, 32'hffffffff, 32'hffffffff); // Line 58: All ones XOR all ones --> 0
doExecute(32'd57, "XOR ", 3'h4, 7'h00, 32'h00000000, 32'hffffffff); // Line 59: Zero XOR all ones --> all ones
doExecute(32'd58, "XOR ", 3'h4, 7'h00, 32'hffffffff, 32'h00000000); // Line 60: All ones XOR zero --> all ones
doExecute(32'd59, "XOR ", 3'h4, 7'h00, 32'h55555555, 32'haaaaaaaa); // Line 61: XOR Alternating bits --> all ones
doExecute(32'd60, "XOR ", 3'h4, 7'h00, 32'hdeadbeef, 32'h00000000); // Line 62: XOR with 0
doExecute(32'd61, "XOR ", 3'h4, 7'h00, 32'hdeadbeef, 32'hdeadbeef); // Line 63: XOR with self
doExecute(32'd62, "XOR ", 3'h4, 7'h00, 32'h00000000, 32'h00000000); // Line 64: Zero XOR zero = 0
doExecute(32'd63, "XOR ", 3'h4, 7'h00, 32'hdeadbeef, 32'h0f0f0f0f); // Line 65: Random Pattern (0xD1A2B1E0)
doExecute(32'd64, "OR  ", 3'h6, 7'h00, 32'h00000000, 32'h00000000); // Line 66: Zero OR zero = 0
doExecute(32'd65, "OR  ", 3'h6, 7'h00, 32'hffffffff, 32'h00000000); // Line 67: OR with 0
doExecute(32'd66, "OR  ", 3'h6, 7'h00, 32'h55555555, 32'haaaaaaaa); // Line 68: Alternating bits --> All ones
doExecute(32'd67, "OR  ", 3'h6, 7'h00, 32'h00000000, 32'hffffffff); // Line 69: Zero OR all ones --> all ones
doExecute(32'd68, "OR  ", 3'h6, 7'h00, 32'hffffffff, 32'hffffffff); // Line 70: All ones OR all ones --> all ones
doExecute(32'd69, "OR  ", 3'h6, 7'h00, 32'h55555555, 32'h55555555); // Line 71: OR with itself --> itself
doExecute(32'd70, "OR  ", 3'h6, 7'h00, 32'h80000000, 32'h7fffffff); // Line 72: MSB and lower bits combined = all ones
doExecute(32'd71, "OR  ", 3'h6, 7'h00, 32'hdeadbeef, 32'h0f0f0f0f); // Line 73: Random Pattern (0xDFAFBFEF)
doExecute(32'd72, "AND ", 3'h7, 7'h00, 32'hffffffff, 32'hffffffff); // Line 74: All ones AND all ones = all ones
doExecute(32'd73, "AND ", 3'h7, 7'h00, 32'h00000000, 32'hffffffff); // Line 75: Zero AND all ones --> zeroes
doExecute(32'd74, "AND ", 3'h7, 7'h00, 32'hffffffff, 32'h00000000); // Line 76: All ones AND zero --> zeroes
doExecute(32'd75, "AND ", 3'h7, 7'h00, 32'h00000000, 32'h00000000); // Line 77: Zero AND zero --> zeroes
doExecute(32'd76, "AND ", 3'h7, 7'h00, 32'h55555555, 32'haaaaaaaa); // Line 78: Alternating bits --> zeroes
doExecute(32'd77, "AND ", 3'h7, 7'h00, 32'hdeadbeef, 32'hffffffff); // Line 79: AND with all ones --> itself
doExecute(32'd78, "AND ", 3'h7, 7'h00, 32'h55555555, 32'h55555555); // Line 80: AND itself --> itself
doExecute(32'd79, "AND ", 3'h7, 7'h00, 32'hdeadbeef, 32'h0f0f0f0f); // Line 81: Random pattern (0x0E0D0E0F)
