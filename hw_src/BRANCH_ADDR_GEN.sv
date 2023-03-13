`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California Polytechnic State University, San Luis Obispo
// Engineer: Brian Mere
// 
// Create Date: 02/09/2023 03:20:52 PM
// Module Name: BRANCH_ADDR_GEN
// Target Devices: Basys 3 Board
// Description: Generates the next PC value based on certain intstructions, such
//              as jalr, jal, and general B_TYPE instructions. 
// 
// Dependencies: None
// 
//////////////////////////////////////////////////////////////////////////////////


module BRANCH_ADDR_GEN(
    input [31:0] PC,            // current PC val
    input [31:0] J_TYPE,        // J_TYPE IMMED value
    input [31:0] B_TYPE,        // B_TYPE IMMED value
    input [31:0] I_TYPE,        // I_TYPE IMMED value
    input [31:0] RS1,           // Value in RS1
    output logic [31:0] JALR,         // Send JALR back to PC
    output logic [31:0] BRANCH,       // Send BRANCH value back to PC
    output logic [31:0] JAL           // Send JAL value back to PC
    );

    always_comb begin
        JALR = RS1 + I_TYPE;    // PC <- rs1 + sext(imm), note imm already sext from IMMED_GEN
        BRANCH = PC + B_TYPE;   // PC <- PC + sext(imm << 1), " ... IMMED_GEN"
        JAL = PC + J_TYPE;      // PC <- PC + sext(imm << 1), " ... IMMED_GEN"
    end

endmodule
