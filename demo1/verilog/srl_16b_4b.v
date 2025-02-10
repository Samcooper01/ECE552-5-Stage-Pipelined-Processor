module srl_16b_4b(out, A, B);
input [15:0] A, B;
output [15:0] out;

wire [3:0] ShAmt;
assign ShAmt = B[3:0];

assign out =    (ShAmt == 4'b0000) ? A :
                (ShAmt == 4'b0001) ? {1'b0, A[15:1]} :
                (ShAmt == 4'b0010) ? {2'b0, A[15:2]} :
                (ShAmt == 4'b0011) ? {3'b0, A[15:3]} :
                (ShAmt == 4'b0100) ? {4'b0, A[15:4]} :
                (ShAmt == 4'b0101) ? {5'b0, A[15:5]} :
                (ShAmt == 4'b0110) ? {6'b0, A[15:6]} :
                (ShAmt == 4'b0111) ? {7'b0, A[15:7]} :
                (ShAmt == 4'b1000) ? {8'b0, A[15:8]} :
                (ShAmt == 4'b1001) ? {9'b0, A[15:9]} :
                (ShAmt == 4'b1010) ? {10'b0, A[15:10]} :
                (ShAmt == 4'b1011) ? {11'b0, A[15:11]} :
                (ShAmt == 4'b1100) ? {12'b0, A[15:12]} :
                (ShAmt == 4'b1101) ? {13'b0, A[15:13]} :
                (ShAmt == 4'b1110) ? {14'b0, A[15:14]} :
                (ShAmt == 4'b1111) ? {15'b0, A[15]} : out;

endmodule