module reg_16 #(parameter WIDTH = 16) (clk, reset, d, q);

    // i/o
    input wire clk;
    input wire reset;
    input wire [WIDTH-1:0] d;
    output wire [WIDTH-1:0] q;

    // registers
    dff DFF [WIDTH-1:0] (
        .q(q),
        .d(d),
        .clk(clk),
        .rst(reset)
    );

endmodule