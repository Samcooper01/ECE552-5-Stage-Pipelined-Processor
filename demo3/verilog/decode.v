/*
   CS/ECE 552 Spring '22
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
module decode (clk, rst, instruction, write_data, write_register_in, hazard, valid_wb, // inputs
               ImmSrc, InvA, InvB, Cin, BSrc, BSel, ALUJmp, MemWrt, RegSrc, ConstSel, ALUOp, enableMem, createDump, halt,// control signal outputs
               read_data_1, read_data_2, instruction_lower_5_ext, instruction_lower_8_ext, instruction_lower_11_ext, write_register, RegWrt, RegWrt_wb, instruction_decode_stage); // data outputs

   // Inputs:
   input wire clk;                     // the clock signal for registers
   input wire rst;                     // the reset signal for registers
   input wire hazard;                  // for zeroing the control signals
   input wire [15:0] instruction;      // the input of the instruction memory block
   input wire [15:0] write_data;
   input wire [2:0] write_register_in;  // the input from the writeback stage
   input wire valid_wb;
   input wire RegWrt_wb;

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
   output wire [2:0] write_register;             // the register to be written to in reg file, propogated through WB
   output wire halt;
   output wire RegWrt;                           // internal control signal

   // Pre-muxed control signals for NOP insertion
   wire premux_ImmSrc;        // generated from decoder
   wire premux_InvA;          // generated from decoder
   wire premux_InvB;          // generated from decoder
   wire premux_Cin;           // generated from decoder
   wire [1:0] premux_BSrc;    // generated from decoder
   wire premux_BSel;          // generated from decoder
   wire premux_ALUJmp;        // generated from decoder
   wire premux_MemWrt;        // generated from decoder
   wire [1:0] premux_RegSrc;  // generated from decoder
   wire [1:0] premux_ConstSel;// generated from decoder
   wire premux_createDump;    // generated from decoder
   wire premux_enableMem;     // generated from decoder
   wire premux_RegWrt;        // generated from decoder

   // Internal wires:
   wire ZeroExt;                             // internal control signal
   wire [1:0] RegDst;                          // internal control signal      
   wire [4:0] ALUOpr;                           // internal control signal
   wire [15:0] instruction_lower_5_SE;    // lower 5 bits of instruction sign extended 
   wire [15:0] instruction_lower_5_ZE;    // lower 5 bits of instruction zero extended
   wire [15:0] instruction_lower_8_SE;    // lower 8 bits of instruction sign extended
   wire [15:0] instruction_lower_8_ZE;    // lower 8 bits of instruction zero extended
   
   // Local parameters:
   localparam [2:0] r7 = 3'b111;          // last input into mux for R7 selection (7)

   // TODO: instantiate the instruction decoder
   // inputs: instruction[15:11]
   // output: ImmSrc, InvA, InvB, Cin, BSrc, BSel, ALUJmp, MemWrt, RegSrc, ConstSel, ALUOpr, ZeroExt, RegDst, createDump, enableMem
   instructiondecoder decoder(.opcode(instruction[15:11]), .funcode(instruction[1:0]), .ALUJmp(premux_ALUJmp), .MemWrt(premux_MemWrt), .InvB(premux_InvB), .RegSrc(premux_RegSrc), 
      .ImmSrc(premux_ImmSrc), .InvA(premux_InvA), .Cin(premux_Cin), .RegWrt(premux_RegWrt), .BSrc(premux_BSrc), .ZeroExt(ZeroExt), .ALUOpr(ALUOpr), .ConstSel(premux_ConstSel), .RegDst(RegDst), 
      .BSel(premux_BSel), .createDump(premux_createDump), .enableMem(premux_enableMem), .halt(halt), .valid_wb(valid_wb));

   // instantiate the register file
   // TODO: add err signal export
   wire err;
   regFile_bypass rf (.clk(clk), .rst(rst), 
               .read1RegSel(instruction[10:8]), .read2RegSel(instruction[7:5]), 
               .writeRegSel(write_register_in), .writeData(write_data), .writeEn(RegWrt_wb), 
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

   // build the ALU operation block
   ALU_operation iALUOp(.opcode(instruction[15:11]), .func(instruction[1:0]), .ALU_mode(ALUOp));

   // Muxes for the exported control signals based on the hazard signal
   assign ImmSrc = (hazard) ? 1'b0 : premux_ImmSrc;
   assign InvA = (hazard) ? 1'b0 : premux_InvA;
   assign InvB = (hazard) ? 1'b0 : premux_InvB;
   assign Cin = (hazard) ? 1'b0 : premux_Cin;
   assign BSrc = (hazard) ? 2'b00 : premux_BSrc;
   assign BSel = (hazard) ? 1'b0 : premux_BSel;
   assign ALUJmp = (hazard) ? 1'b0 : premux_ALUJmp;
   assign MemWrt = (hazard) ? 1'b0 : premux_MemWrt;
   assign RegSrc = (hazard) ? 2'b00 : premux_RegSrc;
   assign ConstSel = (hazard) ? 2'b00 : premux_ConstSel;
   assign createDump = (hazard) ? 1'b0 : premux_createDump;
   assign enableMem = (hazard) ? 1'b0 : premux_enableMem;
   assign RegWrt = (hazard) ? 1'b0 : premux_RegWrt;

   output wire [15:0] instruction_decode_stage;
   assign instruction_decode_stage = (hazard) ? 16'h0800 : instruction;

endmodule
