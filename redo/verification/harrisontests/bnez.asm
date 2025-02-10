// Simple test for the BNEZ instruction after moving to decode resolution
lbi r1, 1
lbi r2, 0
nop
nop
nop
nop
// This should branch to the next branch
bnez r2, 8
nop
halt
halt
halt
// This should not branch, and the add should be executed
bnez r1, 8
nop
add r3, r1, r2
halt
halt
halt

