/*
   CS/ECE 552 Spring '22
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch (
   // Inputs
   clk, rst, next_pc, enableMem, halt, branch_jump_taken, unaligned_access,
   // Outputs
   instruction, pc_plus_two, valid, instruction_memory_error
   );

   // Inputs:
   input wire clk;                     // the clock signal for registers
   input wire rst;                     // the reset signal for registers
   input wire [15:0] next_pc;          // The input to the pc, from the execute stage 
   input wire enableMem;               // signal to enable memory
   input wire halt;
   input wire branch_jump_taken;       // Signal to determine if a branch is taken
   input wire unaligned_access;
   
   // Outputs:
   output wire [15:0] instruction;      // the output of the instruction memory block
   output wire [15:0] pc_plus_two;      // the output of the PC + 2 adder'
   output wire valid;                   // Valid bit determines if the instruction in the current stage is valid
   output wire instruction_memory_error; // Signal to determine if there is an error in the instruction memory

   // Valid bit that propogates through latches, determining whether or not the current instruction is valid or not, and is then allowed to execute
   assign valid = ~rst; 

   // Internal wires:
   wire [15:0] pc;                       // the output of the PC register
   wire [15:0] taken_pc;                 // the output of the branch/jump mux
   wire [15:0] adjusted_pc;  

   // Local parameters:
   localparam [15:0] pc_inc = 4'h2;    // the increment value for the pc (2)

   // instantiate pc
   dff_we pc_reg (.clk(clk), .rst(rst), .writeData(adjusted_pc), .readData(pc), .writeEn(~halt | unaligned_access));
   
   // // TODO: instantiate instruction memory
   // memory2c instruction_memory (.data_out(instruction), .data_in(), .addr(taken_pc), 
   //                              .enable(1'b1), .wr(1'b0), .createdump(1'b0), .clk(clk), .rst(rst));

   // unaligned access memory
   memory2c_align instruction_memory(.data_out(instruction), .data_in(), .addr(taken_pc),
                                    .enable(1'b1), .wr(1'b0), .createdump(1'b0), .clk(clk), .rst(rst), .err(instruction_memory_error));
   
   // TODO: instantiate pc + 2 adder using pc_inc localparam
   cla_16b iPCinc2(.sum(pc_plus_two), .c_out(), .a(taken_pc), .b(pc_inc), .c_in(1'b0));

   assign taken_pc = (branch_jump_taken) ? next_pc : pc;

   wire [15:0] next_pc_plus_two;
   cla_16b iPCinc2inc2(.sum(next_pc_plus_two), .c_out(), .a(next_pc), .b(pc_inc), .c_in(1'b0));
   assign adjusted_pc = (branch_jump_taken) ? next_pc_plus_two : next_pc; 

   
endmodule