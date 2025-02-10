/* $Author: sinclair $ */
/* $LastChangedDate: 2020-02-09 17:03:45 -0600 (Sun, 09 Feb 2020) $ */
/* $Rev: 46 $ */
module proc (/*AUTOARG*/
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input wire clk;
   input wire rst;

   output reg err;

   // None of the above lines can be modified

   // OR all the err ouputs for every sub-module and assign it as this
   // err output
   
   // As desribed in the homeworks, use the err signal to trap corner
   // cases that you think are illegal in your statemachines
   
   /* your code here -- should include instantiations of fetch, decode, execute, mem and wb modules */

   // instantiate the fetch module
   wire [15:0] next_pc;
   wire [15:0] instruction;
   wire [15:0] pc_plus_two;
   wire enableMem;

   fetch fetch_inst (.clk(clk), .rst(rst), .next_pc(next_pc), .instruction(instruction), .pc_plus_two(pc_plus_two), .enableMem(enableMem));

   // instantiate the decode module
   wire ImmSrc;
   wire InvA;
   wire InvB;
   wire Cin;
   wire [1:0] BSrc;
   wire BSel;
   wire ImmJmp;
   wire ALUJmp;
   wire MemWrt;
   wire [15:0] write_data;
   wire [1:0] RegSrc;
   wire [1:0] ConstSel;
   wire [3:0] ALUOp;
   wire createDump;
   wire [15:0] read_data_1;
   wire [15:0] read_data_2;
   wire [15:0] instruction_lower_5_ext;
   wire [15:0] instruction_lower_8_ext;
   wire [15:0] instruction_lower_11_ext;

   decode decode_inst (.clk(clk), .rst(rst), .instruction(instruction), .write_data(write_data), .ImmSrc(ImmSrc), .InvA(InvA), .InvB(InvB), .Cin(Cin), .BSrc(BSrc), 
                       .BSel(BSel), .ALUJmp(ALUJmp), .MemWrt(MemWrt), .RegSrc(RegSrc), .ConstSel(ConstSel), .ALUOp(ALUOp), 
                       .enableMem(enableMem), .createDump(createDump), .read_data_1(read_data_1), .read_data_2(read_data_2), 
                       .instruction_lower_5_ext(instruction_lower_5_ext), .instruction_lower_8_ext(instruction_lower_8_ext), 
                       .instruction_lower_11_ext(instruction_lower_11_ext));

   // instantiate the execute module

   wire [15:0] ALU_output;
   wire [15:0] ALU_input_2;
   wire [15:0] SLBI_concat;

   execute execute_inst (.clk(clk), .rst(rst), .BSrc(BSrc), .BSel(BSel), .Cin(Cin), .InvA(InvA), .InvB(InvB), .ALUOp(ALUOp), .opcode(instruction[15:11]), 
                         .read_data_1(read_data_1), .read_data_2(read_data_2), .instruction_lower_5_ext(instruction_lower_5_ext), 
                         .instruction_lower_8_ext(instruction_lower_8_ext), .instruction_lower_8(instruction[7:0]), .ImmJmp(ImmJmp), 
                         .ALU_output(ALU_output), .ALU_input_2(ALU_input_2), .SLBI_concat(SLBI_concat));

   // instantiate the memory module

   wire [15:0] read_data;
   wire [15:0] ConstSel_mux;
   wire [15:0] ImmJmp_mux;

   memory memory_inst (.clk(clk), .rst(rst), .ImmSrc(ImmSrc), .ImmJmp(ImmJmp), .MemWrt(MemWrt), .ConstSel(ConstSel), .createDump(createDump), 
                       .enableMem(enableMem), .pc_plus_two(pc_plus_two), .ALU_output(ALU_output), .SLBI_concat(SLBI_concat), .read_data_2(read_data_2), 
                       .instruction_lower_8_ext(instruction_lower_8_ext), .instruction_lower_11_ext(instruction_lower_11_ext), .read_data(read_data), 
                       .ConstSel_mux(ConstSel_mux), .ImmJmp_mux(ImmJmp_mux));
   
   // instantiate the wb module

   wb wb_inst (.clk(clk), .rst(rst), .ALUJmp(ALUJmp), .RegSrc(RegSrc), .ALU_output(ALU_output), .pc_plus_two(pc_plus_two), .read_data(read_data), 
               .ConstSel_mux(ConstSel_mux), .ImmJmp_mux(ImmJmp_mux), .next_pc(next_pc), .write_data(write_data));
   
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
