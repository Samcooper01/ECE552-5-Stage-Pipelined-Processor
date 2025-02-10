/*
   CS/ECE 552 Spring '24
  
   Filename        : DE_latch.v
   Description     : This is the module for the decode / execute latch.
*/
module DE_latch (clk, rst, // latch control
                 instruction_i, pc_plus_two_i, ImmSrc_i, InvA_i, InvB_i, Cin_i, Bsrc_i, BSel_i, ALUJmp_i, MemWrt_i, RegSrc_i, ConstSel_i, createDump_i, enableMem_i, ALUOp_i, read_data_1_i, read_data_2_i, instruction_lower_5_ext_i, instruction_lower_8_ext_i, instruction_lower_11_ext_i, write_register_i, halt_i, valid_i, RegWrt_i, instruction_err_i, // signal inputs
                 instruction_o, pc_plus_two_o, ImmSrc_o, InvA_o, InvB_o, Cin_o, Bsrc_o, BSel_o, ALUJmp_o, MemWrt_o, RegSrc_o, ConstSel_o, createDump_o, enableMem_o, ALUOp_o, read_data_1_o, read_data_2_o, instruction_lower_5_ext_o, instruction_lower_8_ext_o, instruction_lower_11_ext_o, write_register_o, halt_o, valid_o, RegWrt_o, instruction_err_o); // signal outputs

    // latch controls
    input wire clk, rst;

    // signal inputs
    input wire [15:0] instruction_i;
    input wire [15:0] pc_plus_two_i;
    input wire ImmSrc_i;
    input wire InvA_i;
    input wire InvB_i;
    input wire Cin_i;
    input wire [1:0] Bsrc_i;
    input wire BSel_i;
    input wire ALUJmp_i;
    input wire MemWrt_i;
    input wire [1:0] RegSrc_i;
    input wire [1:0] ConstSel_i;
    input wire createDump_i;
    input wire enableMem_i;
    input wire [3:0] ALUOp_i;
    input wire [15:0] read_data_1_i;
    input wire [15:0] read_data_2_i;
    input wire [15:0] instruction_lower_5_ext_i;
    input wire [15:0] instruction_lower_8_ext_i;
    input wire [15:0] instruction_lower_11_ext_i;
    input wire [2:0] write_register_i;
    input wire halt_i;
    input wire valid_i;
    input wire RegWrt_i;
    input wire instruction_err_i;

    // signal outputs
    output wire [15:0] instruction_o;
    output wire [15:0] pc_plus_two_o;
    output wire ImmSrc_o;
    output wire InvA_o;
    output wire InvB_o;
    output wire Cin_o;
    output wire [1:0] Bsrc_o;
    output wire BSel_o;
    output wire ALUJmp_o;
    output wire MemWrt_o;
    output wire [1:0] RegSrc_o;
    output wire [1:0] ConstSel_o;
    output wire createDump_o;
    output wire enableMem_o;
    output wire [3:0] ALUOp_o;
    output wire [15:0] read_data_1_o;
    output wire [15:0] read_data_2_o;
    output wire [15:0] instruction_lower_5_ext_o;
    output wire [15:0] instruction_lower_8_ext_o;
    output wire [15:0] instruction_lower_11_ext_o;
    output wire [2:0] write_register_o;
    output wire halt_o;
    output wire valid_o;
    output wire RegWrt_o;
    output wire instruction_err_o;


    // latch signal flip flops
    dff_we  #(16) instruction_dff (
        .clk(clk),
        .rst(rst),
        .writeData(instruction_i),
        .readData(instruction_o),
        .writeEn(1'b0)
    );

    dff_we  #(16) pc_plus_two_dff (
        .clk(clk),
        .rst(rst),
        .writeData(pc_plus_two_i),
        .readData(pc_plus_two_o),
        .writeEn(1'b0)
    );

    dff_we  #(1) ImmSrc_dff (
        .clk(clk),
        .rst(rst),
        .writeData(ImmSrc_i),
        .readData(ImmSrc_o),
        .writeEn(1'b0)
    );

    dff_we  #(1) RegWrt_dff (
        .clk(clk),
        .rst(rst),
        .writeData(RegWrt_i),
        .readData(RegWrt_o),
        .writeEn(1'b0)
    );

    dff_we  #(1) InvA_dff (
        .clk(clk),
        .rst(rst),
        .writeData(InvA_i),
        .readData(InvA_o),
        .writeEn(1'b0)
    );

    dff_we  #(1) InvB_dff (
        .clk(clk),
        .rst(rst),
        .writeData(InvB_i),
        .readData(InvB_o),
        .writeEn(1'b0)
    );

    dff_we  #(1) Cin_dff (
        .clk(clk),
        .rst(rst),
        .writeData(Cin_i),
        .readData(Cin_o),
        .writeEn(1'b0)
    );

    dff_we  #(2) Bsrc_dff (
        .clk(clk),
        .rst(rst),
        .writeData(Bsrc_i),
        .readData(Bsrc_o),
        .writeEn(1'b0)
    );

    dff_we  #(1) BSel_dff (
        .clk(clk),
        .rst(rst),
        .writeData(BSel_i),
        .readData(BSel_o),
        .writeEn(1'b0)
    );

    dff_we  #(1) ALUJmp_dff (
        .clk(clk),
        .rst(rst),
        .writeData(ALUJmp_i),
        .readData(ALUJmp_o),
        .writeEn(1'b0)
    );

    dff_we  #(1) MemWrt_dff (
        .clk(clk),
        .rst(rst),
        .writeData(MemWrt_i),
        .readData(MemWrt_o),
        .writeEn(1'b0)
    );

    dff_we  #(2) RegSrc_dff (
        .clk(clk),
        .rst(rst),
        .writeData(RegSrc_i),
        .readData(RegSrc_o),
        .writeEn(1'b0)
    );

    dff_we  #(2) ConstSel_dff (
        .clk(clk),
        .rst(rst),
        .writeData(ConstSel_i),
        .readData(ConstSel_o),
        .writeEn(1'b0)
    );

    dff_we  #(1) createDump_dff (
        .clk(clk),
        .rst(rst),
        .writeData(createDump_i),
        .readData(createDump_o),
        .writeEn(1'b0)
    );

    dff_we  #(1) enableMem_dff (
        .clk(clk),
        .rst(rst),
        .writeData(enableMem_i),
        .readData(enableMem_o),
        .writeEn(1'b0)
    );

    dff_we  #(4) ALUOp_dff (
        .clk(clk),
        .rst(rst),
        .writeData(ALUOp_i),
        .readData(ALUOp_o),
        .writeEn(1'b0)
    );

    dff_we  #(16) read_data_1_dff (
        .clk(clk),
        .rst(rst),
        .writeData(read_data_1_i),
        .readData(read_data_1_o),
        .writeEn(1'b0)
    );

    dff_we  #(16) read_data_2_dff (
        .clk(clk),
        .rst(rst),
        .writeData(read_data_2_i),
        .readData(read_data_2_o),
        .writeEn(1'b0)
    );

    dff_we  #(16) instruction_lower_5_ext_dff (
        .clk(clk),
        .rst(rst),
        .writeData(instruction_lower_5_ext_i),
        .readData(instruction_lower_5_ext_o),
        .writeEn(1'b0)
    );

    dff_we  #(16) instruction_lower_8_ext_dff (
        .clk(clk),
        .rst(rst),
        .writeData(instruction_lower_8_ext_i),
        .readData(instruction_lower_8_ext_o),
        .writeEn(1'b0)
    );

    dff_we  #(16) instruction_lower_11_ext_dff (
        .clk(clk),
        .rst(rst),
        .writeData(instruction_lower_11_ext_i),
        .readData(instruction_lower_11_ext_o),
        .writeEn(1'b0)
    );

    dff_we #(3) write_register (
        .clk(clk),
        .rst(rst),
        .writeData(write_register_i),
        .readData(write_register_o),
        .writeEn(1'b0)
    );

    dff_we #(1) halt (
        .clk(clk),
        .rst(rst),
        .writeData(halt_i),
        .readData(halt_o),
        .writeEn(1'b0)
    );

    dff_we #(1) valid_dff (
        .clk(clk),
        .rst(rst),
        .writeData(valid_i),
        .readData(valid_o),
        .writeEn(1'b0)
    );

    dff_we #(1) instruction_err_dff (
        .clk(clk),
        .rst(rst),
        .writeData(instruction_err_i),
        .readData(instruction_err_o),
        .writeEn(1'b0)
    );

endmodule