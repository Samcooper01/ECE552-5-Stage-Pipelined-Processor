module data_hazard(hazard, instruction_decode, instruction_execute, instruction_memory, instruction_wb);
    
    input wire [15:0] instruction_decode;
    input wire [15:0] instruction_memory;
    input wire [15:0] instruction_execute;
    input wire [15:0] instruction_wb;

    output wire hazard;

    parameter ADDI = 5'b01000;  // rs, rd, imm (rd destination)
    parameter SUBI = 5'b01001;  // rs, rd, imm (rd destination)
    parameter XORI = 5'b01010;  // rs, rd, imm (rd destination)
    parameter ANDNI = 5'b01011; // rs, rd, imm (rd destination)
    parameter ROLI = 5'b10100;  // rs, rd, imm (rd destination)
    parameter SLLI = 5'b10101;  // rs, rd, imm (rd destination)
    parameter RORI = 5'b10110;  // rs, rd, imm (rd destination)
    parameter SRLI = 5'b10111;  // rs, rd, imm (rd destination)
    parameter ST = 5'b10000;    // rs, rd, imm (rd destination)
    parameter LD = 5'b10001;    // rs, rd, imm (rd destination)

    parameter ADD = 5'b11011;   // rs, rt, rd (rd destination)
    parameter SUB = 5'b11011;   // rs, rt, rd (rd destination)
    parameter XOR = 5'b11011;   // rs, rt, rd (rd destination)
    parameter ANDN = 5'b11011;  // rs, rt, rd (rd destination)
    parameter ROL = 5'b11010;   // rs, rt, rd (rd destination)
    parameter SLL = 5'b11010;   // rs, rt, rd (rd destination)
    parameter ROR = 5'b11010;   // rs, rt, rd (rd destination)
    parameter SRL = 5'b11010;   // rs, rt, rd (rd destination)
    parameter SEQ = 5'b11100;   // rs, rt, rd (rd destination)
    parameter SLT = 5'b11101;   // rs, rt, rd (rd destination)
    parameter SLE = 5'b11110;   // rs, rt, rd (rd destination)
    parameter SCO = 5'b11111;   // rs, rt, rd (rd destination)

    parameter STU = 5'b10011;   // rs, rd, imm (rs destination)
    parameter LBI = 5'b11000;   // rs, imm (rs destination)
    parameter SLBI = 5'b10010;  // rs, imm (rs destination)

    parameter BTR = 5'b11001;   // rs, xxx, rd, xx (rd destination)
    
    parameter BEQZ = 5'b01100; // rs, imm (no destination)
    parameter BNEZ = 5'b01101; // rs, imm (no destination)
    parameter BLTZ = 5'b01110; // rs, imm (no destination)
    parameter BGEZ = 5'b01111; // rs, imm (no destination)

    parameter JR = 5'b00101; // rs (no destination)
    parameter JAL = 5'b00110; // nothing (r7 destination)
    parameter JALR = 5'b00111; // rs, imm (r7 destination)

    // locate the source registers for each instruction in the decode stage
    wire [2:0] source_1_decode, source_2_decode;

    // source 1 is always in the [10:8] spot unless it is LBI, which has no source
    assign source_1_decode =   (instruction_decode[15:11] == ADDI | instruction_decode[15:11] == SUBI |
                                instruction_decode[15:11] == XORI | instruction_decode[15:11] == ANDNI |
                                instruction_decode[15:11] == ROLI | instruction_decode[15:11] == SLLI |
                                instruction_decode[15:11] == RORI | instruction_decode[15:11] == SRLI |
                                instruction_decode[15:11] == ST   | instruction_decode[15:11] == LD |
                                instruction_decode[15:11] == ADD  | instruction_decode[15:11] == SUB |
                                instruction_decode[15:11] == XOR  | instruction_decode[15:11] == ANDN |
                                instruction_decode[15:11] == ROL  | instruction_decode[15:11] == SLL |
                                instruction_decode[15:11] == ROR  | instruction_decode[15:11] == SRL |
                                instruction_decode[15:11] == SEQ  | instruction_decode[15:11] == SLT |
                                instruction_decode[15:11] == SLE  | instruction_decode[15:11] == SCO |
                                instruction_decode[15:11] == STU  | instruction_decode[15:11] == BTR |
                                instruction_decode[15:11] == SLBI) ? instruction_decode[10:8] : 
                                (instruction_decode[15:11] == BEQZ | instruction_decode[15:11] == BNEZ |
                                instruction_decode[15:11] == BLTZ | instruction_decode[15:11] == BGEZ |
                                instruction_decode[15:11] == JR   | instruction_decode[15:11] == JALR) ? instruction_decode[10:8] : 3'b1zz;


    // source 2 will be rd for st, stu and rt for add, sub, xor, andn, rol, sll, ror, srl, seq, slt, sle, and sco
    assign source_2_decode = (instruction_decode[15:11] == ST | instruction_decode[15:11] == STU) ? instruction_decode[7:5] :
                             (instruction_decode[15:11] == ADD | instruction_decode[15:11] == SUB |
                              instruction_decode[15:11] == XOR | instruction_decode[15:11] == ANDN |
                              instruction_decode[15:11] == ROL | instruction_decode[15:11] == SLL |
                              instruction_decode[15:11] == ROR | instruction_decode[15:11] == SRL |
                              instruction_decode[15:11] == SEQ | instruction_decode[15:11] == SLT |
                              instruction_decode[15:11] == SLE | instruction_decode[15:11] == SCO) ? instruction_decode[7:5] : 3'b0zz;
    
    // locate the desination registers for each instruction in the execute stage
    wire [2:0] destination_execute;

    // destination 1 is rd for addi, subi, xori, andni, roli, slli, rori, srli, ld, btr, add, sub, xor, andn, rol, sll, ror, srl, seq, slt, sle, and sco
    // destination 1 is rs for stu, lbi, slbi
    assign destination_execute =  ((instruction_execute[15:11] == STU)  | (instruction_execute[15:11] == LBI) |
                                  (instruction_execute[15:11] == SLBI)) ? instruction_execute[10:8] :
                                  ((instruction_execute[15:11] == ADDI) | (instruction_execute[15:11] == SUBI) |
                                  (instruction_execute[15:11] == XORI) | (instruction_execute[15:11] == ANDNI) |
                                  (instruction_execute[15:11] == ROLI) | (instruction_execute[15:11] == SLLI) |
                                  (instruction_execute[15:11] == RORI) | (instruction_execute[15:11] == SRLI) |
                                  (instruction_execute[15:11] == LD)) ? instruction_execute[7:5] :
                                  ((instruction_execute[15:11] == ADD)  | (instruction_execute[15:11] == SUB) |
                                  (instruction_execute[15:11] == XOR)  | (instruction_execute[15:11] == ANDN) |
                                  (instruction_execute[15:11] == ROL)  | (instruction_execute[15:11] == SLL) |
                                  (instruction_execute[15:11] == ROR)  | (instruction_execute[15:11] == SRL) |
                                  (instruction_execute[15:11] == SEQ)  | (instruction_execute[15:11] == SLT) |
                                  (instruction_execute[15:11] == SLE)  | (instruction_execute[15:11] == SCO) |
                                  (instruction_execute[15:11] == BTR)) ? instruction_execute[4:2] : 
                                  (instruction_execute[15:11] == JAL | instruction_execute[15:11] == JALR) ? 3'b111 : 3'bz1z;

    wire [2:0] destination_memory;

    assign destination_memory =  ((instruction_memory[15:11] == STU)  | (instruction_memory[15:11] == LBI) |
                                  (instruction_memory[15:11] == SLBI)) ? instruction_memory[10:8] :
                                 ((instruction_memory[15:11] == ADDI) | (instruction_memory[15:11] == SUBI) |
                                  (instruction_memory[15:11] == XORI) | (instruction_memory[15:11] == ANDNI) |
                                  (instruction_memory[15:11] == ROLI) | (instruction_memory[15:11] == SLLI) |
                                  (instruction_memory[15:11] == RORI) | (instruction_memory[15:11] == SRLI) |
                                  (instruction_memory[15:11] == LD)) ? instruction_memory[7:5] :
                                 ((instruction_memory[15:11] == ADD)  | (instruction_memory[15:11] == SUB) |
                                  (instruction_memory[15:11] == XOR)  | (instruction_memory[15:11] == ANDN) |
                                  (instruction_memory[15:11] == ROL)  | (instruction_memory[15:11] == SLL) |
                                  (instruction_memory[15:11] == ROR)  | (instruction_memory[15:11] == SRL) |
                                  (instruction_memory[15:11] == SEQ)  | (instruction_memory[15:11] == SLT) |
                                  (instruction_memory[15:11] == SLE)  | (instruction_memory[15:11] == SCO) |
                                  (instruction_memory[15:11] == BTR)) ? instruction_memory[4:2] :
                                  (instruction_memory[15:11] == JAL | instruction_memory[15:11] == JALR) ? 3'b111 : 3'bz0z;

    wire [2:0] destination_wb;

    assign destination_wb =    ((instruction_wb[15:11] == STU)  | (instruction_wb[15:11] == LBI) |
                                (instruction_wb[15:11] == SLBI)) ? instruction_wb[10:8] :
                               ((instruction_wb[15:11] == ADDI) | (instruction_wb[15:11] == SUBI) |
                                (instruction_wb[15:11] == XORI) | (instruction_wb[15:11] == ANDNI) |
                                (instruction_wb[15:11] == ROLI) | (instruction_wb[15:11] == SLLI) |
                                (instruction_wb[15:11] == RORI) | (instruction_wb[15:11] == SRLI) |
                                (instruction_wb[15:11] == LD)) ? instruction_wb[7:5] :
                               ((instruction_wb[15:11] == ADD)  | (instruction_wb[15:11] == SUB) |
                                (instruction_wb[15:11] == XOR)  | (instruction_wb[15:11] == ANDN) |
                                (instruction_wb[15:11] == ROL)  | (instruction_wb[15:11] == SLL) |
                                (instruction_wb[15:11] == ROR)  | (instruction_wb[15:11] == SRL) |
                                (instruction_wb[15:11] == SEQ)  | (instruction_wb[15:11] == SLT) |
                                (instruction_wb[15:11] == SLE)  | (instruction_wb[15:11] == SCO) |
                                (instruction_wb[15:11] == BTR)) ? instruction_wb[4:2] :
                                (instruction_wb[15:11] == JAL | instruction_wb[15:11] == JALR) ? 3'b111 : 3'bz1z;

    // if either source register in decode is equal to any destination register in execute, memory, or wb, there is a hazard
    assign hazard = ((source_1_decode === destination_execute) | (source_2_decode === destination_execute) |
                     (source_1_decode === destination_memory) | (source_2_decode === destination_memory) |
                     (source_1_decode === destination_wb) | (source_2_decode === destination_wb)) ? 1'b1 : 1'b0;
    
endmodule