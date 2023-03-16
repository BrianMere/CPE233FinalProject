`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Ian Feldman
//
// Create Date: 03/15/2023 05:32:00 PM
// Module Name: OTTER_MCU_tb
// Target Devices: OTTER test bench
// Description: Test otter mcu
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
//
//////////////////////////////////////////////////////////////////////////////

module OTTER_MCU_tb();
    // inputs
    logic [31:0] IOBUS_IN;
    logic RST;
    logic INTR;
    logic CLK;
    // outputs
    logic [31:0] IOBUS_OUT;
    logic [31:0] IOBUS_ADDR;
    logic IOBUS_WR;
    
    Otter_MCU UUT( .IOBUS_IN(IOBUS_IN), .RST(RST), .INTR(INTR), .CLK(CLK), .IOBUS_OUT(IOBUS_OUT), .IOBUS_ADDR(IOBUS_ADDR), .IOBUS_WR(IOBUS_WR) );
    
    integer i;

    initial begin
        IOBUS_IN = 0;
        RST = 0;
        INTR = 0;
        CLK = 1'b1;
        
        for (i = 0; i < 1000; i = i + 1) begin
            #100;
            CLK = ~CLK;
            INTR = 0;
            if (i == 300 || i == 301 || i == 302 || i == 303 || i == 304) INTR = 1;
            if (i == 400 || i == 401 || i == 402 || i == 403 || i == 404) INTR = 1;
        end
    end
    
endmodule
