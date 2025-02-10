/*
   CS/ECE 552 Spring '22
  
   Filename        : wb.v
   Description     : This is the module for the overall Write Back stage of the processor.
*/
module wb ( clk, rst,
            ALUJmp, RegSrc, // control signal inputs
            ALU_output, pc_plus_two, read_data, ConstSel_mux, ImmJmp_mux, // data inputs
            next_pc, write_data); // data outputs

   // Inputs:
   input wire clk;                     // the clock signal for registers
   input wire rst;                     // the reset signal for registers
   input wire ALUJmp;                  // control signal from decode
   input wire [1:0] RegSrc;                  // control signal from decode
   input wire [15:0] ALU_output;       // the output of the ALU
   input wire [15:0] pc_plus_two;      // the output of the PC + 2 adder
   input wire [15:0] read_data;        // the output of the data memory block
   input wire [15:0] ConstSel_mux;     // the output of the ConstSel mux
   input wire [15:0] ImmJmp_mux;       // the output of the ImmJmp mux
   
   // Outputs:
   output wire [15:0] next_pc;         // the input to the PC from ALUJmp mux
   output wire [15:0] write_data;      // the input to the register file block from RegSrc mux

   // Internal wires:
   // none

   // Localparams:
   // none

   // ALUJmp mux to select between an immediate / PC + 2 jump or an ALU result
   assign next_pc = (ALUJmp) ? ALU_output : ImmJmp_mux;

   // RegSrc mux to select the data to be written to the register file
   assign write_data = (RegSrc == 2'b00) ? pc_plus_two :
                       (RegSrc == 2'b01) ? read_data :
                       (RegSrc == 2'b10) ? ALU_output :
                       ConstSel_mux; // we default to ConstSel mux for RegSrc == 2'b11
   
endmodule
