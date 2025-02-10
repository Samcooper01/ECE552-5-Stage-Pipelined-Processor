/*
   CS/ECE 552 Spring '22
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch (clk, rst, next_pc, instruction, pc_plus_two, enableMem);

   // Inputs:
   input wire clk;                     // the clock signal for registers
   input wire rst;                     // the reset signal for registers
   input wire [15:0] next_pc;          // the input to the PC
   input wire enableMem;               // signal to enable memory

   // Outputs:
   output wire [15:0] instruction;      // the output of the instruction memory block
   output wire [15:0] pc_plus_two;      // the output of the PC + 2 adder

   // Internal wires:
   wire [15:0] pc;                     // the output of the PC register
   
   // Local parameters:
   localparam [15:0] pc_inc = 4'h2;    // the increment value for the pc (2)

   // instantiate pc
   reg_16 pc_reg (.clk(clk), .reset(rst), .d(next_pc), .q(pc));
   
   // TODO: instantiate instruction memory
   memory2c instruction_memory (.data_out(instruction), .data_in(), .addr(pc), 
                                .enable(1'b1), .wr(1'b0), .createdump(1'b0), .clk(clk), .rst(rst));
   
   // TODO: instantiate pc + 2 adder using pc_inc localparam
   cla_16b iPCinc2(.sum(pc_plus_two), .c_out(), .a(pc), .b(pc_inc), .c_in(1'b0));
   
endmodule