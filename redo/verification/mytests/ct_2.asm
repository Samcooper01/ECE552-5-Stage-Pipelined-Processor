// Custom test 2 - tests basic pipeline functionality with a couple hazards and easily resolvable NOP insertion

lbi r1, 2	//load 100 into r1
lbi r2, 4
nop
nop
nop
nop
LD r3, r2, 0x4
ST r3, r2, 0x1      //store r3 into MEM[r2 + 0x1]
ADD r3, r2, r1
ADD r3, r2, r1
ADD r3, r2, r1
halt