//This module takes the instruction opcode and func bits are inputs
//and outputs the appropriate ALU_mode to the ALU
//refer to ALU_operations excel sheet for mappings
module ALU_operation(opcode, func, ALU_mode);
    input [4:0] opcode;
    input [1:0] func;

    output [3:0] ALU_mode;

    //These are in order from top to bottom
    parameter   ADDI =  5'b01000,
                SUBI =  5'b01001,
                XORI =  5'b01010,
                ANDNI = 5'b01011,
                ROLI =  5'b10100,
                SLLI =  5'b10101,
                RORI =  5'b10110,
                SRLI =  5'b10111,
                ST =    5'b10000,
                LD =    5'b10001,
                STU =   5'b10011,
                BTR =   5'b11001,
                ADD =   5'b11011,
                SUB =   5'b11011,
                XOR =   5'b11011,
                ANDN =  5'b11011,
                ROL =   5'b11010,
                SLL =   5'b11010,
                ROR =   5'b11010,
                SRL =   5'b11010,
                SEQ =   5'b11100,
                SLT =   5'b11101,
                SLE =   5'b11110,
                SCO =   5'b11111,
                BEQZ =  5'b01100,
                BNEZ =  5'b01101,
                BLTZ =  5'b01110,
                BGEZ =  5'b01111,
                LBI =   5'b11000,
                SLBI =  5'b10010,
                J =     5'b00100,
                JR =    5'b00101,
                JAL =   5'b00110,
                JALR =  5'b00111;

    assign ALU_mode =   (opcode == ADDI) ?  4'b0000 :
                        (opcode == SUBI) ?  4'b0000 :
                        (opcode == XORI) ?  4'b0001 :
                        (opcode == ANDNI) ? 4'b0010 :
                        (opcode == ROLI) ?  4'b0011 :
                        (opcode == SLLI) ?  4'b0100 :
                        (opcode == RORI) ?  4'b0101 :
                        (opcode == SRLI) ?  4'b0110 :
                        (opcode == ST) ?    4'b0000 :
                        (opcode == LD) ?    4'b0000 :
                        (opcode == STU) ?   4'b0000 :
                        (opcode == BTR) ?   4'b0111 :
                        ((opcode == ADD) & (func == 2'b00)) ?   4'b0000 :
                        ((opcode == SUB) & (func == 2'b01)) ?   4'b0000 :
                        ((opcode == XOR) & (func == 2'b10)) ?   4'b0001 :
                        ((opcode == ANDN) & (func == 2'b11)) ?  4'b0010 :
                        ((opcode == ROL) & (func == 2'b00)) ?   4'b0011 :
                        ((opcode == SLL) & (func == 2'b01)) ?   4'b0100 :
                        ((opcode == ROR) & (func == 2'b10)) ?   4'b0101 :
                        ((opcode == SRL) & (func == 2'b11)) ?   4'b0110 :
                        (opcode == SEQ) ?   4'b1000 :
                        (opcode == SLT) ?   4'b1001 :
                        (opcode == SLE) ?   4'b1010 :
                        (opcode == SCO) ?   4'b1011 :
                        (opcode == BEQZ) ?  4'b0000 :
                        (opcode == BNEZ) ?  4'b0000 :
                        (opcode == BLTZ) ?  4'b0000 :
                        (opcode == BGEZ) ?  4'b0000 :
                        (opcode == LBI) ?   4'b0000 :
                        (opcode == SLBI) ?  4'b0100 :
                        (opcode == J) ?     4'b0000 :
                        (opcode == JR) ?    4'b0000 :
                        (opcode == JAL) ?   4'b0000 :
                        (opcode == JALR) ?  4'b0000 :
                        4'b0000;

endmodule