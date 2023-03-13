`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California Polytechnic State, University, San Luis Obispo
// Engineer: Brian Mere
// 
// Create Date: 01/30/2023 04:44:31 PM
// Design Name: ALU
// Module Name: ALU
// Project Name: HW4_ALU_and_IMMED
// Target Devices: Basys 3 Board
// Description: ALU used in the OTTER MCU. Handles:
/**
    ADD: 0000
    SUB: 1000
    OR:  0110
    AND: 0111
    XOR: 0100
    SRL: 0101
    SLL: 0001
    SRA: 1101
    SLT: 0010
    SLTU: 0011
    LUI-COPY: 1001
*/
// 
// Dependencies: None
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU(
    input [31:0] srcA,
    input [31:0] srcB,
    input [3:0] alu_fun,
    output logic [31:0] result
    );

    // USE COMBINATIONAL LOGIC!
    always_comb begin
        case (alu_fun)
            4'b0000: result = srcA + srcB;  // 0000 => ADD => srcA + srcB
            4'b1000: result = srcA - srcB;  // SUB: srcA - srcB
            4'b0110: result = srcA | srcB;  // OR
            4'b0111: result = srcA & srcB;  // AND
            4'b0100: result = srcA ^ srcB;  // XOR
            4'b0101: result = srcA >> srcB[4:0]; // Logical Shift Right (SRL). ONLY USE 5 LSBs!
            4'b0001: result = srcA << srcB[4:0]; // Logical Shift Left (SLL)
            4'b1101: result = $signed(srcA) >>> srcB[4:0]; // Arithmatic Shift Right (SRA)
            4'b0010: result = ($signed(srcA) < $signed(srcB)) ? 1 : 0; 
            // slt: set to if less than, else 0. SV default to signed
            4'b0011: result = (srcA < srcB) ? 1 : 0; 
            //sltu: same as above but w/ unsigned values
            4'b1001: result = srcA; 
            // lui-copy: lui will load all but the lower 12 bits, which then are handled by addi.
            default: result = 32'hFFFFFFFF; 
            // This usually won't occur, but fail hard for now during testing.
        endcase
    end

endmodule
