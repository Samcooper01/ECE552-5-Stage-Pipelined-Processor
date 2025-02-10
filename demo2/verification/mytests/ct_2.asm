// Custom test 2 - tests basic pipeline functionality with a couple hazards and easily resolvable NOP insertion

lbi r1, 0x1
addi r2, r1, 0x1
lbi r2, 0x2
addi r3, r2, 0x1
lbi r3, 0x3
addi r4, r3, 0x1
halt
