/*
   CS/ECE 552, Fall '22
   Homework #3, Problem #2
  
   This module creates a wrapper around the 8x16b register file, to do
   do the bypassing logic for RF bypassing.
*/
module regFile_bypass (
                       // Outputs
                       read1Data, read2Data, err,
                       // Inputs
                       clk, rst, read1RegSel, read2RegSel, writeRegSel, writeData, writeEn, bypass_en
                       );
   input        clk, rst;
   input [2:0]  read1RegSel;
   input [2:0]  read2RegSel;
   input [2:0]  writeRegSel;
   input [15:0] writeData;
   input        writeEn;
   input        bypass_en;

   output [15:0] read1Data;
   output [15:0] read2Data;
   output        err;

   // localparams for dimensions
   localparam WIDTH = 16;
   localparam DEPTH = 8;

   // override outputs based on bypassing logic
   wire [WIDTH-1:0] read1Data_bypass;
   wire [WIDTH-1:0] read2Data_bypass;

   // instantiate the register file
   regFile rf (
               .clk(clk),
               .rst(rst),
               .read1RegSel(read1RegSel),
               .read2RegSel(read2RegSel),
               .writeRegSel(writeRegSel),
               .writeData(writeData),
               .writeEn(writeEn),
               .read1Data(read1Data_bypass),
               .read2Data(read2Data_bypass),
               .err(err)
               );

   // if the writeEn is high, we override the readData with the writeData
   assign read1Data = ((writeEn) & (writeRegSel == read1RegSel) & ~bypass_en) ? writeData : read1Data_bypass;
   assign read2Data = ((writeEn) & (writeRegSel == read2RegSel) & ~bypass_en) ? writeData : read2Data_bypass;

endmodule
