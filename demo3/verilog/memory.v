/*
   CS/ECE 552 Spring '22
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
module memory (clk, rst,
               ImmSrc, MemWrt, ConstSel, createDump, enableMem, // control signal inputs
               pc_plus_two, ALU_output, SLBI_concat, read_data_2, instruction_lower_8_ext, instruction_lower_11_ext, // data inputs
               read_data, ConstSel_mux, jump_adder_output, memory_err); // data outputs

   // Inputs:
   input wire clk;                     // the clock signal for registers
   input wire rst;                     // the reset signal for registers
   input wire ImmSrc;                  // generated from decoder
   input wire MemWrt;                  // generated from decoder
   input wire createDump;              // generated from decoder
   input wire enableMem;               // generated from decoder
   input wire [1:0] ConstSel;          // generated from decoder
   input wire [15:0] pc_plus_two;      // PC + 2
   input wire [15:0] ALU_output;       // output of the ALU
   input wire [15:0] SLBI_concat;      // result of SLBI instruction for ConstSel mux
   input wire [15:0] read_data_2;       // data to be written to memory
   input wire [15:0] instruction_lower_8_ext; // lower 8 bits of instruction either SE or ZE
   input wire [15:0] instruction_lower_11_ext; // lower 11 bits of instruction SE
   
   // Outputs:
   output wire [15:0] read_data;       // data read from memory
   output wire [15:0] ConstSel_mux;    // output of the ConstSel mux for wb
   output wire [15:0] jump_adder_output;      // output of the ImmJmp mux for mux in wb
   output wire memory_err;             // error signal from memory

   // Internal wires:
   wire [15:0] ImmSrc_mux;             // output of the ImmSrc mux

   // Localparams
   localparam [15:0] zero = 16'b0;     // 0 value for ConstSel mux
   localparam [15:0] one = 4'h1;  // 1 value for ConstSel mux

   // instantiate the data memory block
   memory2c_align data_memory (.data_out(read_data), .data_in(read_data_2), .addr(ALU_output), .enable(enableMem), 
                         .wr(MemWrt), .createdump(createDump), .clk(clk), .rst(rst), .err(memory_err));

   // instantiate the immediate jump adder
   cla_16b iJadder(.sum(jump_adder_output), .c_out(), .a(pc_plus_two), .b(ImmSrc_mux), .c_in(1'b0));

   // ImmSrc mux to select between the lower 8 bits or lower 11 bits for immediate jump
   assign ImmSrc_mux = (ImmSrc) ? instruction_lower_11_ext : instruction_lower_8_ext;

   // ConstSel mux to select the fourth input to the writeback mux
   assign ConstSel_mux = (ConstSel == 2'b00) ? zero :
                         (ConstSel == 2'b01) ? one :
                         (ConstSel == 2'b10) ? instruction_lower_8_ext :
                         (SLBI_concat); // we default to SLBI concat for ConstSel == 2'b11

endmodule
