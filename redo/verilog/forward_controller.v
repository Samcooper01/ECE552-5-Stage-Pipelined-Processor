/*
   CS/ECE 552 Spring '22
  
   Filename        : forward_controller.v
   Description     : This is the module for setting forwarding signals
*/ 

module forward_controller (
   // Inputs
   clk, rst, 
   instruction_execute, reg_src_EM, reg_src_WB, instruction_memory, instruction_wb, instruction_wb_sb, rf_write_reg_wb_sb,
   // Outputs
   hazard_A, hazard_B, mem_en_forward, mem_data_forward
   );

input wire clk;
input wire rst;

input wire [15:0] instruction_execute, instruction_memory, instruction_wb, instruction_wb_sb;
input wire [2:0] reg_src_EM, rf_write_reg_wb_sb;
input wire [2:0] reg_src_WB;

output wire [2:0]   hazard_A;
output wire [2:0]   hazard_B;
output wire [3:0]   mem_data_forward;
output wire         mem_en_forward;

//Internals
wire [3:0] execute_rs, execute_rt, execute_rd;
wire [4:0] opcode, opcode_memory, opcode_wb, opcode_sb;
wire [3:0] inst_ex_bits_eight_to_ten;
wire [3:0] inst_ex_bits_five_to_seven;
wire hazard_on_rs_EM, hazard_on_rs_WB, hazard_on_rt_EM, hazard_on_rt_WB, hazard_on_rd_sb, hazard_on_rd_wb, hazard_on_rd_EM;
wire instruct_dest_memory, instruct_dest_wb; //1 if dest is from memory, 0 if dest is from ALU
wire hazardous_inst_memory, hazardous_inst_wb, hazardous_inst_sb;

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

//Just for readability
assign opcode = instruction_execute[15:11];
assign opcode_memory = instruction_memory[15:11];
assign opcode_wb = instruction_wb[15:11];
assign inst_ex_bits_eight_to_ten = {{1'b0}, instruction_execute[10:8]}; 
assign inst_ex_bits_five_to_seven = {{1'b0}, instruction_execute[7:5]};
assign opcode_sb = instruction_wb_sb[15:11];


assign execute_rs = (opcode == ADDI) ? inst_ex_bits_eight_to_ten :
                    (opcode == SUBI) ? inst_ex_bits_eight_to_ten :
                    (opcode == XORI) ? inst_ex_bits_eight_to_ten :
                    (opcode == ANDNI) ? inst_ex_bits_eight_to_ten :
                    (opcode == ROLI) ? inst_ex_bits_eight_to_ten :
                    (opcode == SLLI) ? inst_ex_bits_eight_to_ten :
                    (opcode == RORI) ? inst_ex_bits_eight_to_ten :
                    (opcode == SRLI) ? inst_ex_bits_eight_to_ten :
                    (opcode == ADD) ? inst_ex_bits_eight_to_ten :
                    (opcode == SUB) ? inst_ex_bits_eight_to_ten :
                    (opcode == XOR) ? inst_ex_bits_eight_to_ten :
                    (opcode == ANDN) ? inst_ex_bits_eight_to_ten :
                    (opcode == ROL) ? inst_ex_bits_eight_to_ten :
                    (opcode == SLL) ? inst_ex_bits_eight_to_ten :
                    (opcode == ROR) ? inst_ex_bits_eight_to_ten :
                    (opcode == SRL) ? inst_ex_bits_eight_to_ten :
                    (opcode == SEQ) ? inst_ex_bits_eight_to_ten :
                    (opcode == SLT) ? inst_ex_bits_eight_to_ten :
                    (opcode == SLE) ? inst_ex_bits_eight_to_ten :
                    (opcode == SCO) ? inst_ex_bits_eight_to_ten :
                    (opcode == LD) ? inst_ex_bits_eight_to_ten : 
                    (opcode == ST) ? inst_ex_bits_eight_to_ten : 
                    4'b1111; //DEFAULT - should never hit this

assign execute_rt = (opcode == ADD) ? inst_ex_bits_five_to_seven :
                    (opcode == SUB) ? inst_ex_bits_five_to_seven :
                    (opcode == XOR) ? inst_ex_bits_five_to_seven :
                    (opcode == ANDN) ? inst_ex_bits_five_to_seven :
                    (opcode == ROL) ? inst_ex_bits_five_to_seven :
                    (opcode == SLL) ? inst_ex_bits_five_to_seven :
                    (opcode == ROR) ? inst_ex_bits_five_to_seven :
                    (opcode == SRL) ? inst_ex_bits_five_to_seven :
                    (opcode == SEQ) ? inst_ex_bits_five_to_seven :
                    (opcode == SLT) ? inst_ex_bits_five_to_seven :
                    (opcode == SLE) ? inst_ex_bits_five_to_seven :
                    (opcode == SCO) ? inst_ex_bits_five_to_seven : 
                    4'b1111; //DEFAULT - should never hit this

assign execute_rd = (opcode == ST) ? inst_ex_bits_five_to_seven :
                    4'b1111; //Dont question it


assign hazard_on_rs_EM =    (execute_rs == reg_src_EM) & (execute_rs != 4'b1111) ? 1'b1 : 
                            1'b0; //Shut up i know this is dumb

assign hazard_on_rs_WB =    (execute_rs == reg_src_WB) & (execute_rs != 4'b1111) ? 1'b1 :
                            1'b0;

assign hazard_on_rt_EM =    (execute_rt == reg_src_EM) & (execute_rt != 4'b1111) ? 1'b1 :
                            1'b0;

assign hazard_on_rt_WB =    (execute_rt == reg_src_WB) & (execute_rt != 4'b1111) ? 1'b1 :
                            1'b0;

//1 if dest is from memory, 0 if dest is from ALU
assign instruct_dest_memory =   (opcode_memory == ADDI) ? 1'b0 :
                                (opcode_memory == SUBI) ? 1'b0 : 
                                (opcode_memory == XORI) ? 1'b0 : 
                                (opcode_memory == ANDNI) ? 1'b0 : 
                                (opcode_memory == ROLI) ? 1'b0 : 
                                (opcode_memory == SLLI) ? 1'b0 : 
                                (opcode_memory == RORI) ? 1'b0 : 
                                (opcode_memory == SRLI) ? 1'b0 : 
                                (opcode_memory == ADD) ? 1'b0 : 
                                (opcode_memory == SUB) ? 1'b0 : 
                                (opcode_memory == XOR) ? 1'b0 : 
                                (opcode_memory == ANDN) ? 1'b0 : 
                                (opcode_memory == ROL) ? 1'b0 : 
                                (opcode_memory == SLL) ? 1'b0 : 
                                (opcode_memory == ROR) ? 1'b0 : 
                                (opcode_memory == SRL) ? 1'b0 : 
                                (opcode_memory == SEQ) ? 1'b0 : 
                                (opcode_memory == SLT) ? 1'b0 : 
                                (opcode_memory == SLE) ? 1'b0 : 
                                (opcode_memory == SCO) ? 1'b0 : 
                                (opcode_memory == LD) ? 1'b1 :
                                1'b1; 

assign instruct_dest_wb =       (opcode_wb == ADDI) ? 1'b0 :
                                (opcode_wb == SUBI) ? 1'b0 : 
                                (opcode_wb == XORI) ? 1'b0 : 
                                (opcode_wb == ANDNI) ? 1'b0 : 
                                (opcode_wb == ROLI) ? 1'b0 : 
                                (opcode_wb == SLLI) ? 1'b0 : 
                                (opcode_wb == RORI) ? 1'b0 : 
                                (opcode_wb == SRLI) ? 1'b0 : 
                                (opcode_wb == ADD) ? 1'b0 : 
                                (opcode_wb == SUB) ? 1'b0 : 
                                (opcode_wb == XOR) ? 1'b0 : 
                                (opcode_wb == ANDN) ? 1'b0 : 
                                (opcode_wb == ROL) ? 1'b0 : 
                                (opcode_wb == SLL) ? 1'b0 : 
                                (opcode_wb == ROR) ? 1'b0 : 
                                (opcode_wb == SRL) ? 1'b0 : 
                                (opcode_wb == SEQ) ? 1'b0 : 
                                (opcode_wb == SLT) ? 1'b0 : 
                                (opcode_wb == SLE) ? 1'b0 : 
                                (opcode_wb == SCO) ? 1'b0 : 
                                1'b1; 

assign hazardous_inst_memory =   (opcode_memory == ADDI) ? 1'b1 :
                                (opcode_memory == SUBI) ? 1'b1 : 
                                (opcode_memory == XORI) ? 1'b1 : 
                                (opcode_memory == ANDNI) ? 1'b1 : 
                                (opcode_memory == ROLI) ? 1'b1 : 
                                (opcode_memory == SLLI) ? 1'b1 : 
                                (opcode_memory == RORI) ? 1'b1 : 
                                (opcode_memory == SRLI) ? 1'b1 : 
                                (opcode_memory == ADD) ? 1'b1 : 
                                (opcode_memory == SUB) ? 1'b1 : 
                                (opcode_memory == XOR) ? 1'b1 : 
                                (opcode_memory == ANDN) ? 1'b1 : 
                                (opcode_memory == ROL) ? 1'b1 : 
                                (opcode_memory == SLL) ? 1'b1 : 
                                (opcode_memory == ROR) ? 1'b1 : 
                                (opcode_memory == SRL) ? 1'b1 : 
                                (opcode_memory == SEQ) ? 1'b1 : 
                                (opcode_memory == SLT) ? 1'b1 : 
                                (opcode_memory == SLE) ? 1'b1 : 
                                (opcode_memory == SCO) ? 1'b1 : 
                                (opcode_memory == LD) ? 1'b1 :
                                1'b0; 

assign hazardous_inst_wb =      (opcode_wb == ADDI) ? 1'b1 :
                                (opcode_wb == SUBI) ? 1'b1 : 
                                (opcode_wb == XORI) ? 1'b1 : 
                                (opcode_wb == ANDNI) ? 1'b1 : 
                                (opcode_wb == ROLI) ? 1'b1 : 
                                (opcode_wb == SLLI) ? 1'b1 : 
                                (opcode_wb == RORI) ? 1'b1 : 
                                (opcode_wb == SRLI) ? 1'b1 : 
                                (opcode_wb == ADD) ? 1'b1 : 
                                (opcode_wb == SUB) ? 1'b1 : 
                                (opcode_wb == XOR) ? 1'b1 : 
                                (opcode_wb == ANDN) ? 1'b1 : 
                                (opcode_wb == ROL) ? 1'b1 : 
                                (opcode_wb == SLL) ? 1'b1 : 
                                (opcode_wb == ROR) ? 1'b1 : 
                                (opcode_wb == SRL) ? 1'b1 : 
                                (opcode_wb == SEQ) ? 1'b1 : 
                                (opcode_wb == SLT) ? 1'b1 : 
                                (opcode_wb == SLE) ? 1'b1 : 
                                (opcode_wb == SCO) ? 1'b1 : 
                                (opcode_wb == LD) ? 1'b1 :
                                1'b0; 

assign hazardous_inst_sb =      (opcode_sb == ADDI) ? 1'b1 :
                                (opcode_sb == SUBI) ? 1'b1 : 
                                (opcode_sb == XORI) ? 1'b1 : 
                                (opcode_sb == ANDNI) ? 1'b1 : 
                                (opcode_sb == ROLI) ? 1'b1 : 
                                (opcode_sb == SLLI) ? 1'b1 : 
                                (opcode_sb == RORI) ? 1'b1 : 
                                (opcode_sb == SRLI) ? 1'b1 : 
                                (opcode_sb == ADD) ? 1'b1 : 
                                (opcode_sb == SUB) ? 1'b1 : 
                                (opcode_sb == XOR) ? 1'b1 : 
                                (opcode_sb == ANDN) ? 1'b1 : 
                                (opcode_sb == ROL) ? 1'b1 : 
                                (opcode_sb == SLL) ? 1'b1 : 
                                (opcode_sb == ROR) ? 1'b1 : 
                                (opcode_sb == SRL) ? 1'b1 : 
                                (opcode_sb == SEQ) ? 1'b1 : 
                                (opcode_sb == SLT) ? 1'b1 : 
                                (opcode_sb == SLE) ? 1'b1 : 
                                (opcode_sb == SCO) ? 1'b1 : 
                                (opcode_sb == LD) ? 1'b1 :
                                1'b0; 


//0->5
//0 -> no hazard
//1 -> hazard from alu_output_EM
//2 -> hazard from alu_output_wb
//3 -> hazard from mem_data_out_EM
//4 -> hazard from mem_data_out_wb
assign hazard_A =   (hazard_on_rs_EM & ~instruct_dest_memory & hazardous_inst_memory) ? 3'b001 :
                    (hazard_on_rs_WB & ~instruct_dest_wb & hazardous_inst_wb) ? 3'b010 :
                    (hazard_on_rs_EM &  instruct_dest_memory & hazardous_inst_memory) ? 3'b011 :
                    (hazard_on_rs_WB &  instruct_dest_wb & hazardous_inst_wb) ? 3'b100 :
                    3'b000;

assign hazard_B =   (hazard_on_rt_EM & ~instruct_dest_memory & hazardous_inst_memory) ? 3'b001 :
                    (hazard_on_rt_WB & ~instruct_dest_wb & hazardous_inst_wb) ? 3'b010 :
                    (hazard_on_rt_EM &  instruct_dest_memory & hazardous_inst_memory) ? 3'b011 :
                    (hazard_on_rt_WB &  instruct_dest_wb & hazardous_inst_wb) ? 3'b100 :
                    3'b000;

assign hazard_on_rd_EM =    ((opcode == ST) & (reg_src_EM == execute_rd)) ? 1'b1 :
                            1'b0;

assign hazard_on_rd_wb =    ((opcode == ST) & (reg_src_WB == execute_rd)) ? 1'b1 :
                            1'b0;

assign hazard_on_rd_sb =    ((opcode == ST) & (rf_write_reg_wb_sb == execute_rd)) ? 1'b1 :
                            1'b0;

assign mem_en_forward = (opcode == ST) & (hazard_on_rd_sb | hazard_on_rd_wb | hazard_on_rd_EM);

assign mem_data_forward =   ((opcode == ST) & hazard_on_rd_EM & ~instruct_dest_memory & hazardous_inst_memory) ? 3'b001 :                
                            ((opcode == ST) & hazard_on_rd_EM &  instruct_dest_memory & hazardous_inst_memory) ? 3'b010 :
                            ((opcode == ST) & hazard_on_rd_wb & hazardous_inst_wb) ? 3'b011 :
                            ((opcode == ST) & hazard_on_rd_sb & hazardous_inst_sb) ? 3'b100 :
                            3'b000; //Should hit this default if no hazard on ST



endmodule

   //ALU INPUT_A =     RS
    /* Input A can be a hazard when RS is being written to by an inst in pipeline */

    //ALU INPUT_B =     RT
    //                  IM5
    //                  IM8
    //                  BConst
    /* Input B can be a hazard when RT is being written to by an inst in pipeline */

    /* 
        This is a table of the instruction in the execute stage (a.k.a) being executed by the ALU 
        and its possible hazardous registers
    */
    //  OPCODE    Potential Hazard A?     Potential Hazard B?

    //  ADDI      Y                       N
    //  SUBI      Y                       N
    //  XORI      Y                       N
    //  ANDNI     Y                       N
    //  ROLI      Y                       N
    //  SLLI      Y                       N
    //  RORI      Y                       N
    //  SRLI      Y                       N

    //  ADD       Y                       Y
    //  SUB       Y                       Y
    //  XOR       Y                       Y
    //  ANDN      Y                       Y
    //  ROL       Y                       Y
    //  SLL       Y                       Y
    //  ROR       Y                       Y
    //  SRL       Y                       Y
    //  SEQ       Y                       Y
    //  SLT       Y                       Y
    //  SLE       Y                       Y
    //  SCO       Y                       Y

    /* 
        There are two sources for potential hazards
            1) ALU_output -> RS/RT
            2) MEM_output -> RS/RT

        The stages these outputs can be in are
            1) ALU_output -> RS/RT
                E/M latch output
                M/W latch output
            2) MEM_output -> RS/RT
                Data_memory readData
                M/W latch output
    */