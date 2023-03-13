`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Califronia Polytechnic State University, San Luis Obispo
// Engineer: Brian Mere
// 
// Create Date: 01/18/2023 04:01:05 PM
// Design Name: mux6sel
// Module Name: N/A (no top module)
// Project Name: HW2: PC
// Target Devices: Basys 3
// Description: A 6-input select mux to handle selection of inputs to the PC. 
// 
// Dependencies: None
// 
//////////////////////////////////////////////////////////////////////////////////

module mux6sel(
        input[31:0] PC_P4,          // whatever value the PC has +4
        input[31:0] JALR,           // new address input from a jalr instruction
        input[31:0] BRANCH,         // new address input from a BRANCH (beq, for 
                                    // example) instruction
        input[31:0] JAL,            // new address input from JAL operations 
        input[31:0] MTVEC,          // input to jump to interrupt service routine
        input[31:0] MEPC,           // input to jump from interrupt service routine
        input[2:0] PC_SOURCE,       // is the selector input for the mux. Expects 
                                    // 0-5, 6/7 should output the lowest 32-bit 
                                    // number possible (ie: 0) to reset the PC
        output logic[31:0] PC_DOUT  // the resulting address to send to the PC
    );
    
    always_comb begin
        case(PC_SOURCE) // cases 0-5 should be normal as shown above. 6/7 should 
                        // just give normal 0x0 output to fail gently.
            3'b000: PC_DOUT = PC_P4;
            3'b001: PC_DOUT = JALR;
            3'b010: PC_DOUT = BRANCH;
            3'b011: PC_DOUT = JAL;
            3'b100: PC_DOUT = MTVEC;
            3'b101: PC_DOUT = MEPC;
            default: PC_DOUT = 0; 
            // in testing we'll use a specific value to 
            //detect it if it does occur. Otherwise, 0 should work. 
        endcase
    end
    
endmodule
