/*
   CS/ECE 552 Spring '24
  
   Filename        : FD_latch.v
   Description     : This is the module for the fetch / decode latch.
*/
module FD_latch (
    // Latch Controls
    clk, rst, we, 
    // Signal Inputs
    pc_plus_two_i, instruction_i, valid_i, instruction_memory_error_i,
    // Signal Outputs
    pc_plus_two_o, instruction_o, valid_o, instruction_memory_error_o
    ); 

    // Latch Controls
    input wire clk, rst, we;

    // Signal Inputs
    input wire [15:0] pc_plus_two_i;
    input wire [15:0] instruction_i;
    input wire valid_i, instruction_memory_error_i;

    // Signal Outputs
    output wire [15:0] pc_plus_two_o;
    output wire [15:0] instruction_o;
    output wire valid_o, instruction_memory_error_o;


    // latch signal flip flops
    dff_we  #(16) pc_plus_two_dff (
        .clk(clk),
        .rst(rst),
        .writeData(pc_plus_two_i),
        .readData(pc_plus_two_o),
        .writeEn(we)
    );

    dff_we  #(16) instruction_dff (
        .clk(clk),
        .rst(rst),
        .writeData(instruction_i),
        .readData(instruction_o),
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
    
endmodule