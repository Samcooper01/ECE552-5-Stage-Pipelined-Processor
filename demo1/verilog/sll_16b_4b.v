module sll_16b_4b(out, A, B);
input [15:0] A, B;
output [15:0] out;

wire [3:0] ShAmt;

assign ShAmt = B[3:0];

assign out = (ShAmt == 4'b0000) ? A 		    :
                (ShAmt == 4'b0001) ? {A[14:0], 1'b0} :
                (ShAmt == 4'b0010) ? {A[13:0], 2'b0} :
                (ShAmt == 4'b0011) ? {A[12:0], 3'b0} :
                (ShAmt == 4'b0100) ? {A[11:0], 4'b0} :
                (ShAmt == 4'b0101) ? {A[10:0], 5'b0} :
                (ShAmt == 4'b0110) ? {A[9:0], 6'b0}  :
                (ShAmt == 4'b0111) ? {A[8:0], 7'b0}  :
                (ShAmt == 4'b1000) ? {A[7:0], 8'b0}  :
                (ShAmt == 4'b1001) ? {A[6:0], 9'b0}  :
                (ShAmt == 4'b1010) ? {A[5:0], 10'b0} :
                (ShAmt == 4'b1011) ? {A[4:0], 11'b0} :
                (ShAmt == 4'b1100) ? {A[3:0], 12'b0} :
                (ShAmt == 4'b1101) ? {A[2:0], 13'b0} :
                (ShAmt == 4'b1110) ? {A[1:0], 14'b0} :
                (ShAmt == 4'b1111) ? {A[0], 15'b0}   : out;

endmodule