/*
   CS/ECE 552 Spring '24
  
   Filename        : EM_latch.v
   Description     : This is the module for the execute / memory latch.
*/
module EM_latch (clk, rst, // latch control
                 pc_plus_two_i, ImmSrc_i, ALUJmp_i, MemWrt_i, RegSrc_i, ConstSel_i, createDump_i, enableMem_i, read_data_2_i, instruction_lower_8_ext_i, instruction_lower_11_ext_i, ImmJmp_i, ALU_output_i, SLBI_concat_i, instruction_i, write_register_i, halt_i, valid_i, RegWrt_i,// signal inputs
                 pc_plus_two_o, ImmSrc_o, ALUJmp_o, MemWrt_o, RegSrc_o, ConstSel_o, createDump_o, enableMem_o, read_data_2_o, instruction_lower_8_ext_o, instruction_lower_11_ext_o, ImmJmp_o, ALU_output_o, SLBI_concat_o, instruction_o, write_register_o, halt_o, valid_o, RegWrt_o); // signal outputs

    // latch controls
    input wire clk, rst;

    // signal inputs
    input wire [15:0] pc_plus_two_i;
    input wire ImmSrc_i;
    input wire ALUJmp_i;
    input wire MemWrt_i;
    input wire [1:0] RegSrc_i;
    input wire [1:0] ConstSel_i;
    input wire createDump_i;
    input wire enableMem_i;
    input wire [15:0] read_data_2_i;
    input wire [15:0] instruction_lower_8_ext_i;
    input wire [15:0] instruction_lower_11_ext_i;
    input wire ImmJmp_i;
    input wire [15:0] ALU_output_i;
    input wire [15:0] SLBI_concat_i;
    input wire [15:0] instruction_i;
    input wire [2:0] write_register_i;
    input wire halt_i;
    input wire valid_i;
    input wire RegWrt_i;

    // signal outputs
    output wire [15:0] pc_plus_two_o;
    output wire ImmSrc_o;
    output wire ALUJmp_o;
    output wire MemWrt_o;
    output wire [1:0] RegSrc_o;
    output wire [1:0] ConstSel_o;
    output wire createDump_o;
    output wire enableMem_o;
    output wire [15:0] read_data_2_o;
    output wire [15:0] instruction_lower_8_ext_o;
    output wire [15:0] instruction_lower_11_ext_o;
    output wire ImmJmp_o;
    output wire [15:0] ALU_output_o;
    output wire [15:0] SLBI_concat_o;
    output wire [15:0] instruction_o;
    output wire [2:0] write_register_o;
    output wire halt_o;
    output wire valid_o;
    output wire RegWrt_o;


    // latch signal flip flops
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

    dff_we  #(1) ALUJmp_dff (
        .clk(clk),
        .rst(rst),
        .writeData(ALUJmp_i),
        .readData(ALUJmp_o),
        .writeEn(1'b0)
    );

    dff_we  #(1) RegWrt_dff (
        .clk(clk),
        .rst(rst),
        .writeData(RegWrt_i),
        .readData(RegWrt_o),
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

    dff_we  #(16) read_data_2_dff (
        .clk(clk),
        .rst(rst),
        .writeData(read_data_2_i),
        .readData(read_data_2_o),
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

    dff_we  #(1) ImmJmp_dff (
        .clk(clk),
        .rst(rst),
        .writeData(ImmJmp_i),
        .readData(ImmJmp_o),
        .writeEn(1'b0)
    );

    dff_we  #(16) ALU_output_dff (
        .clk(clk),
        .rst(rst),
        .writeData(ALU_output_i),
        .readData(ALU_output_o),
        .writeEn(1'b0)
    );

    dff_we  #(16) SLBI_concat_dff (
        .clk(clk),
        .rst(rst),
        .writeData(SLBI_concat_i),
        .readData(SLBI_concat_o),
        .writeEn(1'b0)
    );

    dff_we  #(16) instruction_dff (
        .clk(clk),
        .rst(rst),
        .writeData(instruction_i),
        .readData(instruction_o),
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
    
endmodule

