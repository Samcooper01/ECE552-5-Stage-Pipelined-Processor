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

   // any universal signals that don't belong to a stage
   wire hazard;
   wire control_hazard;
   wire nop_pc;

   // fetch stage signals
   wire [15:0] instruction_fetch;
   wire [15:0] pc_plus_two_fetch;
   wire enableMem_fetch;
   wire [2:0] write_register_fetch;
   wire valid_fetch;
   wire instruction_err_fetch;

   // decode stage signals
   wire [15:0] instruction_decode;
   wire [15:0] pc_plus_two_decode;
   wire ImmSrc_decode;
   wire InvA_decode;
   wire InvB_decode;
   wire Cin_decode;
   wire [1:0] BSrc_decode;
   wire BSel_decode;
   wire ALUJmp_decode;
   wire MemWrt_decode;
   wire [1:0] RegSrc_decode;
   wire [1:0] ConstSel_decode;
   wire createDump_decode;
   wire enableMem_decode;
   wire [3:0] ALUOp_decode;
   wire [15:0] read_data_1_decode;
   wire [15:0] read_data_2_decode;
   wire [15:0] instruction_lower_5_ext_decode;
   wire [15:0] instruction_lower_8_ext_decode;
   wire [15:0] instruction_lower_11_ext_decode;
   wire [2:0] write_register_decode;
   wire halt_decode;
   wire valid_decode;
   wire RegWrt_decode;
   wire [15:0] instruction_decode_stage;
   wire [15:0] pc_fetch;
   wire instruction_err_decode;


   // execute stage signals
   wire [15:0] instruction_execute;
   wire [15:0] pc_plus_two_execute;
   wire ImmSrc_execute;
   wire ImmJmp_execute;
   wire InvA_execute;
   wire InvB_execute;
   wire Cin_execute;
   wire [1:0] BSrc_execute;
   wire BSel_execute;
   wire ALUJmp_execute;
   wire MemWrt_execute;
   wire [1:0] RegSrc_execute;
   wire [1:0] ConstSel_execute;
   wire createDump_execute;
   wire enableMem_execute;
   wire [3:0] ALUOp_execute;
   wire [15:0] read_data_1_execute;
   wire [15:0] read_data_2_execute;
   wire [15:0] instruction_lower_5_ext_execute;
   wire [15:0] instruction_lower_8_ext_execute;
   wire [15:0] instruction_lower_11_ext_execute;
   wire [15:0] ALU_output_execute;
   wire [15:0] ALU_input_2_execute;
   wire [15:0] SLBI_concat_execute;
   wire [2:0] write_register_execute;
   wire halt_execute;
   wire valid_execute;
   wire RegWrt_execute;
   wire instruction_err_execute;

   // memory stage signals
   wire [15:0] instruction_memory;
   wire [15:0] pc_plus_two_memory;
   wire ImmSrc_memory;
   wire ALUJmp_memory;
   wire MemWrt_memory;
   wire [1:0] RegSrc_memory;
   wire [1:0] ConstSel_memory;
   wire createDump_memory;
   wire enableMem_memory;
   wire [15:0] read_data_2_memory;
   wire [15:0] instruction_lower_8_ext_memory;
   wire [15:0] instruction_lower_11_ext_memory;
   wire ImmJmp_memory;
   wire [15:0] ALU_output_memory;
   wire [15:0] SLBI_concat_memory;
   wire [15:0] read_data_memory;
   wire [15:0] ConstSel_mux_memory;
   wire [15:0] jump_adder_output_memory;
   wire [2:0] write_register_memory;
   wire halt_memory;
   wire valid_memory;
   wire RegWrt_memory;
   wire instruction_err_memory;
   wire memory_err_memory;

   // writeback stage signals
   wire [15:0] instruction_wb;
   wire [15:0] pc_plus_two_wb;
   wire ALUJmp_wb;
   wire ImmJmp_wb;
   wire [1:0] RegSrc_wb;
   wire [15:0] ALU_output_wb;
   wire [15:0] read_data_wb;
   wire [15:0] ConstSel_mux_wb;
   wire [15:0] jump_adder_output_wb;
   wire [15:0] next_pc_wb;
   wire [15:0] write_data_wb;
   wire [2:0] write_register_wb;
   wire halt_wb;
   wire valid_wb;
   wire RegWrt_wb;
   wire instruction_err_wb;
   wire memory_err_wb;
   wire halt_wb_final;
   assign halt_wb_final = halt_wb | memory_err_wb | instruction_err_wb;


   // instantiate the fetch stage
   fetch fetch_inst (.clk(clk), 
                     .rst(rst), 
                     .hazard(hazard), 
                     .control_hazard(control_hazard), 
                     .next_pc(next_pc_wb), 
                     .instruction(instruction_fetch), 
                     .pc_plus_two(pc_plus_two_fetch), 
                     .enableMem(enableMem_fetch), 
                     .halt(halt_wb_final), 
                     .valid(valid_fetch),
                     .nop_pc(nop_pc),
                     .ImmJmp(ImmJmp_wb),
                     .pc(pc_fetch),
                     .instruction_wb(instruction_wb),
                     .instruction_err(instruction_err_fetch)
                     );

   // instantiate the fetch - decode latch -- hazard being HIGH will hold the output steady
   FD_latch FD_latch_inst (.clk(clk), 
                           .rst(rst), 
                           .hazard(hazard), 
                           .pc_plus_two_i(pc_plus_two_fetch), 
                           .instruction_i(instruction_fetch), 
                           .valid_i(valid_fetch),
                           .instruction_err_i(instruction_err_fetch),
                           .pc_plus_two_o(pc_plus_two_decode), 
                           .instruction_o(instruction_decode), 
                           .valid_o(valid_decode),
                           .instruction_err_o(instruction_err_decode)
                           );

   // hazard detection unit 
   // inputs: instruction_decode, instruction_execute, instruction_memory, instruction_wb
   // outputs: hazard (data hazard detected in one of the last 3 stages), jump (jump detected in the last 3 stages)
   hazard_detector iHazardDetector( .instr_decode(instruction_decode), 
                                    .instr_execute(instruction_execute), 
                                    .instr_memory(instruction_memory), 
                                    .instr_wb(instruction_wb), 
                                    .control_hazard(control_hazard), 
                                    .hazard(hazard));

   // instantiate the decode stage
   decode decode_inst ( 
                        //Inputs
                        .clk(clk), 
                        .rst(rst), 
                        .instruction(instruction_decode), 
                        .write_data(write_data_wb), 
                        .RegWrt_wb(RegWrt_wb),
                        //outputs
                        .ImmSrc(ImmSrc_decode), 
                        .InvA(InvA_decode), 
                        .InvB(InvB_decode), 
                        .Cin(Cin_decode), 
                        .BSrc(BSrc_decode), 
                        .BSel(BSel_decode), 
                        .ALUJmp(ALUJmp_decode), 
                        .MemWrt(MemWrt_decode), 
                        .RegSrc(RegSrc_decode), 
                        .ConstSel(ConstSel_decode), 
                        .ALUOp(ALUOp_decode), 
                        .enableMem(enableMem_decode), 
                        .createDump(createDump_decode), 
                        .read_data_1(read_data_1_decode), 
                        .read_data_2(read_data_2_decode), 
                        .instruction_lower_5_ext(instruction_lower_5_ext_decode), 
                        .instruction_lower_8_ext(instruction_lower_8_ext_decode), 
                        .instruction_lower_11_ext(instruction_lower_11_ext_decode), 
                        .hazard(hazard), 
                        .write_register_in(write_register_wb), 
                        .write_register(write_register_decode), 
                        .halt(halt_decode), 
                        .valid_wb(valid_wb),
                        .RegWrt(RegWrt_decode),
                        .instruction_decode_stage(instruction_decode_stage)
                        );

   // instantiate the decode - execute latch
   DE_latch DE_latch_inst (.clk(clk), 
                           .rst(rst), 
                           .instruction_i(instruction_decode_stage), 
                           .pc_plus_two_i(pc_plus_two_decode), 
                           .ImmSrc_i(ImmSrc_decode), 
                           .InvA_i(InvA_decode), 
                           .InvB_i(InvB_decode), 
                           .Cin_i(Cin_decode), 
                           .Bsrc_i(BSrc_decode), 
                           .BSel_i(BSel_decode), 
                           .ALUJmp_i(ALUJmp_decode), 
                           .MemWrt_i(MemWrt_decode), 
                           .RegSrc_i(RegSrc_decode), 
                           .ConstSel_i(ConstSel_decode), 
                           .createDump_i(createDump_decode), 
                           .enableMem_i(enableMem_decode), 
                           .ALUOp_i(ALUOp_decode), 
                           .read_data_1_i(read_data_1_decode), 
                           .read_data_2_i(read_data_2_decode), 
                           .instruction_lower_5_ext_i(instruction_lower_5_ext_decode), 
                           .instruction_lower_8_ext_i(instruction_lower_8_ext_decode), 
                           .instruction_lower_11_ext_i(instruction_lower_11_ext_decode), 
                           .write_register_i(write_register_decode), 
                           .halt_i(halt_decode), 
                           .valid_i(valid_decode),
                           .instruction_err_i(instruction_err_decode), // signal inputs
                           .instruction_o(instruction_execute), 
                           .pc_plus_two_o(pc_plus_two_execute), 
                           .ImmSrc_o(ImmSrc_execute), 
                           .InvA_o(InvA_execute), 
                           .InvB_o(InvB_execute), 
                           .Cin_o(Cin_execute), 
                           .Bsrc_o(BSrc_execute), 
                           .BSel_o(BSel_execute), 
                           .ALUJmp_o(ALUJmp_execute), 
                           .MemWrt_o(MemWrt_execute), 
                           .RegSrc_o(RegSrc_execute), 
                           .ConstSel_o(ConstSel_execute), 
                           .createDump_o(createDump_execute), 
                           .enableMem_o(enableMem_execute), 
                           .ALUOp_o(ALUOp_execute), 
                           .read_data_1_o(read_data_1_execute), 
                           .read_data_2_o(read_data_2_execute), 
                           .instruction_lower_5_ext_o(instruction_lower_5_ext_execute),
                           .instruction_lower_8_ext_o(instruction_lower_8_ext_execute), 
                           .instruction_lower_11_ext_o(instruction_lower_11_ext_execute), 
                           .write_register_o(write_register_execute), 
                           .halt_o(halt_execute), 
                           .valid_o(valid_execute),
                           .RegWrt_i(RegWrt_decode),
                           .RegWrt_o(RegWrt_execute),
                           .instruction_err_o(instruction_err_execute)
                           ); // signal outputs

   // instantiate the execute stage
   execute execute_inst (  .clk(clk), 
                           .rst(rst), 
                           .BSrc(BSrc_execute), 
                           .BSel(BSel_execute),
                           .Cin(Cin_execute), 
                           .InvA(InvA_execute), 
                           .InvB(InvB_execute), 
                           .ALUOp(ALUOp_execute), 
                           .opcode(instruction_execute[15:11]), 
                           .read_data_1(read_data_1_execute), 
                           .read_data_2(read_data_2_execute), 
                           .instruction_lower_5_ext(instruction_lower_5_ext_execute), 
                           .instruction_lower_8_ext(instruction_lower_8_ext_execute), 
                           .instruction_lower_8(instruction_execute[7:0]), 
                           .ImmJmp(ImmJmp_execute), 
                           .ALU_output(ALU_output_execute), 
                           .ALU_input_2(ALU_input_2_execute), 
                           .SLBI_concat(SLBI_concat_execute));

   // instantiate the execute - memory latch
   EM_latch EM_latch_inst (.clk(clk), 
                           .rst(rst), 
                           .pc_plus_two_i(pc_plus_two_execute), 
                           .ImmSrc_i(ImmSrc_execute), 
                           .ALUJmp_i(ALUJmp_execute), 
                           .MemWrt_i(MemWrt_execute), 
                           .RegSrc_i(RegSrc_execute), 
                           .ConstSel_i(ConstSel_execute), 
                           .createDump_i(createDump_execute), 
                           .enableMem_i(enableMem_execute), 
                           .read_data_2_i(read_data_2_execute), 
                           .instruction_lower_8_ext_i(instruction_lower_8_ext_execute), 
                           .instruction_lower_11_ext_i(instruction_lower_11_ext_execute), 
                           .ImmJmp_i(ImmJmp_execute), 
                           .ALU_output_i(ALU_output_execute), 
                           .SLBI_concat_i(SLBI_concat_execute), 
                           .instruction_i(instruction_execute), 
                           .write_register_i(write_register_execute), 
                           .halt_i(halt_execute), 
                           .valid_i(valid_execute),
                           .instruction_err_i(instruction_err_execute), // signal inputs
                           .pc_plus_two_o(pc_plus_two_memory), 
                           .ImmSrc_o(ImmSrc_memory), 
                           .ALUJmp_o(ALUJmp_memory), 
                           .MemWrt_o(MemWrt_memory), 
                           .RegSrc_o(RegSrc_memory), 
                           .ConstSel_o(ConstSel_memory), 
                           .createDump_o(createDump_memory), 
                           .enableMem_o(enableMem_memory), 
                           .read_data_2_o(read_data_2_memory), 
                           .instruction_lower_8_ext_o(instruction_lower_8_ext_memory), 
                           .instruction_lower_11_ext_o(instruction_lower_11_ext_memory), 
                           .ImmJmp_o(ImmJmp_memory), 
                           .ALU_output_o(ALU_output_memory), 
                           .SLBI_concat_o(SLBI_concat_memory), 
                           .instruction_o(instruction_memory), 
                           .write_register_o(write_register_memory), 
                           .halt_o(halt_memory), 
                           .valid_o(valid_memory),
                           .RegWrt_i(RegWrt_execute),
                           .RegWrt_o(RegWrt_memory),
                           .instruction_err_o(instruction_err_memory)
                           ); // signal outputs


   // instantiate the memory stage
   memory memory_inst ( .clk(clk), 
                        .rst(rst), 
                        .ImmSrc(ImmSrc_memory), 
                        .MemWrt(MemWrt_memory), 
                        .ConstSel(ConstSel_memory), 
                        .createDump(createDump_memory), 
                        .enableMem(enableMem_memory), 
                        .pc_plus_two(pc_plus_two_memory), 
                        .ALU_output(ALU_output_memory), 
                        .SLBI_concat(SLBI_concat_memory), 
                        .read_data_2(read_data_2_memory), 
                        .instruction_lower_8_ext(instruction_lower_8_ext_memory), 
                        .instruction_lower_11_ext(instruction_lower_11_ext_memory), 
                        .read_data(read_data_memory), 
                        .ConstSel_mux(ConstSel_mux_memory), 
                        .jump_adder_output(jump_adder_output_memory),
                        .memory_err(memory_err_memory));

   // instantiate the memory - writeback latch
   MW_latch MW_latch_inst (.clk(clk), 
                           .rst(rst), // latch control
                           .pc_plus_two_i(pc_plus_two_memory), 
                           .ALUJmp_i(ALUJmp_memory), 
                           .RegSrc_i(RegSrc_memory), 
                           .ALU_output_i(ALU_output_memory), 
                           .read_data_i(read_data_memory), 
                           .ConstSel_mux_i(ConstSel_mux_memory), 
                           .jump_adder_output_i(jump_adder_output_memory), 
                           .instruction_i(instruction_memory), 
                           .write_register_i(write_register_memory), 
                           .halt_i(halt_memory), 
                           .valid_i(valid_memory), 
                           .ImmJmp_i(ImmJmp_memory),
                           .instruction_err_i(instruction_err_memory),
                           .memory_err_i(memory_err_memory), // signal inputs
                           .pc_plus_two_o(pc_plus_two_wb), 
                           .ALUJmp_o(ALUJmp_wb), 
                           .RegSrc_o(RegSrc_wb), 
                           .ALU_output_o(ALU_output_wb), 
                           .read_data_o(read_data_wb), 
                           .ConstSel_mux_o(ConstSel_mux_wb), 
                           .jump_adder_output_o(jump_adder_output_wb), 
                           .instruction_o(instruction_wb), 
                           .write_register_o(write_register_wb), 
                           .halt_o(halt_wb), 
                           .valid_o(valid_wb),
                           .ImmJmp_o(ImmJmp_wb),
                           .RegWrt_i(RegWrt_memory),
                           .RegWrt_o(RegWrt_wb),
                           .instruction_err_o(instruction_err_wb),
                           .memory_err_o(memory_err_wb) // signal outputs
                           );




   // instantiate the writeback stage
   wb wb_inst (   .clk(clk), 
                  .rst(rst), 
                  .ALUJmp(ALUJmp_wb), 
                  .RegSrc(RegSrc_wb), 
                  .ALU_output(ALU_output_wb), 
                  .pc_plus_two(pc_plus_two_fetch),
                  .pc(pc_fetch),
                  .read_data(read_data_wb), 
                  .ConstSel_mux(ConstSel_mux_wb), 
                  .ImmJmp(ImmJmp_wb), 
                  .jump_adder_output(jump_adder_output_wb), 
                  .next_pc(next_pc_wb), 
                  .write_data(write_data_wb));

   // DEMO 1 CODE FOR REFERENCE
   // // instantiate the fetch module
   // wire [15:0] next_pc;
   // wire [15:0] instruction;
   // wire [15:0] pc_plus_two;
   // wire enableMem;

   // fetch fetch_inst (.clk(clk), .rst(rst), .next_pc(next_pc), .instruction(instruction), .pc_plus_two(pc_plus_two), .enableMem(enableMem));

   // // instantiate the decode module
   // wire ImmSrc;
   // wire InvA;
   // wire InvB;
   // wire Cin;
   // wire [1:0] BSrc;
   // wire BSel;
   // wire ImmJmp;
   // wire ALUJmp;
   // wire MemWrt;
   // wire [15:0] write_data;
   // wire [1:0] RegSrc;
   // wire [1:0] ConstSel;
   // wire [3:0] ALUOp;
   // wire createDump;
   // wire [15:0] read_data_1;
   // wire [15:0] read_data_2;
   // wire [15:0] instruction_lower_5_ext;
   // wire [15:0] instruction_lower_8_ext;
   // wire [15:0] instruction_lower_11_ext;

   // decode decode_inst (.clk(clk), .rst(rst), .instruction(instruction), .write_data(write_data), .ImmSrc(ImmSrc), .InvA(InvA), .InvB(InvB), .Cin(Cin), .BSrc(BSrc), 
   //                     .BSel(BSel), .ALUJmp(ALUJmp), .MemWrt(MemWrt), .RegSrc(RegSrc), .ConstSel(ConstSel), .ALUOp(ALUOp), 
   //                     .enableMem(enableMem), .createDump(createDump), .read_data_1(read_data_1), .read_data_2(read_data_2), 
   //                     .instruction_lower_5_ext(instruction_lower_5_ext), .instruction_lower_8_ext(instruction_lower_8_ext), 
   //                     .instruction_lower_11_ext(instruction_lower_11_ext));

   // // instantiate the execute module

   // wire [15:0] ALU_output;
   // wire [15:0] ALU_input_2;
   // wire [15:0] SLBI_concat;

   // execute execute_inst (.clk(clk), .rst(rst), .BSrc(BSrc), .BSel(BSel), .Cin(Cin), .InvA(InvA), .InvB(InvB), .ALUOp(ALUOp), .opcode(instruction[15:11]), 
   //                       .read_data_1(read_data_1), .read_data_2(read_data_2), .instruction_lower_5_ext(instruction_lower_5_ext), 
   //                       .instruction_lower_8_ext(instruction_lower_8_ext), .instruction_lower_8(instruction[7:0]), .ImmJmp(ImmJmp), 
   //                       .ALU_output(ALU_output), .ALU_input_2(ALU_input_2), .SLBI_concat(SLBI_concat));

   // // instantiate the memory module

   // wire [15:0] read_data;
   // wire [15:0] ConstSel_mux;
   // wire [15:0] ImmJmp_mux;

   // memory memory_inst (.clk(clk), .rst(rst), .ImmSrc(ImmSrc), .ImmJmp(ImmJmp), .MemWrt(MemWrt), .ConstSel(ConstSel), .createDump(createDump), 
   //                     .enableMem(enableMem), .pc_plus_two(pc_plus_two), .ALU_output(ALU_output), .SLBI_concat(SLBI_concat), .read_data_2(read_data_2), 
   //                     .instruction_lower_8_ext(instruction_lower_8_ext), .instruction_lower_11_ext(instruction_lower_11_ext), .read_data(read_data), 
   //                     .ConstSel_mux(ConstSel_mux), .ImmJmp_mux(ImmJmp_mux));
   
   // // instantiate the wb module

   // wb wb_inst (.clk(clk), .rst(rst), .ALUJmp(ALUJmp), .RegSrc(RegSrc), .ALU_output(ALU_output), .pc_plus_two(pc_plus_two), .read_data(read_data), 
   //             .ConstSel_mux(ConstSel_mux), .ImmJmp_mux(ImmJmp_mux), .next_pc(next_pc), .write_data(write_data));
   
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
