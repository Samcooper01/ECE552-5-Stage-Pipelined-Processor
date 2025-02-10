lbi r1, 1
lbi r2, 2
lbi r3, 3
lbi r4, 4
lbi r5, 5
beqz r1, 5
beqz r2, 5
beqz r3, 5
beqz r4, 5
beqz r5, 5
lbi r6, 0
beqz r6, 2
halt
add r1, r2, r3
halt
