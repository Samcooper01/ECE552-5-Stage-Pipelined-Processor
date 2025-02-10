/*
   CS/ECE 552 Spring '22
  
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
module execute (
   // Inputs:
   clk, rst, instruction, instruction_ext_5, instruction_ext_8, 
   read_data_1, read_data_2, Cin, BSel, ALUOp, InvA, InvB, BSrc, 
   forward_ALU_output_EM, forward_ALU_output_MW, forward_MEM_output, forward_MEM_output_MW, 
   forward_control_A, forward_control_B, mem_data_forward, forward_reg_data_wb, reg_data_wb_sb,
   // Outputs:
   ALU_output, ALU_read_data_2, SLBI_result);

   // Inputs:
   input wire clk, rst;
   input wire [15:0] instruction, instruction_ext_5, 
      instruction_ext_8, read_data_1, read_data_2;
   input wire Cin, BSel, InvA, InvB;
   input wire [1:0] BSrc; 
   input wire [3:0] ALUOp;
   input wire [15:0] forward_ALU_output_EM, forward_ALU_output_MW, forward_MEM_output, forward_MEM_output_MW, forward_reg_data_wb, reg_data_wb_sb;
   input wire [2:0] forward_control_A, forward_control_B;
   input wire [3:0] mem_data_forward;
   
   // Outputs:
   output wire [15:0] ALU_output;         
   output wire [15:0] ALU_read_data_2;   
   output wire [15:0] SLBI_result;  

   // localparams
   localparam [15:0] zero = 16'b0;    // 0 value for BSel mux
   localparam [15:0] eight = 4'h8; // 8 value for BSel mux

   // Internal wires:
   wire [15:0] ALU_input_b, BSel_mux, ALU_input_a, ALU_input_no_forward;


   // BSel Mux to produce the fourth input for the BSrc mux
   assign BSel_mux = (BSel) ? eight : zero;

   // BSrc Mux to select the input for the second ALU input "B"
   assign ALU_input_no_forward = (BSrc == 2'b00) ? read_data_2 : 
                                 (BSrc == 2'b01) ? instruction_ext_5 :
                                 (BSrc == 2'b10) ? instruction_ext_8 :
                                 (BSel_mux); 

   // ALU Instantiation
   ALU ALU_inst(.A(ALU_input_a), .B(ALU_input_b), .invA(InvA), .invB(InvB), .c_in(Cin), .ALU_mode(ALUOp), .out(ALU_output));

   // ALU Input A
   assign ALU_input_a = (forward_control_A == 3'b000) ? read_data_1 :
                        (forward_control_A == 3'b001) ? forward_ALU_output_EM :
                        (forward_control_A == 3'b010) ? forward_ALU_output_MW :
                        (forward_control_A == 3'b011) ? forward_MEM_output :
                        (forward_control_A == 3'b100) ? forward_MEM_output_MW :
                        read_data_1; //DEFAULT should never hit

   // ALU Input B
   assign ALU_input_b = (forward_control_B == 3'b000) ? ALU_input_no_forward :
                        (forward_control_B == 3'b001) ? forward_ALU_output_EM :
                        (forward_control_B == 3'b010) ? forward_ALU_output_MW :
                        (forward_control_B == 3'b011) ? forward_MEM_output :
                        (forward_control_B == 3'b100) ? forward_MEM_output_MW :
                        ALU_input_no_forward; //DEFAULT should never hit

   assign ALU_read_data_2 =   (mem_data_forward == 3'b000) ? read_data_2 :
                              (mem_data_forward == 3'b001) ? forward_ALU_output_EM :
                              (mem_data_forward == 3'b010) ? forward_MEM_output :
                              (mem_data_forward == 3'b011) ? forward_reg_data_wb :
                              (mem_data_forward == 3'b100) ? reg_data_wb_sb :
                              read_data_1; //DEFAULT should never hit

endmodule
