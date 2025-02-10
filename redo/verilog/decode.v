/*
   CS/ECE 552 Spring '22
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
module decode (
   // Inputs: 
   clk, rst, instruction, WriteData, valid_wb, WrtEn, rf_write_reg_i, pc_plus_two_fetch, pc_plus_two,
   // Outputs:
   ImmSrc, InvA, InvB, Cin, BSrc, BSel, ALUJmp, MemWrt, RegSrc, ConstSel, ALUOp, enableMem, 
   createDump, RegWrt, halt, rf_write_reg_o, read_data_1, read_data_2, instruction_ext_5, instruction_ext_8, 
   instruction_ext_11, next_pc, branch_jump_taken
   ); 

   // Inputs:
   input wire clk;
   input wire rst;
   input wire [15:0] instruction;
   input wire WrtEn;                            // Enable signal for RF - comes from WB stage
   input wire [15:0] WriteData;                 // Data to be written to RF - comes from WB stage
   input wire [2:0] rf_write_reg_i;             // Register to be written to in RF - comes from WB stage
   input wire valid_wb;                         // TODO
   input wire [15:0] pc_plus_two_fetch;         // NEW
   input wire [15:0] pc_plus_two;               // NEW
   //input wire halt_wb;                        // TODO

   // Outputs:
   output wire ImmSrc;                          /* Control Signals from the decoder */
   output wire InvA;                        
   output wire InvB;                      
   output wire Cin;                          
   output wire [1:0] BSrc;                                       
   output wire BSel;                         
   output wire ALUJmp;                       
   output wire MemWrt;                      
   output wire halt;
   output wire [1:0] RegSrc;                   
   output wire [1:0] ConstSel;                
   output wire createDump;          
   output wire RegWrt;                            
   output wire enableMem;                       /* End of Control Signals */ 
   output wire [3:0] ALUOp;             // ALU operation generated by the ALU operation block 
   output wire [15:0] read_data_1;              // First data input to the RF
   output wire [15:0] read_data_2;              // Second data input to the RF  
   output wire [15:0] instruction_ext_5;        // Lower 5 bits of instruction either SE or ZE
   output wire [15:0] instruction_ext_8;        // Lower 8 bits of instruction either SE or ZE
   output wire [15:0] instruction_ext_11;       // Lower 11 bits of instruction SE
   output wire [2:0] rf_write_reg_o;
   output wire [15:0] next_pc;
   output wire branch_jump_taken;

   // Internal wires:
   wire ZeroExt;                             // internal control signal
   wire LBI_forward;
   wire Reg_write;
   wire [1:0] RegDst;                          // internal control signal      
   wire [4:0] ALUOpr;                           // internal control signal
   wire [2:0] write_register;             // the register to be written to in reg file
   wire [15:0] instruction_lower_5_SE;    // lower 5 bits of instruction sign extended 
   wire [15:0] instruction_lower_5_ZE;    // lower 5 bits of instruction zero extended
   wire [15:0] instruction_lower_8_SE;    // lower 8 bits of instruction sign extended
   wire [15:0] instruction_lower_8_ZE;    // lower 8 bits of instruction zero extended
   wire [2:0] write_reg_sel;    
   wire [15:0] write_data_sel, SLBI_concat, read_data_1_slbi;
   wire bypass_en;
   // New
   wire [15:0] jump_adder_output, adder_output, Immsrc_mux, Immjmp_mux;
   // Local parameters:
   localparam [2:0] r7 = 3'b111;          // last input into mux for R7 selection (7)

   // TODO: instantiate the instruction decoder
   // inputs: instruction[15:11]
   // output: ImmSrc, InvA, InvB, Cin, BSrc, BSel, ALUJmp, MemWrt, RegSrc, ConstSel, ALUOpr, ZeroExt, RegDst, createDump, enableMem
   instructiondecoder decoder(.opcode(instruction[15:11]), .funcode(instruction[1:0]), .ALUJmp(ALUJmp), .MemWrt(MemWrt), .InvB(InvB), .RegSrc(RegSrc), 
      .ImmSrc(ImmSrc), .InvA(InvA), .Cin(Cin), .RegWrt(RegWrt), .BSrc(BSrc), .ZeroExt(ZeroExt), .ALUOpr(ALUOpr), .ConstSel(ConstSel), .RegDst(RegDst), 
      .BSel(BSel), .createDump(createDump), .enableMem(enableMem), .halt(halt), .valid_wb(valid_wb), .LBI_forward(LBI_forward));

   // instantiate the register file
   // TODO: add err signal export
   wire err;
   regFile_bypass rf (.clk(clk), .rst(rst), 
               .read1RegSel(instruction[10:8]), .read2RegSel(instruction[7:5]), 
               .writeRegSel(write_reg_sel), .writeData(write_data_sel), .writeEn(Reg_write), 
               .read1Data(read_data_1), .read2Data(read_data_2), .err(err), .bypass_en(bypass_en));

   // RegDst mux for write register select input
   assign rf_write_reg_o  = (RegDst == 2'b00) ? (instruction[7:5]) :
                           (RegDst == 2'b01) ? (instruction[10:8]) :
                           (RegDst == 2'b10) ? (instruction[4:2]) :
                           (r7); // we default to writing to r7 when RegDst == 2'b11
   
   // zero/sign extend the lower 5 bits of instruction to 16 bits based on ZeroExt signal
   assign instruction_lower_5_SE = {{11{instruction[4]}}, instruction[4:0]};
   assign instruction_lower_5_ZE = {{11{1'b0}}, instruction[4:0]};
   assign instruction_ext_5 = (ZeroExt) ? instruction_lower_5_ZE : instruction_lower_5_SE;

   // zero/sign extend the lower 8 bits of instruction to 16 bits based on ZeroExt signal
   assign instruction_lower_8_SE = {{8{instruction[7]}}, instruction[7:0]};
   assign instruction_lower_8_ZE = {{8{1'b0}}, instruction[7:0]};
   assign instruction_ext_8 = (ZeroExt) ? instruction_lower_8_ZE : instruction_lower_8_SE;

   // sign extend the lower 11 bits of instruction to 16 bits
   assign instruction_ext_11 = {{5{instruction[10]}}, instruction[10:0]};

   // TODO: build the ALU operation block
   ALU_operation iALUOp(.opcode(instruction[15:11]), .func(instruction[1:0]), .ALU_mode(ALUOp));

   assign Reg_write = (LBI_forward) ? 1'b1 : WrtEn;
   assign write_reg_sel =  (LBI_forward) ? instruction[10:8] : rf_write_reg_i;
   assign write_data_sel = (LBI_forward & instruction[15:11] == 5'b11000) ? instruction_lower_8_SE :
                           (LBI_forward & instruction[15:11] == 5'b10010) ? SLBI_concat :
                           WriteData;

   assign SLBI_concat = {read_data_1[7:0], instruction[7:0]};

   assign bypass_en = ((LBI_forward & instruction[15:11] == 5'b11000) | (LBI_forward & instruction[15:11] == 5'b10010)) ? 1'b1 : 1'b0;



   // Moved jump and branch resolutions to the decode stage
   // Branch Conditional Block
   branchCnd branchCnd_inst(.opcode(instruction[15:11]), .rs_register(read_data_1), .instruction_ext_8(instruction_ext_8),
      .immJump(ImmJmp), .adder_output(adder_output), .branch_jump_taken(branch_jump_taken));

   /* NEW BRANCH LOGIC, RESOLVES IN EXECUTE */
   // ImmSrc mux
   assign Immsrc_mux = (ImmSrc) ? instruction_ext_11 : instruction_ext_8;

   // 16-bit adder for the jump address 
   cla_16b iPCinc2(.sum(jump_adder_output), .c_out(), .a(Immsrc_mux), .b(pc_plus_two), .c_in(1'b0));

   // ImmJmp mux
   assign Immjmp_mux = (ImmJmp) ? jump_adder_output : pc_plus_two_fetch;

   // ALUJmp mux
   assign next_pc = (ALUJmp) ? adder_output : Immjmp_mux;



   // ALUOutput is for JR and JALR
   /*
    * JR Rs, Immediate -> 00101 sss iiiiiiii
    *    PC <- Rs + I(sign_extended)   // Put in branchCnd???
    * JALR Rs, Immediate -> 00111 sss iiiiiiii 
    *    R7 <- PC + 2
    *    PC <- Rs + I(sign_extended)
    */


endmodule
