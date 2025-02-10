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

   // FETCH INSTANTIATION //
   wire [15:0] instruction_fetch, pc_plus_two_fetch;
   wire valid_fetch;
   wire instruction_memory_error_fetch;
   wire unaligned_access;

   // DECODE INSTANTIATION //
   wire [15:0] instruction_decode, pc_plus_two_decode, read_data_1_decode, read_data_2_decode, 
      instruction_ext_5_decode, instruction_ext_8_decode, instruction_ext_11_decode, next_pc_decode;
   wire [3:0] ALUOp_decode;
   wire [2:0] rf_write_reg_decode; 
   wire [1:0] BSrc_decode, RegSrc_decode, ConstSel_decode;
   wire ImmSrc_decode, InvA_decode, InvB_decode, Cin_decode, BSel_decode, ALUJmp_decode, 
      MemWrt_decode, halt_decode, createDump_decode, enableMem_decode, RegWrt_decode, valid_decode, branch_jump_taken;
   wire instruction_memory_error_decode;

   // EXECUTE INSTANTIATION //
   wire [15:0] pc_plus_two_execute, instruction_execute, instruction_ext_5_execute, instruction_ext_8_execute, 
      instruction_ext_11_execute, read_data_1_execute, read_data_2_execute, ALU_output_execute, 
      ALU_read_data_2_execute, SLBI_result_execute, next_pc_execute;
   wire [3:0] ALUOp_execute;
   wire [2:0] rf_write_reg_execute;
   wire [1:0] BSrc_execute, RegSrc_execute, ConstSel_execute;
   wire ImmSrc_execute, Cin_execute, Bsel_execute, ALUJmp_execute, InvA_execute, InvB_execute, valid_execute,
      BSel_execute, MemWrt_execute, createDump_execute,enableMem_execute, RegWrt_execute, halt_execute;
   wire instruction_memory_error_execute;

   // MEMORY INSTANTIATION // 
   wire [15:0] ALU_output_memory, read_data_2_memory, SLBI_result_memory, instruction_ext_8_memory,
      mem_data_out_memory, constsel_mux_memory, pc_plus_two_memory;
   wire [2:0] rf_write_reg_memory;
   wire [1:0] ConstSel_memory, RegSrc_memory;
   wire MemWrt_memory, enableMem_memory, createDump_memory, valid_memory, RegWrt_memory, halt_memory, mem_en_forward_memory;
   wire instruction_memory_error_memory, data_memory_error_memory;

   // WB INSTANTIATION //
   wire [15:0] ALU_output_wb, pc_plus_two_wb, mem_data_out_wb, constsel_mux_wb, reg_data_wb, instruction_wb, instruction_memory, instruction_wb_sb, reg_data_wb_sb;
   wire [2:0] rf_write_reg_wb, rf_write_reg_wb_sb;
   wire [1:0] RegSrc_wb;
   wire RegWrt_wb, halt_wb;
   wire valid_wb;
   wire instruction_memory_error_wb, data_memory_error_wb;

   // FORWARDING SIGNALS 
   wire [2:0] hazard_A;
   wire [2:0] hazard_B;
   wire [3:0] mem_data_forward;
   wire mem_en_forward;

   // FETCH STAGE //
   assign unaligned_access = instruction_memory_error_wb | data_memory_error_wb;
   fetch FETCH_inst(
      //Inputs
      .clk(clk),
      .rst(rst),
      .enableMem(enableMem_decode),
      .halt(halt_wb),
      .next_pc(next_pc_decode),
      .branch_jump_taken(branch_jump_taken),
      .unaligned_access(unaligned_access),
      //Outputs
      .pc_plus_two(pc_plus_two_fetch),
      .instruction(instruction_fetch),
      .valid(valid_fetch),
      .instruction_memory_error(instruction_memory_error_fetch)
   );
   
   // FETCH -> DECODE LATCH //
   FD_latch FD_latch(
      // Inputs
      .clk(clk),
      .rst(rst),
      .we(1'b1),   // Write enabled is high
      .instruction_i(instruction_fetch),
      .pc_plus_two_i(pc_plus_two_fetch),
      .valid_i(valid_fetch),
      .instruction_memory_error_i(instruction_memory_error_fetch),
      // Outputs
      .instruction_o(instruction_decode),
      .pc_plus_two_o(pc_plus_two_decode),
      .valid_o(valid_decode),
      .instruction_memory_error_o(instruction_memory_error_decode)
   );

   // DECODE STAGE //
   decode DECODE_inst(
      // Inputs
      .clk(clk),
      .rst(rst),
      .instruction(instruction_decode),
      .WrtEn(RegWrt_wb),
      .WriteData(reg_data_wb),
      .rf_write_reg_i(rf_write_reg_wb),
      .valid_wb(valid_wb),
      .pc_plus_two_fetch(pc_plus_two_fetch),
      .pc_plus_two(pc_plus_two_decode),
      //.halt_wb(halt_wb), TODO
      // Outputs
      .ImmSrc(ImmSrc_decode),                /* Control Signals from the decoder */
      .InvA(InvA_decode),
      .InvB(InvB_decode),
      .Cin(Cin_decode),
      .BSrc(BSrc_decode),
      .BSel(BSel_decode),
      .ALUJmp(ALUJmp_decode),
      .MemWrt(MemWrt_decode),
      .halt(halt_decode),
      .RegSrc(RegSrc_decode),
      .ConstSel(ConstSel_decode),
      .createDump(createDump_decode),
      .RegWrt(RegWrt_decode),
      .enableMem(enableMem_decode),          /* End of Control Signals */
      .ALUOp(ALUOp_decode), 
      .read_data_1(read_data_1_decode),   
      .read_data_2(read_data_2_decode),
      .instruction_ext_5(instruction_ext_5_decode),
      .instruction_ext_8(instruction_ext_8_decode),
      .instruction_ext_11(instruction_ext_11_decode),
      .rf_write_reg_o(rf_write_reg_decode),
      .next_pc(next_pc_decode),
      .branch_jump_taken(branch_jump_taken)
   );

   // DECODE -> EXECUTE LATCH //
   DE_latch DE_latch(
      // Inputs
      .clk(clk),
      .rst(rst),
      .we(1'b1),
      .instruction_i(instruction_decode),
      .pc_plus_two_i(pc_plus_two_decode),
      .valid_i(valid_decode),
      .ImmSrc_i(ImmSrc_decode),
      .InvA_i(InvA_decode),
      .InvB_i(InvB_decode),
      .Cin_i(Cin_decode),
      .BSrc_i(BSrc_decode),
      .BSel_i(BSel_decode),
      .ALUJmp_i(ALUJmp_decode),
      .MemWrt_i(MemWrt_decode),
      .RegSrc_i(RegSrc_decode),
      .ConstSel_i(ConstSel_decode),
      .createDump_i(createDump_decode),
      .enableMem_i(enableMem_decode),
      .RegWrt_i(RegWrt_decode),
      .halt_i(halt_decode),
      .rf_write_reg_i(rf_write_reg_decode),
      .read_data_1_i(read_data_1_decode),
      .read_data_2_i(read_data_2_decode),
      .instruction_ext_5_i(instruction_ext_5_decode),
      .instruction_ext_8_i(instruction_ext_8_decode),
      .instruction_ext_11_i(instruction_ext_11_decode),
      .ALUOp_i(ALUOp_decode),
      .instruction_memory_error_i(instruction_memory_error_decode),
      // Outputs
      .instruction_o(instruction_execute),
      .pc_plus_two_o(pc_plus_two_execute),
      .valid_o(valid_execute),
      .ImmSrc_o(ImmSrc_execute),
      .InvA_o(InvA_execute),
      .InvB_o(InvB_execute),
      .Cin_o(Cin_execute),
      .BSrc_o(BSrc_execute),
      .BSel_o(BSel_execute),
      .ALUJmp_o(ALUJmp_execute),
      .MemWrt_o(MemWrt_execute),
      .RegSrc_o(RegSrc_execute),
      .ConstSel_o(ConstSel_execute),
      .createDump_o(createDump_execute),
      .enableMem_o(enableMem_execute),
      .RegWrt_o(RegWrt_execute),
      .halt_o(halt_execute),
      .rf_write_reg_o(rf_write_reg_execute),
      .read_data_1_o(read_data_1_execute),
      .read_data_2_o(read_data_2_execute),
      .instruction_ext_5_o(instruction_ext_5_execute),
      .instruction_ext_8_o(instruction_ext_8_execute),
      .instruction_ext_11_o(instruction_ext_11_execute),
      .ALUOp_o(ALUOp_execute),
      .instruction_memory_error_o(instruction_memory_error_execute)
   );

   // EXECUTE STAGE //
   execute EXECUTE_inst(
      // Inputs
      .clk(clk),
      .rst(rst),
      .instruction(instruction_execute),
      .instruction_ext_5(instruction_ext_5_execute),
      .instruction_ext_8(instruction_ext_8_execute),
      .read_data_1(read_data_1_execute),
      .read_data_2(read_data_2_execute),
      .Cin(Cin_execute),
      .BSel(BSel_execute),
      .ALUOp(ALUOp_execute),
      .InvA(InvA_execute),
      .InvB(InvB_execute),
      .BSrc(BSrc_execute),
      .forward_ALU_output_EM(ALU_output_memory),
      .forward_ALU_output_MW(ALU_output_wb),
      .forward_MEM_output(mem_data_out_memory),
      .forward_MEM_output_MW(mem_data_out_wb),
      .forward_control_A(hazard_A),
      .forward_control_B(hazard_B),
      .mem_data_forward(mem_data_forward),
      .forward_reg_data_wb(reg_data_wb),
      .reg_data_wb_sb(reg_data_wb_sb),
      // Outputs
      .ALU_output(ALU_output_execute),
      .ALU_read_data_2(ALU_read_data_2_execute),
      .SLBI_result(SLBI_result_execute)
   );

   // FORWARDING CONTROLLER //
   forward_controller FOWARD_inst(
      //Inputs
      .clk(clk),
      .rst(rst),
      .instruction_execute(instruction_execute),
      .instruction_memory(instruction_memory),
      .instruction_wb(instruction_wb),
      .reg_src_EM(rf_write_reg_memory), 
      .reg_src_WB(rf_write_reg_wb),
      .instruction_wb_sb(instruction_wb_sb),
      .rf_write_reg_wb_sb(rf_write_reg_wb_sb),
      //Outputs
      .hazard_A(hazard_A),
      .hazard_B(hazard_B),
      .mem_data_forward(mem_data_forward),
      .mem_en_forward(mem_en_forward)
   );

   // EXECUTE -> MEMORY LATCH //
   EM_latch EM_latch(
      // Inputs
      .clk(clk),
      .rst(rst),
      .we(1'b1),
      .pc_plus_two_i(pc_plus_two_execute),
      .instruction_ext_8_i(instruction_ext_8_execute),
      .rf_write_reg_i(rf_write_reg_execute), 
      .valid_i(valid_execute),
      .MemWrt_i(MemWrt_execute),
      .RegSrc_i(RegSrc_execute),
      .ConstSel_i(ConstSel_execute),
      .createDump_i(createDump_execute),
      .enableMem_i(enableMem_execute),
      .RegWrt_i(RegWrt_execute),
      .halt_i(halt_execute),
      .ALU_output_i(ALU_output_execute),
      .read_data_2_i(ALU_read_data_2_execute),
      .SLBI_result_i(SLBI_result_execute),
      .instruction_i(instruction_execute),
      .mem_en_forward_i(mem_en_forward),
      .instruction_memory_error_i(instruction_memory_error_execute),
      // Outputs
      .instruction_o(instruction_memory),
      .pc_plus_two_o(pc_plus_two_memory),
      .instruction_ext_8_o(instruction_ext_8_memory),
      .rf_write_reg_o(rf_write_reg_memory), 
      .valid_o(valid_memory),
      .MemWrt_o(MemWrt_memory),
      .RegSrc_o(RegSrc_memory),
      .ConstSel_o(ConstSel_memory),
      .createDump_o(createDump_memory),
      .enableMem_o(enableMem_memory),
      .RegWrt_o(RegWrt_memory),
      .halt_o(halt_memory),
      .ALU_output_o(ALU_output_memory),
      .read_data_2_o(read_data_2_memory),
      .SLBI_result_o(SLBI_result_memory),
      .mem_en_forward_o(mem_en_forward_memory),
      .instruction_memory_error_o(instruction_memory_error_memory)
   );

   // MEMORY STAGE //
   memory MEMORY_inst(
      // Inputs
      .clk(clk),
      .rst(rst),
      .ALU_output(ALU_output_memory),
      .read_data_2(read_data_2_memory),
      .SLBI_result(SLBI_result_memory),
      .instruction_ext_8(instruction_ext_8_memory),
      .ConstSel(ConstSel_memory),
      .MemWrt(MemWrt_memory),
      .enableMem(enableMem_memory),
      .createDump(createDump_memory),
      .mem_en_forward_memory(mem_en_forward_memory),
      // Outputs
      .mem_data_out(mem_data_out_memory),
      .constsel_mux(constsel_mux_memory),
      .data_memory_error(data_memory_error_memory)
   );

   // MEMORY -> WB LATCH //
   MW_latch MW_latch(
      // Inputs
      .clk(clk),
      .rst(rst),
      .we(1'b1),
      .RegWrt_i(RegWrt_memory),
      .pc_plus_two_i(pc_plus_two_memory),
      .ALU_output_i(ALU_output_memory),
      .mem_data_out_i(mem_data_out_memory),
      .constsel_mux_i(constsel_mux_memory),
      .RegSrc_i(RegSrc_memory),
      .halt_i(halt_memory),
      .rf_write_reg_i(rf_write_reg_memory),
      .valid_i(valid_memory),
      .instruction_i(instruction_memory),
      .instruction_memory_error_i(instruction_memory_error_memory),
      .data_memory_error_i(data_memory_error_memory),
      // Outputs
      .RegWrt_o(RegWrt_wb),
      .pc_plus_two_o(pc_plus_two_wb),
      .ALU_output_o(ALU_output_wb),
      .mem_data_out_o(mem_data_out_wb),
      .constsel_mux_o(constsel_mux_wb),
      .RegSrc_o(RegSrc_wb),
      .halt_o(halt_wb),
      .rf_write_reg_o(rf_write_reg_wb),
      .valid_o(valid_wb),
      .instruction_o(instruction_wb),
      .instruction_memory_error_o(instruction_memory_error_wb),
      .data_memory_error_o(data_memory_error_wb)
   );

   // Fowarding store buffer
      dff_we #(16) store_buffer_instruct (
      .clk(clk),
      .rst(rst),
      .writeData(instruction_wb),
      .readData(instruction_wb_sb),
      .writeEn(1'b1)
    );

    dff_we #(3) store_buffer_reg (
        .clk(clk),
        .rst(rst),
        .writeData(rf_write_reg_wb),
        .readData(rf_write_reg_wb_sb),
        .writeEn(1'b1)
    );

   dff_we #(16) store_buffer_data (
      .clk(clk),
      .rst(rst),
      .writeData(reg_data_wb),
      .readData(reg_data_wb_sb),
      .writeEn(1'b1)
    );


   // WB STAGE //
   wb WB_inst(
      // Inputs
      .clk(clk),
      .rst(rst),
      .RegSrc(RegSrc_wb),
      .pc_plus_two(pc_plus_two_wb),
      .mem_data_out(mem_data_out_wb),
      .ALU_output(ALU_output_wb),
      .constsel_mux(constsel_mux_wb),
      // Outputs
      .reg_data(reg_data_wb)
   );
   
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
