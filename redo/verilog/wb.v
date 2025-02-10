/*
   CS/ECE 552 Spring '22
  
   Filename        : wb.v
   Description     : This is the module for the overall Write Back stage of the processor.
*/
module wb ( 
   // Inputs
   clk, rst, RegSrc, pc_plus_two, ALU_output, mem_data_out, constsel_mux,
   // Outputs
   reg_data
   );
   
   // Inputs:
   input wire clk, rst;
   input wire [15:0] ALU_output, pc_plus_two, mem_data_out, constsel_mux;
   input wire [1:0] RegSrc;

   // Outputs:
   output wire [15:0] reg_data;   

   // RegSrc mux to select the data to be written to the register file
   assign reg_data = (RegSrc == 2'b00) ? pc_plus_two :
                     (RegSrc == 2'b01) ? mem_data_out :
                     (RegSrc == 2'b10) ? ALU_output :
                     (constsel_mux); 
   
endmodule
