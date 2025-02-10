module instructiondecoder(opcode, funcode, ALUJmp, MemWrt, InvB, RegSrc, ImmSrc, InvA, Cin, RegWrt, BSrc, ZeroExt, ALUOpr, ConstSel, RegDst, BSel, createDump, enableMem, halt, valid_wb);
    // Instruction decoder module takes instruction[15:11] as the opcode to determine which control signals to enable high or low
    input wire [4:0] opcode;
    input wire [1:0] funcode;    // TESTING ADDING FUNCODE WIRE from INSTRUCTION [1:0]
    input wire valid_wb;

    // Control Signals
    output wire ALUJmp, MemWrt, InvB, ImmSrc, InvA, Cin, RegWrt, ZeroExt, BSel, createDump, enableMem, halt;
    output wire [1:0] BSrc, ConstSel, RegDst, RegSrc;
    output wire [4:0] ALUOpr;
    
    // Based on the opcode, assign appropriate control signals //
    parameter HALT = 5'b00000;
    parameter NOP = 5'b00001;
    parameter ADDI = 5'b01000;
    parameter SUBI = 5'b01001;
    parameter XORI = 5'b01010;
    parameter ANDNI = 5'b01011;
    parameter ROLI = 5'b10100;
    parameter SLLI = 5'b10101;
    parameter RORI = 5'b10110;
    parameter SRLI = 5'b10111;
    parameter ST = 5'b10000;
    parameter LD = 5'b10001;
    parameter STU = 5'b10011;

    parameter BTR = 5'b11001; 
    parameter ADD = 5'b11011;
    parameter SUB = 5'b11011;
    parameter XOR = 5'b11011; 
    parameter ANDN = 5'b11011;
    parameter ROL = 5'b11010;
    parameter SLL = 5'b11010; 
    parameter ROR = 5'b11010;
    parameter SRL = 5'b11010;
    parameter SEQ = 5'b11100;
    parameter SLT = 5'b11101;
    parameter SLE = 5'b11110;
    parameter SCO = 5'b11111;

    parameter BEQZ = 5'b01100;
    parameter BNEZ = 5'b01101;
    parameter BLTZ = 5'b01110;
    parameter BGEZ = 5'b01111;
    parameter LBI = 5'b11000;
    parameter SLBI = 5'b10010;

    parameter J = 5'b00100;
    parameter JR = 5'b00101;
    parameter JAL = 5'b00110;
    parameter JALR = 5'b00111;

    // ALUJmp is 1 when JR or JALR, else 0
    assign ALUJmp = (opcode == JR) ? 1'b1 : 
                    (opcode == JALR) ? 1'b1 :
                    1'b0;

    // MemWrt is 1 only when ST or STU, else 0 or don't care otherwise
    assign MemWrt = (opcode == ST) ? 1'b1 : 
                    (opcode == STU) ? 1'b1 :
                    1'b0;

    // InvB is 1 only when ANDNI or ANDN, else 0 or don't care otherwise
    assign InvB =   (opcode == ANDNI) ? 1'b1 :
                    (opcode == ANDN) ? ((funcode == 2'b11) ? 1'b1 : 1'b0) :
                    1'b0;

    // RegSrc is 1 when LD, 3 if LBI or SLBI, and 2 or don't care otherwise
    assign RegSrc = (opcode == LD) ? 2'b01 :
                    (opcode == LBI) ? 2'b11 : 
                    (opcode == SLBI) ? 2'b11 :
                    (opcode == JAL) ? 2'b00 : 
                    (opcode == JALR) ? 2'b00 : 
                    (opcode == NOP) ? 2'b00 :
                    (opcode == HALT) ? 2'b00 : 
                    2'b10;

    // ImmSrc is 1 when J or JAL, 0 or don't care otherwise
    assign ImmSrc = (opcode == J) ? 1'b1 : 
                    (opcode == JAL) ? 1'b1 : 
                    1'b0;

    // InvA is 1 when SUBI, SUB, SEQ, SLT, or SLE, and 0 or don't care otherwise
    assign InvA =   (opcode == SUBI) ? 1'b1 :
                    (opcode == SUB) ? ((funcode == 2'b01) ? 1'b1 : 1'b0) :
                    (opcode == SEQ) ? 1'b1 : 
                    (opcode == SLT) ? 1'b1 : 
                    (opcode == SLE) ? 1'b1 :  
                    1'b0;

    // Cin is 1 when SUBI, SUB, SEQ, SLT, or SLE, and 0 or don't care otherwise
    assign Cin =    (opcode == SUBI) ? 1'b1 :
                    (opcode == SUB) ? ((funcode == 2'b01) ? 1'b1 : 1'b0) :
                    (opcode == SEQ) ? 1'b1 : 
                    (opcode == SLT) ? 1'b1 : 
                    (opcode == SLE) ? 1'b1 : 
                    1'b0;

    // RegWrt is 0 when ST, BEQZ, BNEZ, BLTZ, BGEZ, J, JR, or NOP, and 1 or don't care otherwise
    assign RegWrt = (opcode == ST) ? 1'b0 :
                    (opcode == BEQZ) ? 1'b0 :
                    (opcode == BNEZ) ? 1'b0 : 
                    (opcode == BLTZ) ? 1'b0 : 
                    (opcode == BGEZ) ? 1'b0 : 
                    (opcode == J) ? 1'b0 :
                    (opcode == JR) ? 1'b0:
                    (opcode == NOP) ? 1'b0 :
                    (opcode == HALT) ? 1'b0 : 
                    1'b1;

    // Brsc is 3 when BEQZ, BNEZ, BLTZ, BGEZ, or SLBI, 2 if LBI, JR, or JALR, 1 if ADDI, SUBI, XORI, ANDNI, ROLI, SLLI, RORI, SRLI, ST, LD, STU, and 0 or don't care otherwise
    assign BSrc =   (opcode == BEQZ) ? 2'b11 : 
                    (opcode == BNEZ) ? 2'b11 : 
                    (opcode == BLTZ) ? 2'b11 : 
                    (opcode == BGEZ) ? 2'b11 : 
                    (opcode == SLBI) ? 2'b11 :
                    (opcode == LBI) ? 2'b10 : 
                    (opcode == JR) ? 2'b10 : 
                    (opcode == JALR) ? 2'b10 :
                    (opcode == ADDI) ? 2'b01 : 
                    (opcode == SUBI) ? 2'b01 : 
                    (opcode == XORI) ? 2'b01 : 
                    (opcode == ANDNI) ? 2'b01 : 
                    (opcode == ROLI) ? 2'b01 : 
                    (opcode == SLLI) ? 2'b01 : 
                    (opcode == RORI) ? 2'b01 :
                    (opcode == SRLI) ? 2'b01 : 
                    (opcode == ST) ? 2'b01 : 
                    (opcode == LD) ? 2'b01 : 
                    (opcode == STU) ? 2'b01 : 
                    2'b00; // Default case to avoid undefined values
    
    // 0Ext is 1 when XORI, ANDNI, ROLI, SLLI, RORI, SRLI, or SLBI, 0 otherwise or don't care
    assign ZeroExt =    (opcode == XORI) ? 1'b1 : 
                        (opcode == ANDNI) ? 1'b1 : 
                        (opcode == ROLI) ? 1'b1 : 
                        (opcode == SLLI) ? 1'b1 : 
                        (opcode == RORI) ? 1'b1 : 
                        (opcode == SRLI) ? 1'b1: 
                        (opcode == SLBI) ? 1'b1: 
                        1'b0;

    // ALUOpr is always the opcode provided from instruction[15:11]
    assign ALUOpr = opcode;

    // ConstSel is 2 for LBI, 3 for SLBI, or 0 for NOP, else don't care so set to 0
    assign ConstSel =   (opcode == LBI) ? 2'b10 : 
                        (opcode == SLBI) ? 2'b11 : 
                        2'b00;

    // RegDst is 3 for JAL and JALR, 2 for BTR, ADD, SUB, XOR, ANDN, ROL, SLL, ROR, SRL, SEQ, SLT, SLE, or SCO, 1 for STU, LBI, SLBI, 0 otherwise or don't care
    assign RegDst = (opcode == JAL) ? 2'b11 : 
                    (opcode == JALR) ? 2'b11 : 
                    (opcode == BTR) ? 2'b10 : 
                    (opcode == ADD) ? 2'b10 : 
                    (opcode == SUB) ? 2'b10 : 
                    (opcode == XOR) ? 2'b10 : 
                    (opcode == ANDN) ? 2'b10 : 
                    (opcode == ROL) ? 2'b10 : 
                    (opcode == SLL) ? 2'b10 : 
                    (opcode == ROR) ? 2'b10 : 
                    (opcode == SRL) ? 2'b10 : 
                    (opcode == SEQ) ? 2'b10 : 
                    (opcode == SLT) ? 2'b10 : 
                    (opcode == SLE) ? 2'b10 : 
                    (opcode == SCO) ? 2'b10 : 
                    (opcode == STU) ? 2'b01 : 
                    (opcode == LBI) ? 2'b01 : 
                    (opcode == SLBI) ? 2'b01 : 
                    2'b00; 

    // BSel is 1 for SLBI, 0/don't care otherwise
    assign BSel = (opcode == SLBI) ? 1'b1 : 1'b0;

    // Memory can produce a dumpfile, use halt to assert createDump for a single cycle
    assign createDump = (opcode == HALT) ? 1'b1 : 1'b0;

    // Memory is only disabled during a NOP instruction, otherwise it should always be enabled
    assign enableMem =  (opcode == LD) ? 1'b1 :
                        (opcode == ST) ? 1'b1 : 
                        (opcode == STU) ? 1'b1 : 
                        1'b0;
    
    // halt is enabled when opcode is HALT
    assign halt = (opcode == HALT) & valid_wb ? 1'b1 : 1'b0;

endmodule