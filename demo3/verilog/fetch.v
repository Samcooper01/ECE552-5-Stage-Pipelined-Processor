/*
   CS/ECE 552 Spring '22
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch (clk, rst, next_pc, instruction, pc_plus_two, enableMem, hazard, control_hazard, halt, valid, nop_pc, ImmJmp, pc, instruction_wb, instruction_err);

   // Inputs:
   input wire clk;                     // the clock signal for registers
   input wire rst;                     // the reset signal for registers
   input wire [15:0] next_pc;          // the input to the PC
   input wire enableMem;               // signal to enable memory
   input wire hazard;                  // when this is HIGH, the output of the PC is held steady
   input wire control_hazard;
   input wire halt;
   input wire nop_pc;
   input wire ImmJmp;
   input wire [15:0] instruction_wb;

   // Outputs:
   output wire [15:0] instruction;      // the output of the instruction memory block
   output wire [15:0] pc_plus_two;      // the output of the PC + 2 adder
   output wire valid;                   // Valid bit determines if the instruction in the current stage is valid
   output wire instruction_err;

   // Internal wires:
   output wire [15:0] pc;                     // the output of the PC register
   wire [15:0] instruction_premux;     // the output of the instruction memory block
   wire freeze_pc;
   wire Done, Stall, CacheHit, instruction_stall;

   // freeze the PC on any hazardor halt
   assign freeze_pc = hazard | halt | instruction_stall;

   // on a control hazard, fill with NOP
   assign instruction = control_hazard | halt | instruction_stall ? 16'h0800 : instruction_premux;

   // Valid bit that propogates through latches, determining whether or not the current instruction is valid or not, and is then allowed to execute
   assign valid = ~rst; 

   // Local parameters:
   localparam [15:0] pc_inc = 4'h2;    // the increment value for the pc (2)

   // instantiate pc
   // reg_16 pc_reg (.clk(clk), .reset(rst), .d(next_pc), .q(pc));
   dff_we #(16) pc_reg (.clk(clk), .rst(rst), .writeData(next_pc), .readData(pc), .writeEn(freeze_pc));
   
   // TODO: instantiate instruction memory
   //memory2c_align instruction_memory (.data_out(instruction_premux), .data_in(), .addr(pc), 
   //                             .enable(~halt), .wr(1'b0), .createdump(1'b0), .clk(clk), .rst(rst), .err(instruction_err));
   stallmem instruction_memory(.DataOut(instruction_premux), .Done(Done), .Stall(Stall), .CacheHit(CacheHit), 
      .err(instruction_err), .Addr(pc), .DataIn(), .Rd(~halt), .Wr(1'b0), .createdump(1'b0), .clk(clk), .rst(rst));

   assign instruction_stall = Stall & ~Done;

   // TODO: instantiate pc + 2 adder using pc_inc localparam
   cla_16b iPCinc2(.sum(pc_plus_two), .c_out(), .a(pc), .b(pc_inc), .c_in(1'b0));
   
endmodule