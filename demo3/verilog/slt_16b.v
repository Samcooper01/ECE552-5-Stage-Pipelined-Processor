//SLT - 9
//      add_out = inputA + inputB
//      *inputB = -B    
//      slt_out = (add_out[15] == 1) ? 1 : 0
//      *seq_out needs to be 16 bits
module slt_16b(out, A, B, A_raw, B_raw);
input [15:0] A, B, A_raw, B_raw;
output [15:0] out;

wire [15:0] sub_AB;
wire carry_out;

cla_16b iadd_AB(.sum(sub_AB), .c_out(carry_out), .a(A), .b(B), .c_in(1'b0));

//sub_AB = B - A
// if sub_AB[15] == 0 then pos number and B > A
// if sub_AB[15] == 1 then neg number and B < A
// if sub_AB == 0 then A == B 
// if we are checking if A < B then 
// sub_AB[15] (B > A) should be 0 for out to be 1
assign out =    ((A_raw[15] == 1'b1) & (B_raw[15] == 1'b0)) ? 16'h0001 :
                ((A_raw[15] == 1'b0) & (B_raw[15] == 1'b1)) ? 16'h0000 :
                (((sub_AB[15] == 1'b0) & (sub_AB != 16'h0000)) ? 16'h0001 : 16'h0000);

endmodule