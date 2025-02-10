module ror_16b_4b(out, A, B);
input [15:0] A, B;
output [15:0] out;

wire [3:0] ShAmt;

assign ShAmt = B[3:0];

assign out =    (ShAmt == 4'b0000) ? A :
                (ShAmt == 4'b0001) ? {A[0], A[15:1]} :
                (ShAmt == 4'b0010) ? {A[1:0], A[15:2]} :
                (ShAmt == 4'b0011) ? {A[2:0], A[15:3]} :
                (ShAmt == 4'b0100) ? {A[3:0], A[15:4]} :
                (ShAmt == 4'b0101) ? {A[4:0], A[15:5]} :
                (ShAmt == 4'b0110) ? {A[5:0], A[15:6]} :
                (ShAmt == 4'b0111) ? {A[6:0], A[15:7]} :
                (ShAmt == 4'b1000) ? {A[7:0], A[15:8]} :
                (ShAmt == 4'b1001) ? {A[8:0], A[15:9]} :
                (ShAmt == 4'b1010) ? {A[9:0], A[15:10]} :
                (ShAmt == 4'b1011) ? {A[10:0], A[15:11]} :
                (ShAmt == 4'b1100) ? {A[11:0], A[15:12]} :
                (ShAmt == 4'b1101) ? {A[12:0], A[15:13]} :
                (ShAmt == 4'b1110) ? {A[13:0], A[15:14]} :
                (ShAmt == 4'b1111) ? {A[14:0], A[15]} : out;

endmodule