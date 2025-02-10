// Custom test 1 - tests basic pipeline functionality with no hazards and manual NOP insertion

lbi r1, 0x1
lbi r2, 0x2
lbi r3, 0x3
nop
addi r4, r1, 0x1
addi r5, r2, 0x2
addi r6, r3, 0x3
halt
