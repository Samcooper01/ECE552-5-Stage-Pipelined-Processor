// This test is for basic functionality of the jal instruction after being moved to decode
lbi r1, 0x04    // r1 = 0x04
lbi r2, 0x02    // r2 = 0x02
lbi r4, 0x03    // r4 = 0x03
nop
nop
nop
nop
nop

jal 0x4   // pc <- pc + 2 + 4 (should skip halts)
nop
halt
nop
add r5, r2, r4 // r5 = 0x05
halt