// Simple BEQZ test after moving to decode resolution
lbi r1, 0
lbi r2, 0
nop
nop
nop
nop
// This should branch to the second branch 
beqz r2, 4  
nop
halt
// This should branch to the add
beqz r1, 4
nop
halt 
add r3, r1, r2
// Branch should not be taken and halt should be 
beqz r3, 8
nop
halt
