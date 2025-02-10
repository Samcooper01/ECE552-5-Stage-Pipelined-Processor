// Simple BLTZ test after moving to decode resolution
lbi r1, -2
lbi r2, 0
nop
nop
nop
nop

// R3 <- -2
add r3, r1, r2
nop
nop
nop
nop

lbi r4, 5
nop
nop
nop
nop

// Should not take the branch
bltz r4, 2
// Should take the branch to the add
bltz r3, 4
nop
halt
add r5, r1, r2
halt