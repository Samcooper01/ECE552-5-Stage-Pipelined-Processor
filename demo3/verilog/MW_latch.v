/*
   CS/ECE 552 Spring '24
  
   Filename        : MW_latch.v
   Description     : This is the module for the memory / writeback latch.
*/
module MW_latch (clk, rst, // latch control
                 pc_plus_two_i, ALUJmp_i, RegSrc_i, ALU_output_i, read_data_i, ConstSel_mux_i, jump_adder_output_i, instruction_i, write_register_i, halt_i, valid_i, ImmJmp_i, RegWrt_i, instruction_err_i, memory_err_i, // signal inputs
                 pc_plus_two_o, ALUJmp_o, RegSrc_o, ALU_output_o, read_data_o, ConstSel_mux_o, jump_adder_output_o, instruction_o, write_register_o, halt_o, valid_o, ImmJmp_o, RegWrt_o, instruction_err_o, memory_err_o); // signal outputs

    // latch controls
    input wire clk, rst;

    // signal inputs
    input wire [15:0] pc_plus_two_i;
    input wire ALUJmp_i;
    input wire [1:0] RegSrc_i;
    input wire [15:0] ALU_output_i;
    input wire [15:0] read_data_i;
    input wire [15:0] ConstSel_mux_i;
    input wire [15:0] jump_adder_output_i;
    input wire [15:0] instruction_i;
    input wire [2:0] write_register_i;
    input wire halt_i;
    input wire valid_i;
    input wire ImmJmp_i;
    input wire RegWrt_i;
    input wire instruction_err_i;
    input wire memory_err_i;

    // signal outputs
    output wire [15:0] pc_plus_two_o;
    output wire ALUJmp_o;
    output wire [1:0] RegSrc_o;
    output wire [15:0] ALU_output_o;
    output wire [15:0] read_data_o;
    output wire [15:0] ConstSel_mux_o;
    output wire [15:0] jump_adder_output_o;
    output wire [15:0] instruction_o;
    output wire [2:0] write_register_o;
    output wire halt_o;
    output wire valid_o;
    output wire ImmJmp_o;
    output wire RegWrt_o;
    output wire instruction_err_o;
    output wire memory_err_o;

    // latch signal flip flops
    dff_we  #(16) pc_plus_two_dff (
        .clk(clk),
        .rst(rst),
        .writeData(pc_plus_two_i),
        .readData(pc_plus_two_o),
        .writeEn(1'b0)
    );

    dff_we  #(1) ALUJmp_dff (
        .clk(clk),
        .rst(rst),
        .writeData(ALUJmp_i),
        .readData(ALUJmp_o),
        .writeEn(1'b0)
    );

    dff_we  #(1) ImmJmp_dff (
        .clk(clk),
        .rst(rst),
        .writeData(ImmJmp_i),
        .readData(ImmJmp_o),
        .writeEn(1'b0)
    );

    dff_we  #(1) RegWrt_dff (
        .clk(clk),
        .rst(rst),
        .writeData(RegWrt_i),
        .readData(RegWrt_o),
        .writeEn(1'b0)
    );

    dff_we  #(2) RegSrc_dff (
        .clk(clk),
        .rst(rst),
        .writeData(RegSrc_i),
        .readData(RegSrc_o),
        .writeEn(1'b0)
    );

    dff_we  #(16) ALU_output_dff (
        .clk(clk),
        .rst(rst),
        .writeData(ALU_output_i),
        .readData(ALU_output_o),
        .writeEn(1'b0)
    );

    dff_we  #(16) read_data_dff (
        .clk(clk),
        .rst(rst),
        .writeData(read_data_i),
        .readData(read_data_o),
        .writeEn(1'b0)
    );

    dff_we  #(16) ConstSel_mux_dff (
        .clk(clk),
        .rst(rst),
        .writeData(ConstSel_mux_i),
        .readData(ConstSel_mux_o),
        .writeEn(1'b0)
    );

    dff_we  #(16) jump_adder_output_dff (
        .clk(clk),
        .rst(rst),
        .writeData(jump_adder_output_i),
        .readData(jump_adder_output_o),
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
    
    dff_we #(1) instruction_err_dff (
        .clk(clk),
        .rst(rst),
        .writeData(instruction_err_i),
        .readData(instruction_err_o),
        .writeEn(1'b0)
    );

    dff_we #(1) memory_err_dff (
        .clk(clk),
        .rst(rst),
        .writeData(memory_err_i),
        .readData(memory_err_o),
        .writeEn(1'b0)
    );

endmodule