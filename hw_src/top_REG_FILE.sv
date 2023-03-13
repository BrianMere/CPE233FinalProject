`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California Polytechnic State University, San Luis Obispo
// Engineer: Brian Mere
// 
// Create Date: 01/23/2023 04:16:37 PM
// Design Name: REG_FILE
// Module Name: REG_FILE
// Project Name: REG_FILE
// Target Devices: Basys 3 Board
// Description: TOP Module for REG_FILE which holds all register data
//              within the OTTER MCU.
//
//              Inputs: 
//                  RF_ADR1: Register # for argument 1 (ex: 4 refers to x4)
//                  RF_ADR2: Register # for argument 2 
//                  RF_WA: Register # to write to. Will only write with RF_EN on.
//                  RF_WD: Data to write to the register specified by RF_WA
//                  RF_EN: Enables the selected register (see RF_WA) to be written to
//                  CLK: Clock signal. Read operations are asynch, while write
//                      operations are synchronous.
//
//              Outputs:
//                  RF_RS1: The read value from RF_ADR1's register
//                  RF_RS2: The read value from RF_ADR2's register
// 
// Dependencies: None
// 
//////////////////////////////////////////////////////////////////////////////////


module REG_FILE(
    input [4:0] RF_ADR1,
    input [4:0] RF_ADR2,
    input [4:0] RF_WA,
    input [31:0] RF_WD,
    input RF_EN,
    input CLK,
    output logic [31:0] RF_RS1,
    output logic [31:0] RF_RS2
    );

    // Create a 32-bit register (LSB on right, MSB on left)
    // that has 32 registers (x0 first, x1 next, ..., up to x31)
    logic [31:0] registers[0:31];

    // reset the memory to all 0's on powerup
    initial begin
        int i;
        // iterate through all 32 registers
        for (i = 0; i < 32; i=i+1) begin
            registers[i] = 0; //set register i to 0
        end
    end

    // read operations. Always asynch, hence the combinational logic
    always_comb begin

        // filter out the x0 address. If chosen, output 0. Same for RS2. 
        if(RF_ADR1 != 0) begin
            RF_RS1 = registers[RF_ADR1]; // read, from the set of registers, xRF_ADR1
        end
        else begin
            RF_RS1 = 0;
        end
        
        // same as above...
        if(RF_ADR2 != 0) begin
            RF_RS2 = registers[RF_ADR2]; // same as above
        end
        else begin
            RF_RS2 = 0;
        end
    end

    // write operations
    always_ff @ (posedge CLK) begin
        // DON"T WRITE IF NOT ENABLED!!!
        if(RF_EN) begin
            registers[RF_WA] = RF_WD;
        end
    end
    
endmodule
