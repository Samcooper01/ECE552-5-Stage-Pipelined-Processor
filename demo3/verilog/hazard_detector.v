module hazard_detector(instr_decode, instr_execute, instr_memory, instr_wb, control_hazard, hazard);

    input wire [15:0]instr_decode;
    input wire [15:0]instr_execute;
    input wire [15:0]instr_memory;
    input wire [15:0]instr_wb;
    
    output wire control_hazard;
    output wire hazard;

    control_hazard_detector iControlHazard(.instr_decode(instr_decode), .instr_execute(instr_execute), .instr_memory(instr_memory), .instr_wb(instr_wb), .control_hazard(control_hazard));

    data_hazard iDataHazard(.instruction_decode(instr_decode), .instruction_execute(instr_execute), .instruction_memory(instr_memory), .instruction_wb(instr_wb), .hazard(hazard));

endmodule