`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California Polytechnic State, University, San Luis Obispo
// Engineer: Brian Mere
// 
// Create Date: 01/30/2023 04:44:31 PM
// Design Name: IMMED_GEN
// Module Name: IMMED_GEN
// Project Name: HW4_ALU_and_IMMED
// Target Devices: Basys 3 Board
// Description: Generates the imm values from the various types of instructions for ALU.
// 
// Dependencies: None
//
//////////////////////////////////////////////////////////////////////////////////


module IMMED_GEN(
    input [31:7] INSTRUCT,
    output logic [31:0] U_TYPE,
    output logic [31:0] I_TYPE,
    output logic [31:0] S_TYPE,
    output logic [31:0] J_TYPE, 
    output logic [31:0] B_TYPE
    );

    // USE COMBINATIONAL!
    always_comb begin
        // Will shift the bits 12 places left after these operations.
        U_TYPE = {INSTRUCT[31:12], 12'b0};
        // need to sign extend the immediate for the operation. 
        // Copy the left bit 20 times.
        I_TYPE = {{20{INSTRUCT[31]}}, INSTRUCT[31:20]}; 
        // sext(imm), but now the imm is in multiple parts
        S_TYPE = {{20{INSTRUCT[31]}}, INSTRUCT[31:25], INSTRUCT[11:7]};
        // sext(imm << 1), really only used for jal
        J_TYPE = {{12{INSTRUCT[31]}}, 
                    INSTRUCT[19:12], 
                    INSTRUCT[20], 
                    INSTRUCT[30:21], 
                    1'b0};
        // sext(imm << 1)
        B_TYPE = {{20{INSTRUCT[31]}}, 
                    INSTRUCT[7], 
                    INSTRUCT[30:25], 
                    INSTRUCT[11:8], 
                    1'b0};
    end

endmodule
