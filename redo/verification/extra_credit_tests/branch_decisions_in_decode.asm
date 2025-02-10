// Simple test showcasing the benefits of making branch decisions in decode
lbi r1, 0
lbi r2, 5
beqz r2, 4
addi r1, r1, 5
addi r1, r1, 5
add r2, r1, r1
bnez r1, 10
addi r1, r1, 5
addi r1, r1, 5
addi r1, r1, 5
addi r1, r1, 5
addi r1, r1, 5
halt


halt
