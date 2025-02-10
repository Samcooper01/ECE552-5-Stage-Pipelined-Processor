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

module branchCnd(opcode, rs_register, instruction_ext_8, immJump, adder_output, branch_jump_taken);

input wire [4:0] opcode;                // Opcode of the branch instruction
input wire [15:0] rs_register;          // Directly from read_data_1 of the register file, pertains to RS of the brach instructions
input wire [15:0] instruction_ext_8;    // Lower 8 bits of the instruction, used for the JALR and JAL instructions
output wire immJump;                    // Signal to be sent to the immJump block
output wire [15:0] adder_output;        // Output of the adder for the JALR and JAL instructions
output wire branch_jump_taken;          // Signal to be sent to the fetch stage to determine if a branch is taken

wire SF, ZF, OF, CF;                // Flags to be used in the immJump logic

parameter   BEQZ =  5'b01100,
            BNEZ =  5'b01101,
            BLTZ =  5'b01110,
            BGEZ =  5'b01111,
            J =     5'b00100,
            JR =    5'b00101,
            JAL =   5'b00110,
            JALR =  5'b00111;

assign ZF = ~|rs_register;          // If any bit is high, then RS != 0, so ZF = 0, and vice-versa
assign SF = rs_register[15];        // The sign bit of RS is the sign bit of the branch instruction


// Adder for the JALR and JAL instructions
/* PC <- Rs + I(sign_extended) */
cla_16b jump_adder(.sum(adder_output), .c_out(), .a(rs_register), .b(instruction_ext_8), .c_in(1'b0));

// Assign immJump based on the opcode and flags
assign immJump =    (opcode == J) ?     1'b1 :
                    (opcode == JAL) ?   1'b1 :
                    (opcode == BEQZ) ?  ZF :
                    (opcode == BNEZ) ?  ~ZF :
                    (opcode == BLTZ) ?  SF :
                    (opcode == BGEZ) ?  (~SF | ZF ) :
                    1'b0;

assign branch_jump_taken = (immJump) ? 1'b1 :
                        (opcode == JR ) ? 1'b1 :
                        (opcode == JALR ) ? 1'b1 :
                        1'b0;

endmodule