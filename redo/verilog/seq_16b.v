//SEQ - 8
//      sub_AB = inputA + inputB
//      *inputA = -A
//      seq_out = (sub_AB == 0) ? 1 : 0
//      *seq_out needs to be 16 bits
module seq_16b(out, A, B);
input [15:0] A, B;
output [15:0] out;

wire [15:0] sub_AB;

cla_16b iadd_AB(.sum(sub_AB), .c_out(), .a(A), .b(B), .c_in(1'b0));

assign out = (sub_AB == 16'h0000) ? 16'h0001 : 16'h0000;

endmodule