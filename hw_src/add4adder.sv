`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Califronia Polytechnic State University, San Luis Obispo
// Engineer: Brian Mere
// 
// Create Date: 01/18/2023 03:41:18 PM
// Design Name: add4adder
// Module Name: N/A (no top module)
// Project Name: HW2: PC
// Target Devices: Basys 3
// Description: A simple constant +4 adder to help with next instruction
//              addresses.
// 
// Dependencies: None
// 
//////////////////////////////////////////////////////////////////////////////////


module add4adder(
        input[31:0] operand,             // input to the +4 adder
        output logic[31:0]  added_out    // whatever the input was + 4
    );
    
    // just always add 4 combinationally to input
    assign added_out = operand + 32'b100; 
    
    
endmodule
