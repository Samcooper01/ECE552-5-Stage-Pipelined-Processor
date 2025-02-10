/*
   CS/ECE 552, Fall '22
   Homework #3, Problem #1
  
   This module creates a 8x16-bit register file.  It has 1 write port, 2 read
   ports, 3 register select inputs, a write enable, a reset, and a clock
   input.  All register state changes occur on the rising edge of the
   clock. 
*/
module regFile  (
                // Outputs
                read1Data, read2Data, err,
                // Inputs
                clk, rst, read1RegSel, read2RegSel, writeRegSel, writeData, writeEn
                );

   input        clk, rst;
   input [2:0]  read1RegSel;
   input [2:0]  read2RegSel;
   input [2:0]  writeRegSel;
   input [15:0] writeData;
   input        writeEn;

   output [15:0] read1Data;
   output [15:0] read2Data;
   output        err;

   // localparam for number of 16-bit registers
   localparam WIDTH = 16;
   // 8 registers with 16 bit width each, must have in and out wires
   wire [WIDTH-1:0] reg_out [7:0];
   wire [WIDTH-1:0] reg_in [7:0];
   
   // 8 x 16 register file
   reg_16 rf0 (.clk(clk), .reset(rst), .d(reg_in[0]), .q(reg_out[0]));
   reg_16 rf1 (.clk(clk), .reset(rst), .d(reg_in[1]), .q(reg_out[1]));
   reg_16 rf2 (.clk(clk), .reset(rst), .d(reg_in[2]), .q(reg_out[2]));
   reg_16 rf3 (.clk(clk), .reset(rst), .d(reg_in[3]), .q(reg_out[3]));
   reg_16 rf4 (.clk(clk), .reset(rst), .d(reg_in[4]), .q(reg_out[4]));
   reg_16 rf5 (.clk(clk), .reset(rst), .d(reg_in[5]), .q(reg_out[5]));
   reg_16 rf6 (.clk(clk), .reset(rst), .d(reg_in[6]), .q(reg_out[6]));
   reg_16 rf7 (.clk(clk), .reset(rst), .d(reg_in[7]), .q(reg_out[7]));

   // assign each input to the correct signal
   assign reg_in[0] = ((writeRegSel == 3'b000) & writeEn) ? writeData : reg_out[0];
   assign reg_in[1] = ((writeRegSel == 3'b001) & writeEn) ? writeData : reg_out[1];
   assign reg_in[2] = ((writeRegSel == 3'b010) & writeEn) ? writeData : reg_out[2];
   assign reg_in[3] = ((writeRegSel == 3'b011) & writeEn) ? writeData : reg_out[3];
   assign reg_in[4] = ((writeRegSel == 3'b100) & writeEn) ? writeData : reg_out[4];
   assign reg_in[5] = ((writeRegSel == 3'b101) & writeEn) ? writeData : reg_out[5];
   assign reg_in[6] = ((writeRegSel == 3'b110) & writeEn) ? writeData : reg_out[6];
   assign reg_in[7] = ((writeRegSel == 3'b111) & writeEn) ? writeData : reg_out[7];

   // read data should always show up
   assign read1Data = reg_out[read1RegSel];
   assign read2Data = reg_out[read2RegSel];

   // TODO: error signal
   assign err = 0;
   

endmodule
