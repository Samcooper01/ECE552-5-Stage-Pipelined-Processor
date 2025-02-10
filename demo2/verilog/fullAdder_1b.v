/*
    	CS/ECE 552 FALL '22
    	Homework #2, Problem 1
    
    	a 1-bit full adder
*/
module fullAdder_1b(s, c_out, a, b, c_in);
	output wire s;
	output wire c_out;
	input  wire a, b;
	input  wire c_in;

	// YOUR CODE HERE
	wire wire1, wire2, wire3, wire4, wire5, wire6, wire7;

	xor3 xor3_1(.out(s), .in1(a), .in2(b), .in3(c_in));
	

	nand2 nand2_1(.out(wire1), .in1(a), .in2(b));
	nand2 nand2_2(.out(wire2), .in1(a), .in2(c_in));
	nand2 nand2_3(.out(wire3), .in1(b), .in2(c_in));

	not1 not1_1(.out(wire4), .in1(wire1));
	not1 not1_2(.out(wire5), .in1(wire2));
	not1 not1_3(.out(wire6), .in1(wire3));

	nor3 nor3_1(.out(wire7), .in1(wire4), .in2(wire5), .in3(wire6));
	
	not1 not1_4(.out(c_out), .in1(wire7));
endmodule
