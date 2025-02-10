//This module is the primary ALU
//It takes A and B as its main inputs and has inputs for inverting A/B as well as adding a c_in
// which adds to whichever signal is being inverter (can also be added to both if both inverted)

//its outputs are ALU flags: SF/ZF/OF/CF which are sent to the branch condition block
//its main computational output is the out signal which is the result of the alu operation on A and B

//There exist 12 possible ALU operations which are broken into submodules and commented below

module ALU(A, B, invA, invB, c_in, ALU_mode, out);
//Inputs
input [15:0] A, B;
input invA, invB, c_in;

//Input Mode
input [3:0] ALU_mode;

//Main Output
output [15:0] out;

wire [15:0]     add_out, 
                xor_out, 
                and_out,
                rol_out,
                sll_out,
                ror_out,
                srl_out,
                btr_out,
                seq_out,
                slt_out,
                sle_out,
                sco_out;

wire [15:0]     inputA,
                inputB;

wire [15:0]     A_inv_inc,
                B_inv_inc;

wire    Ofl_unsigned, Ofl_signed;
wire    signed_input; 

//Functions: ADD/XOR/AND/ROL/SLL/ROR/SRL/BTR/SEQ/SLT/SLE/SCO
parameter   ADD = 4'b0000,
            XOR = 4'b0001,
            AND = 4'b0010,
            ROL = 4'b0011,
            SLL = 4'b0100,
            ROR = 4'b0101,
            SRL = 4'b0110,
            BTR = 4'b0111,
            SEQ = 4'b1000,
            SLT = 4'b1001,
            SLE = 4'b1010,
            SCO = 4'b1011;

assign out =    (ALU_mode == ADD) ? add_out :
                (ALU_mode == XOR) ? xor_out :
                (ALU_mode == AND) ? and_out :
                (ALU_mode == ROL) ? rol_out :
                (ALU_mode == SLL) ? sll_out :
                (ALU_mode == ROR) ? ror_out :
                (ALU_mode == SRL) ? srl_out :
                (ALU_mode == BTR) ? btr_out :
                (ALU_mode == SEQ) ? seq_out :
                (ALU_mode == SLT) ? slt_out :
                (ALU_mode == SLE) ? sle_out :
                (ALU_mode == SCO) ? sco_out :
                add_out;

//We can assert these for all operations bc the branchCnd block will only send immJump signal if
//the opcode requires a flag
assign signed_input =   (invA & c_in) ? 1'b1 :
                        (invB & c_in) ? 1'b1 :
                        1'b0; //if we are inverting a signal and adding c_in we can assume this is a signed operation
assign  Ofl_unsigned = ((inputA[15] & inputB[15]) | (inputA[15] ^ inputB[15]) & ~out[15]) ? 1'b1 : 1'b0;
assign  Ofl_signed = ((~inputA[15] & ~inputB[15] & out[15]) | (inputA[15] & inputB[15] & ~out[15])) ? 1'b1 : 1'b0;

assign  OF = (signed_input) ? Ofl_signed : Ofl_unsigned; //the overflow depends on the type of operations (signed vs unsigned)
assign  ZF =     (out) ? 1'b0 : 1'b1;
assign  SF =     out[15];
        //CF set in iadder

cla_16b iInvA(.sum(A_inv_inc), .c_out(), .a(~A), .b(16'h0000), .c_in(c_in)); //X_inv_inc is slightly misleading as the signal is not always incremented
cla_16b iInvB(.sum(B_inv_inc), .c_out(), .a(~B), .b(16'h0000), .c_in(c_in)); // if c_in is 0 the signal is not incremented but if 1 it will be

assign inputA = (invA) ? A_inv_inc : A;
assign inputB = (invB) ? B_inv_inc : B;

//ADD - 0
//      add_out = inputA + inputB
//      *note this also can do sub if inputA = ~inputA + 1
//       or if inputB = ~inputB + 1
cla_16b iadder( .sum(add_out), .c_out(CF), .a(inputA), .b(inputB), .c_in(1'b0));

//XOR - 1
//      xor_out = inputA XOR inputB
xor_16b ixor(.out(xor_out), .A(inputA), .B(inputB));

//AND - 2
//      and_out = inputA & inputB
and_16b iand(.out(and_out), .A(inputA), .B(inputB));

//ROL - 3
//      rol_out = inputA <<< inputB[3:0]
//      *note <<< represents rotate
rol_16b_4b irol(.out(rol_out), .A(inputA), .B(inputB));

//SLL - 4
//      sll_out = inputA << inputB[3:0]
sll_16b_4b isll(.out(sll_out), .A(inputA), .B(inputB));

//ROR - 5
//      ror_out = inputA >>> inputB[3:0]
//      *note >>> represents rotate
ror_16b_4b iror(.out(ror_out), .A(inputA), .B(inputB));

//SRL - 6
//      srl_out = inputA >> inputB[3:0]
srl_16b_4b isrl(.out(srl_out), .A(inputA), .B(inputB));

//BTR - 7
//      btr_out[i] = inputA[15-i] for i=0..15
btr_16b ibtr(.out(btr_out), .A(inputA), .B(inputB));
 
//SEQ - 8 -> seq_out = A == B
//      add_out = inputA + inputB
//      *inputB = -B
//      seq_out = (add_out == 0) ? 1 : 0
//      *seq_out needs to be 16 bits
seq_16b iseq(.out(seq_out), .A(inputA), .B(inputB));

//SLT - 9 -> slt_out = A < B
//      add_out = inputA + inputB
//      *inputB = -B    
//      slt_out = (add_out[15] == 1) ? 1 : 0
//      *seq_out needs to be 16 bits
slt_16b islt(.out(slt_out), .A(inputA), .B(inputB), .A_raw(A), .B_raw(B));

//SLE - 10 -> sle_out = A <= B
//      add_out = inputA + inputB
//      *inputB = -B    
//      slt_out = (add_out[15] == 1 or add_out == 0) ? 1 : 0
//      *seq_out needs to be 16 bits
sle_16b isle(.out(sle_out), .A(inputA), .B(inputB), .A_raw(A), .B_raw(B));

//SCO - 11 -> sco_out = A+B has Cout
//      add_out = inputA + inputB
//      sco_out = CF
//      *sco_out needs to be 16 bits
sco_16b isco(.out(sco_out), .A(inputA), .B(inputB));

endmodule