// This test is for basic functionality of the jalr instruction after being moved to decode
lbi r1, 2
lbi r3, 4
// should jump to PC=0x000a
// skip the 2 add instructions
jalr r1, 8 
nop
add r3, r1, r3
halt