// This test is for basic functionality of the jump instruction after being moved to decode
lbi r1, 4    // r1 = 0x04
lbi r2, 2    // r2 = 0x02
lbi r4, 3    // r4 = 0x03
nop
nop
nop
nop
nop

j 10   // pc <- pc + 2 + 10 (should skip halts)

halt
halt
halt
halt
halt


add r5, r2, r4 // r5 = 0x05
add r6, r1, r2 // r6 = 0x06
halt
