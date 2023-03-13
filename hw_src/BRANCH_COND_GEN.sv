`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California Polytechnic State University, San Luis Obispo
// Engineer: Brian Mere
// 
// Create Date: 02/09/2023 03:20:52 PM
// Module Name: BRANCH_COND_GEN
// Target Devices: Basys 3 Board
// Description: Determines whether an evaluated BRANCH condition is successful or not
//              and then sends it to the CU DCDR for evalutation to switch muxes. 
// 
// Dependencies: None
// 
//////////////////////////////////////////////////////////////////////////////////


module BRANCH_COND_GEN(
    input [31:0] RS1,       // RS1 values from REG_FILE
    input [31:0] RS2,       // RS2 values from REG_FILE
    output logic BR_EQ,           // Is RS1 == RS2?
    output logic BR_LT,           // Is $signed(RS1) < $signed(RS2)?
    output logic BR_LTU           // Is RS1 < RS2? By default Vivado assumes unsigned
    );

    always_comb begin
        BR_EQ = (RS1 == RS2) ? 1 : 0;                  // set 1 if eq, else 0
        BR_LT = ($signed(RS1) < $signed(RS2)) ? 1 : 0; // set 1 if lt, else 0
        BR_LTU = (RS1 < RS2) ? 1 : 0;                  // set 1 if ltu, else 0
    end

endmodule
