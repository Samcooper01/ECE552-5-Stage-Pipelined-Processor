`default_nettype none
module dff_we #(parameter WIDTH = 16) (clk, rst, writeData, readData, writeEn);
    
    // input and outputs
    input wire clk, rst, writeEn;
    input wire [WIDTH-1:0] writeData;
    output wire [WIDTH-1:0] readData;

    // maintain state of the register when writeEn is low
    wire [WIDTH-1:0] dff_input;
    assign dff_input = writeEn ? writeData : readData;
    
    // vector instantiate flip flops for width
    dff dff_vi [WIDTH-1:0] (
        .clk(clk),
        .rst(rst),
        .d(dff_input),
        .q(readData)
    );

endmodule