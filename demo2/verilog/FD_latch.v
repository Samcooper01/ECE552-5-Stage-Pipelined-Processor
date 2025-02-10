/*
   CS/ECE 552 Spring '24
  
   Filename        : FD_latch.v
   Description     : This is the module for the fetch / decode latch.
*/
module FD_latch (clk, rst, hazard, // latch control
                 pc_plus_two_i, instruction_i, valid_i,// signal inputs
                 pc_plus_two_o, instruction_o, valid_o); // signal outputs

    // latch controls
    input wire clk, rst, hazard;

    // signal inputs
    input wire [15:0] pc_plus_two_i;
    input wire [15:0] instruction_i;
    input wire valid_i;

    // signal outputs
    output wire [15:0] pc_plus_two_o;
    output wire [15:0] instruction_o;
    output wire valid_o;


    // latch signal flip flops
    dff_we  #(16) pc_plus_two_dff (
        .clk(clk),
        .rst(rst),
        .writeData(pc_plus_two_i),
        .readData(pc_plus_two_o),
        .writeEn(hazard)
    );

    dff_we  #(16) instruction_dff (
        .clk(clk),
        .rst(rst),
        .writeData(instruction_i),
        .readData(instruction_o),
        .writeEn(hazard)
    );

    dff_we #(1) valid_dff (
        .clk(clk),
        .rst(rst),
        .writeData(valid_i),
        .readData(valid_o),
        .writeEn(hazard)
    );
    
endmodule