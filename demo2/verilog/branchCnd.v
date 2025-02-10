//This module sets the immJump signal based on the ALU flags SF, ZF, OF, CF
// Only certain opcodes are valid "candidates" for immJump to be asserted (high)
// The list of valid opcode candidates for a immJump signal are:
//      BEQZ
//      BNEZ
//      BLTZ
//      BGEZ
//      J
//      JAL
// for signals who are not valid "candidates" we keep immJump low (0)

//The flags that each valid candidate depends on is depend on the opcode.
//Below are the ALU flag dependecies for each opcode:

// BEQZ -> ZF
// BNEZ -> ~ZF
// BLTZ -> SF
// BGEZ -> ~SF | ZF
// J -> NA (immJump is set to 1 for this opcode)
// JAL -> NA (immJump is set to 1 for this opcode)

module branchCnd(opcode, SF, ZF, OF, CF, immJump);
input [4:0] opcode;

output SF, ZF, OF, CF, immJump;

parameter   BEQZ =  5'b01100,
            BNEZ =  5'b01101,
            BLTZ =  5'b01110,
            BGEZ =  5'b01111,
            J =     5'b00100,
            JAL =   5'b00110;

assign immJump =    (opcode == J) ?     1'b1 :
                    (opcode == JAL) ?   1'b1 :
                    (opcode == BEQZ) ?  ZF :
                    (opcode == BNEZ) ?  ~ZF :
                    (opcode == BLTZ) ?  SF :
                    (opcode == BGEZ) ?  (~SF | ZF ) :
                    1'b0;

endmodule