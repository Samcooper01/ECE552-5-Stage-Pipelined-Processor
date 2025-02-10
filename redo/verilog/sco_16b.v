//SCO - 11 -> A+B has Cout
//      add_out = inputA + inputB
//      sco_out = CF
//      *sco_out needs to be 16 bits
module sco_16b(out, A, B);
input [15:0] A, B;
output [15:0] out;

wire carry_out;

cla_16b iInvA(.sum(), .c_out(carry_out), .a(A), .b(B), .c_in(1'b0));

assign out = (carry_out) ? 16'h0001 : 16'h0000;

endmodule