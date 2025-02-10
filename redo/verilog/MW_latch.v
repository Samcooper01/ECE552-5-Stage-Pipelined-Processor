/*
   CS/ECE 552 Spring '24
  
   Filename        : MW_latch.v
   Description     : This is the module for the memory / writeback latch.
*/
module MW_latch (
    // Latch Controls
    clk, rst, we,
    // Inputs
    RegWrt_i, pc_plus_two_i, ALU_output_i, mem_data_out_i, constsel_mux_i, RegSrc_i, halt_i, rf_write_reg_i, instruction_i, instruction_memory_error_i, data_memory_error_i,
    valid_i, 
    // Outputs
    RegWrt_o, pc_plus_two_o, ALU_output_o, mem_data_out_o, constsel_mux_o, RegSrc_o, halt_o, rf_write_reg_o, instruction_o, instruction_memory_error_o, data_memory_error_o,
    valid_o
    );
   
    // Latch Controls
    input wire clk, rst, we;

    // Signal Inputs
    input wire [15:0] pc_plus_two_i, ALU_output_i, mem_data_out_i, constsel_mux_i, instruction_i;
    input wire [2:0] rf_write_reg_i;
    input wire [1:0] RegSrc_i;
    input wire RegWrt_i, halt_i, valid_i, instruction_memory_error_i, data_memory_error_i;

    // Signal Outputs
    output wire [15:0] pc_plus_two_o, ALU_output_o, mem_data_out_o, constsel_mux_o, instruction_o;
    output wire [2:0] rf_write_reg_o;
    output wire [1:0] RegSrc_o;
    output wire RegWrt_o, halt_o, valid_o, instruction_memory_error_o, data_memory_error_o;

    // Latch Signal Flip Flops
    dff_we #(16) pc_plus_two_dff (
        .clk(clk),
        .rst(rst),
        .writeData(pc_plus_two_i),
        .readData(pc_plus_two_o),
        .writeEn(we)
    );

    dff_we #(16) instruction_dff (
        .clk(clk),
        .rst(rst),
        .writeData(instruction_i),
        .readData(instruction_o),
        .writeEn(we)
    );

    dff_we #(16) ALU_output_dff (
        .clk(clk),
        .rst(rst),
        .writeData(ALU_output_i),
        .readData(ALU_output_o),
        .writeEn(we)
    );

    dff_we #(16) mem_data_out_dff (
        .clk(clk),
        .rst(rst),
        .writeData(mem_data_out_i),
        .readData(mem_data_out_o),
        .writeEn(we)
    );

    dff_we #(16) constsel_mux_dff (
        .clk(clk),
        .rst(rst),
        .writeData(constsel_mux_i),
        .readData(constsel_mux_o),
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

    dff_we #(1) valid_dff (
        .clk(clk),
        .rst(rst),
        .writeData(valid_i),
        .readData(valid_o),
        .writeEn(we)
    );

    dff_we #(1) instruction_memory_error_dff (
        .clk(clk),
        .rst(rst),
        .writeData(instruction_memory_error_i),
        .readData(instruction_memory_error_o),
        .writeEn(we)
    );

    dff_we #(1) data_memory_error_dff (
        .clk(clk),
        .rst(rst),
        .writeData(data_memory_error_i),
        .readData(data_memory_error_o),
        .writeEn(we)
    );

endmodule