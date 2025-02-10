/*
   CS/ECE 552 Spring '24
  
   Filename        : EM_latch.v
   Description     : This is the module for the execute / memory latch.
*/
module EM_latch (clk, rst, we, // Latch Controls
    // Inputs
    pc_plus_two_i, instruction_ext_8_i, rf_write_reg_i, valid_i, MemWrt_i, RegSrc_i, ConstSel_i, createDump_i,
    enableMem_i, RegWrt_i, halt_i, ALU_output_i, read_data_2_i, SLBI_result_i, instruction_i, mem_en_forward_i, instruction_memory_error_i,
    // Outputs
    pc_plus_two_o, instruction_ext_8_o, rf_write_reg_o, valid_o, MemWrt_o, RegSrc_o, ConstSel_o, createDump_o,
    enableMem_o, RegWrt_o, halt_o, ALU_output_o, read_data_2_o, SLBI_result_o, instruction_o, mem_en_forward_o, instruction_memory_error_o
    );
                 
    // Latch Controls
    input wire clk, rst, we;

    // Signal Inputs
    input wire [15:0] pc_plus_two_i, instruction_ext_8_i, ALU_output_i, read_data_2_i, SLBI_result_i, instruction_i;
    input wire [2:0] rf_write_reg_i;
    input wire [1:0] RegSrc_i, ConstSel_i;
    input wire valid_i, MemWrt_i, createDump_i, enableMem_i, RegWrt_i, halt_i, mem_en_forward_i, instruction_memory_error_i;

    // Signal Outputs
    output wire [15:0] pc_plus_two_o, instruction_ext_8_o, ALU_output_o, read_data_2_o, SLBI_result_o, instruction_o;
    output wire [2:0] rf_write_reg_o;
    output wire [1:0] RegSrc_o, ConstSel_o;
    output wire valid_o, MemWrt_o, createDump_o, enableMem_o, RegWrt_o, halt_o, mem_en_forward_o, instruction_memory_error_o;

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

    dff_we #(1) mem_en_dff (
        .clk(clk),
        .rst(rst),
        .writeData(mem_en_forward_i),
        .readData(mem_en_forward_o),
        .writeEn(we)
    );


    dff_we #(16) instruction_ext_8_dff (
        .clk(clk),
        .rst(rst),
        .writeData(instruction_ext_8_i),
        .readData(instruction_ext_8_o),
        .writeEn(we)
    );

    dff_we #(16) ALU_output_dff (
        .clk(clk),
        .rst(rst),
        .writeData(ALU_output_i),
        .readData(ALU_output_o),
        .writeEn(we)
    );

    dff_we #(16) read_dat_2_dff (
        .clk(clk),
        .rst(rst),
        .writeData(read_data_2_i),
        .readData(read_data_2_o),
        .writeEn(we)
    );  

    dff_we #(16) SLBI_result_dff (
        .clk(clk),
        .rst(rst),
        .writeData(SLBI_result_i),
        .readData(SLBI_result_o),
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

    dff_we #(1) valid_dff (
        .clk(clk),
        .rst(rst),
        .writeData(valid_i),
        .readData(valid_o),
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

