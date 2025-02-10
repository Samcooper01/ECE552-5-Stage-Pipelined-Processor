module control_hazard_detector(instr_decode, instr_execute, instr_memory, instr_wb, control_hazard);

    input [15:0]instr_decode;
    input [15:0]instr_execute;
    input [15:0]instr_memory;
    input [15:0]instr_wb;
    
    output control_hazard;

    parameter   BEQZ =  5'b01100,
                BNEZ =  5'b01101,
                BLTZ =  5'b01110,
                BGEZ =  5'b01111,
                J =     5'b00100,
                JR =    5'b00101,
                JAL =   5'b00110,
                JALR =  5'b00111;

    assign control_hazard = (instr_decode[15:11] == BEQZ) ? 1'b1 : 
                            (instr_decode[15:11] == BNEZ) ? 1'b1 :
                            (instr_decode[15:11] == BLTZ) ? 1'b1 :
                            (instr_decode[15:11] == BGEZ) ? 1'b1 :
                            (instr_decode[15:11] == J) ? 1'b1 :
                            (instr_decode[15:11] == JR) ? 1'b1 :
                            (instr_decode[15:11] == JAL) ? 1'b1 :
                            (instr_decode[15:11] == JALR) ? 1'b1 :
                            (instr_execute[15:11] == BEQZ) ? 1'b1 : 
                            (instr_execute[15:11] == BNEZ) ? 1'b1 :
                            (instr_execute[15:11] == BLTZ) ? 1'b1 :
                            (instr_execute[15:11] == BGEZ) ? 1'b1 :
                            (instr_execute[15:11] == J) ? 1'b1 :
                            (instr_execute[15:11] == JR) ? 1'b1 :
                            (instr_execute[15:11] == JAL) ? 1'b1 :
                            (instr_execute[15:11] == JALR) ? 1'b1 :
                            (instr_memory[15:11] == BEQZ) ? 1'b1 : 
                            (instr_memory[15:11] == BNEZ) ? 1'b1 :
                            (instr_memory[15:11] == BLTZ) ? 1'b1 :
                            (instr_memory[15:11] == BGEZ) ? 1'b1 :
                            (instr_memory[15:11] == J) ? 1'b1 :
                            (instr_memory[15:11] == JR) ? 1'b1 :
                            (instr_memory[15:11] == JAL) ? 1'b1 :
                            (instr_memory[15:11] == JALR) ? 1'b1 :
                            (instr_wb[15:11] == BEQZ) ? 1'b1 : 
                            (instr_wb[15:11] == BNEZ) ? 1'b1 :
                            (instr_wb[15:11] == BLTZ) ? 1'b1 :
                            (instr_wb[15:11] == BGEZ) ? 1'b1 :
                            1'b0;

endmodule