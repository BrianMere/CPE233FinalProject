`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Ian Feldman
//
// Create Date: 02/22/2023 04:54:00 PM
// Module Name: MCUtb
// Target Devices: OTTER wrapper test bench
// Description: Test otter top module
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
//
//////////////////////////////////////////////////////////////////////////////

module OTTER_Wrapper_tb();
   logic CLK;
   // input BTNL, // used for interrupts
   logic BTNC;
   logic [15:0] SWITCHES;
   logic PS2CLK;
   logic PS2DATA;
   logic [15:0] LEDS;
   logic [7:0] CATHODES;
   logic [3:0] ANODES;
   logic [7:0] VGA_RGB;
   logic VGA_HS;
   logic VGA_VS;
    

    OTTER_Wrapper UUT( .CLK(CLK), .BTNC(BTNC), .SWITCHES(SWITCHES), .PS2CLK(PS2CLK), .PS2DATA(PS2DATA), .LEDS(LEDS), .CATHODES(CATHODES), .ANODES(ANODES), .VGA_RGB(VGA_RGB), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS) );

    integer i;

    initial begin
        CLK = 1'b1;
        BTNC = 1'b0;
        SWITCHES = 15'b0;
        PS2CLK = 0;
        PS2DATA = 0;
        
        for (i = 0; i < 1000; i = i + 1) begin
            #10;
            CLK = ~CLK;
        end
    end
    
endmodule
