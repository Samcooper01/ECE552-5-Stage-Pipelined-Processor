/*
   CS/ECE 552 Spring '22
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
module decode (clk, rst, instruction, write_data, // inputs
               ImmSrc, InvA, InvB, Cin, BSrc, BSel, ALUJmp, MemWrt, RegSrc, ConstSel, ALUOp, enableMem, createDump,// control signal outputs
               read_data_1, read_data_2, instruction_lower_5_ext, instruction_lower_8_ext, instruction_lower_11_ext); // data outputs

   // Inputs:
   input wire clk;                     // the clock signal for registers
   input wire rst;                     // the reset signal for registers
   input wire [15:0] instruction;      // the input of the instruction memory block
   input wire [15:0] write_data;

   // Outputs:
   output wire ImmSrc;        // generated from decoder
   output wire InvA;          // generated from decoder
   output wire InvB;          // generated from decoder
   output wire Cin;           // generated from decoder
   output wire [1:0] BSrc;          // generated from decoder
   output wire BSel;          // generated from decoder
   output wire ALUJmp;        // generated from decoder
   output wire MemWrt;        // generated from decoder
   output wire [1:0] RegSrc;        // generated from decoder
   output wire [1:0] ConstSel;      // generated from decoder
   output wire createDump;    // generated from decoder
   output wire enableMem;     // generated from decoder
   output wire [3:0] ALUOp;         // generated from ALU Op block
   output wire [15:0] read_data_1;                 // output 1 of register file block
   output wire [15:0] read_data_2;                 // output 2 of register file block
   output wire [15:0] instruction_lower_5_ext;     // lower 5 bits of instruction either SE or ZE
   output wire [15:0] instruction_lower_8_ext;     // lower 8 bits of instruction either SE or ZE
   output wire [15:0] instruction_lower_11_ext;    // lower 11 bits of instruction SE

   // Internal wires:
   wire ZeroExt;                             // internal control signal
   wire [1:0] RegDst;                          // internal control signal      
   wire [4:0] ALUOpr;                           // internal control signal
   wire RegWrt;                           // internal control signal
   wire [2:0] write_register;             // the register to be written to in reg file
   wire [15:0] instruction_lower_5_SE;    // lower 5 bits of instruction sign extended 
   wire [15:0] instruction_lower_5_ZE;    // lower 5 bits of instruction zero extended
   wire [15:0] instruction_lower_8_SE;    // lower 8 bits of instruction sign extended
   wire [15:0] instruction_lower_8_ZE;    // lower 8 bits of instruction zero extended
   
   // Local parameters:
   localparam [2:0] r7 = 3'b111;          // last input into mux for R7 selection (7)

   // TODO: instantiate the instruction decoder
   // inputs: instruction[15:11]
   // output: ImmSrc, InvA, InvB, Cin, BSrc, BSel, ALUJmp, MemWrt, RegSrc, ConstSel, ALUOpr, ZeroExt, RegDst, createDump, enableMem
   instructiondecoder decoder(.opcode(instruction[15:11]), .funcode(instruction[1:0]), .ALUJmp(ALUJmp), .MemWrt(MemWrt), .InvB(InvB), .RegSrc(RegSrc), 
      .ImmSrc(ImmSrc), .InvA(InvA), .Cin(Cin), .RegWrt(RegWrt), .BSrc(BSrc), .ZeroExt(ZeroExt), .ALUOpr(ALUOpr), .ConstSel(ConstSel), .RegDst(RegDst), 
      .BSel(BSel), .createDump(createDump), .enableMem(enableMem));

   // instantiate the register file
   // TODO: add err signal export
   wire err;
   regFile rf (.clk(clk), .rst(rst), 
               .read1RegSel(instruction[10:8]), .read2RegSel(instruction[7:5]), 
               .writeRegSel(write_register), .writeData(write_data), .writeEn(RegWrt), 
               .read1Data(read_data_1), .read2Data(read_data_2), .err(err));

   // RegDst mux for write register select input
   assign write_register = (RegDst == 2'b00) ? (instruction[7:5]) :
                           (RegDst == 2'b01) ? (instruction[10:8]) :
                           (RegDst == 2'b10) ? (instruction[4:2]) :
                           (r7); // we default to writing to r7 when RegDst == 2'b11
   
   // zero/sign extend the lower 5 bits of instruction to 16 bits based on ZeroExt signal
   assign instruction_lower_5_SE = {{11{instruction[4]}}, instruction[4:0]};
   assign instruction_lower_5_ZE = {{11{1'b0}}, instruction[4:0]};
   assign instruction_lower_5_ext = (ZeroExt) ? instruction_lower_5_ZE : instruction_lower_5_SE;

   // zero/sign extend the lower 8 bits of instruction to 16 bits based on ZeroExt signal
   assign instruction_lower_8_SE = {{8{instruction[7]}}, instruction[7:0]};
   assign instruction_lower_8_ZE = {{8{1'b0}}, instruction[7:0]};
   assign instruction_lower_8_ext = (ZeroExt) ? instruction_lower_8_ZE : instruction_lower_8_SE;

   // sign extend the lower 11 bits of instruction to 16 bits
   assign instruction_lower_11_ext = {{5{instruction[10]}}, instruction[10:0]};

   // TODO: build the ALU operation block
   ALU_operation iALUOp(.opcode(instruction[15:11]), .func(instruction[1:0]), .ALU_mode(ALUOp));

endmodule
