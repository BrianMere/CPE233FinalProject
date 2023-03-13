`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Califronia Polytechnic State University, San Luis Obispo
// Engineer: Brian Mere
// 
// Create Date: 01/18/2023 03:44:25 PM
// Design Name: program_counter
// Module Name: N/A (no top module)
// Project Name: HW2: PC
// Target Devices: Basys 3
// Description: A 32-bit counter that changes count state based on reset, digital 
//              inputs, and a clk signal
// 
// Dependencies: None
// 
//////////////////////////////////////////////////////////////////////////////////


module program_counter(
       input PC_WRITE,        // active high that writes PC_DIN to PC_COUNT
       input PC_RST,          // active high that sets PC_COUNT to 0 while active
       input [31:0] PC_DIN,   // value to store in PC_COUNT w/ PC_WRITE
       input CLK,             // used in counter logic to increment counter
       output logic [31:0] PC_COUNT // current count in internal COUNT register
    );
    
    always_ff @ (posedge CLK) begin
        // RESET takes highest priority and resets the COUNT to 0
        if(PC_RST) begin 
            PC_COUNT <= 0;
        end
        
        // The next highest priority operand is the PC_WRITE to 
        // force PC_DIN into the PC_COUNT
        else if(PC_WRITE) begin
            PC_COUNT <= PC_DIN;
        end
        
        // Normal Operation: Just maintain the certain input value given by the 
        // MUX
        
    end
    
endmodule
