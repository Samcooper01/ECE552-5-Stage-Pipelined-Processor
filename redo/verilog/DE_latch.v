/*
   CS/ECE 552 Spring '24
  
   Filename        : DE_latch.v
   Description     : This is the module for the decode / execute latch.
*/
module DE_latch (
    // Latch Controls
    clk, rst, we,
    // Inputs
    instruction_i, pc_plus_two_i, read_data_1_i, read_data_2_i,
    instruction_ext_5_i, instruction_ext_8_i, instruction_ext_11_i,
    ALUOp_i, rf_write_reg_i, RegSrc_i, ConstSel_i, BSrc_i, valid_i, ImmSrc_i, InvA_i, InvB_i, Cin_i, BSel_i, 
    ALUJmp_i, MemWrt_i, createDump_i, enableMem_i, RegWrt_i, halt_i, instruction_memory_error_i,
    // Outputs
    instruction_o, pc_plus_two_o, read_data_1_o, read_data_2_o,
    instruction_ext_5_o, instruction_ext_8_o, instruction_ext_11_o,
    ALUOp_o, rf_write_reg_o, RegSrc_o, ConstSel_o, BSrc_o, valid_o, ImmSrc_o, InvA_o, InvB_o, Cin_o, BSel_o,
    ALUJmp_o, MemWrt_o, createDump_o, enableMem_o, RegWrt_o, halt_o, instruction_memory_error_o
    ); 

    // Latch Controls
    input wire clk, rst, we;

    // Signal Inputs
    input wire [15:0] instruction_i, pc_plus_two_i, read_data_1_i, read_data_2_i, 
        instruction_ext_5_i, instruction_ext_8_i, instruction_ext_11_i;
    input wire [3:0] ALUOp_i;   
    input wire [2:0] rf_write_reg_i;
    input wire [1:0] RegSrc_i, ConstSel_i, BSrc_i;
    input wire valid_i, ImmSrc_i, InvA_i, InvB_i, Cin_i, BSel_i, ALUJmp_i, MemWrt_i, createDump_i, 
        enableMem_i, RegWrt_i, halt_i, instruction_memory_error_i;
    


    // signal outputs
    output wire [15:0] instruction_o, pc_plus_two_o, read_data_1_o, read_data_2_o, 
        instruction_ext_5_o, instruction_ext_8_o, instruction_ext_11_o;
    output wire [3:0] ALUOp_o;
    output wire [2:0] rf_write_reg_o;
    output wire [1:0] RegSrc_o, ConstSel_o, BSrc_o;
    output wire valid_o, ImmSrc_o, InvA_o, InvB_o, Cin_o, BSel_o, ALUJmp_o, MemWrt_o, createDump_o, 
        enableMem_o, RegWrt_o, halt_o, instruction_memory_error_o;

    // Latch Signal Flip Flops
    dff_we #(16) instruction_dff (
        .clk(clk),
        .rst(rst),
        .writeData(instruction_i),
        .readData(instruction_o),
        .writeEn(we)
    );

    dff_we #(16) pc_plus_two_dff (
        .clk(clk),
        .rst(rst),
        .writeData(pc_plus_two_i),
        .readData(pc_plus_two_o),
        .writeEn(we)
    );

    dff_we #(16) read_data_1_dff (
        .clk(clk),
        .rst(rst),
        .writeData(read_data_1_i),
        .readData(read_data_1_o),
        .writeEn(we)
    );

    dff_we #(16) read_data_2_dff (
        .clk(clk),
        .rst(rst),
        .writeData(read_data_2_i),
        .readData(read_data_2_o),
        .writeEn(we)
    );

    dff_we #(16) instruction_lower_5_ext_dff (
        .clk(clk),
        .rst(rst),
        .writeData(instruction_ext_5_i),
        .readData(instruction_ext_5_o),
        .writeEn(we)
    );

    dff_we #(16) instruction_lower_8_ext_dff (
        .clk(clk),
        .rst(rst),
        .writeData(instruction_ext_8_i),
        .readData(instruction_ext_8_o),
        .writeEn(we)
    );

    dff_we #(16) instruction_lower_11_ext_dff (
        .clk(clk),
        .rst(rst),
        .writeData(instruction_ext_11_i),
        .readData(instruction_ext_11_o),
        .writeEn(we)
    );

    dff_we #(4) ALUOp_dff (
        .clk(clk),
        .rst(rst),
        .writeData(ALUOp_i),
        .readData(ALUOp_o),
        .writeEn(we)
    );

    dff_we #(3) rf_write_reg_dff (
        .clk(clk),
        .rst(rst),
        .writeData(rf_write_reg_i),
        .readData(rf_write_reg_o),
        .writeEn(we)
    );

    dff_we #(2) RegSrc_dff (
        .clk(clk),
        .rst(rst),
        .writeData(RegSrc_i),
        .readData(RegSrc_o),
        .writeEn(we)
    );

    dff_we #(2) ConstSel_dff (
        .clk(clk),
        .rst(rst),
        .writeData(ConstSel_i),
        .readData(ConstSel_o),
        .writeEn(we)
    );

    dff_we #(2) BSrc_dff (
        .clk(clk),
        .rst(rst),
        .writeData(BSrc_i),
        .readData(BSrc_o),
        .writeEn(we)
    );

    dff_we #(1) valid_dff (
        .clk(clk),
        .rst(rst),
        .writeData(valid_i),
        .readData(valid_o),
        .writeEn(we)
    );

    dff_we #(1) ImmSrc_dff (
        .clk(clk),
        .rst(rst),
        .writeData(ImmSrc_i),
        .readData(ImmSrc_o),
        .writeEn(we)
    );

    dff_we #(1) InvA_dff (
        .clk(clk),
        .rst(rst),
        .writeData(InvA_i),
        .readData(InvA_o),
        .writeEn(we)
    );

    dff_we #(1) InvB_dff (
        .clk(clk),
        .rst(rst),
        .writeData(InvB_i),
        .readData(InvB_o),
        .writeEn(we)
    );

    dff_we #(1) Cin_dff (
        .clk(clk),
        .rst(rst),
        .writeData(Cin_i),
        .readData(Cin_o),
        .writeEn(we)
    );

    dff_we #(1) BSel_dff (
        .clk(clk),
        .rst(rst),
        .writeData(BSel_i),
        .readData(BSel_o),
        .writeEn(we)
    );

    dff_we #(1) ALUJmp_dff (
        .clk(clk),
        .rst(rst),
        .writeData(ALUJmp_i),
        .readData(ALUJmp_o),
        .writeEn(we)
    );

    dff_we #(1) MemWrt_dff (
        .clk(clk),
        .rst(rst),
        .writeData(MemWrt_i),
        .readData(MemWrt_o),
        .writeEn(we)
    );      

    dff_we #(1) createDump_dff (
        .clk(clk),
        .rst(rst),
        .writeData(createDump_i),
        .readData(createDump_o),
        .writeEn(we)
    );

    dff_we #(1) enableMem_dff (
        .clk(clk),
        .rst(rst),
        .writeData(enableMem_i),
        .readData(enableMem_o),
        .writeEn(we)
    );

    dff_we #(1) RegWrt_dff (
        .clk(clk),
        .rst(rst),
        .writeData(RegWrt_i),
        .readData(RegWrt_o),
        .writeEn(we)
    );

    dff_we #(1) halt_dff (
        .clk(clk),
        .rst(rst),
        .writeData(halt_i),
        .readData(halt_o),
        .writeEn(we)
    );

    dff_we #(1) instruction_memory_error_dff (
        .clk(clk),
        .rst(rst),
        .writeData(instruction_memory_error_i),
        .readData(instruction_memory_error_o),
        .writeEn(we)
    );

endmodule