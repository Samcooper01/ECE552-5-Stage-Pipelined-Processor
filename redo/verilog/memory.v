/*
   CS/ECE 552 Spring '22
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
module memory (
   // Inputs
   clk, rst, ALU_output, read_data_2, SLBI_result, instruction_ext_8, ConstSel, MemWrt, enableMem, createDump, mem_en_forward_memory,
   // Outputs
   mem_data_out, constsel_mux, data_memory_error
   );

   // Inputs:
   input wire clk, rst;
   input wire [15:0] ALU_output, read_data_2, SLBI_result, instruction_ext_8;         
   input wire [1:0] ConstSel;          
   input wire MemWrt, enableMem, createDump, mem_en_forward_memory;            

   
   // Outputs:
   output wire [15:0] mem_data_out;       
   output wire [15:0] constsel_mux;   
   output wire data_memory_error;

   // Localparams
   localparam [15:0] zero = 16'b0;     // 0 value for ConstSel mux
   localparam [15:0] one = 4'h1;  // 1 value for ConstSel mux

   wire memory_wrt;
   assign memory_wrt = MemWrt | mem_en_forward_memory;

   // Data memory block
   // memory2c data_memory (.data_out(mem_data_out), .data_in(read_data_2), .addr(ALU_output), .enable(enableMem), 
   //                       .wr(memory_wrt), .createdump(createDump), .clk(clk), .rst(rst));
                         
   memory2c_align data_memory (.data_out(mem_data_out), .data_in(read_data_2), .addr(ALU_output), .enable(enableMem), 
                         .wr(memory_wrt), .createdump(createDump), .clk(clk), .rst(rst), .err(data_memory_error));

   // ConstSel mux to select the fourth input to the writeback mux
   assign constsel_mux = (ConstSel == 2'b00) ? zero :
                         (ConstSel == 2'b01) ? one :
                         (ConstSel == 2'b10) ? instruction_ext_8 :
                         (SLBI_result); 

endmodule
