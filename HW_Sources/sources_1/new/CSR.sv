`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California Polytechnic State University, San Luis Obispo
// Engineer: Brian Mere 
// 
// Create Date: 03/06/2023 04:45:59 PM
// Design Name: Otter_MCU
// Module Name: CSR
// Project Name: OTTER_MCU
// Target Devices: Basys 3 Board
// Description: The CSR handles storing/sending data to various components in the
//              OTTER_MCU. It handles:
//
//              INT_TAKEN:
//              1) Saving the current PC count internally (to MEPC)
//              2) Copying the MTVEC to the PC on an interrupt. 
//              3) Copy MIE (bit 3 of MSTATUS) to MPIE (bit 7) and clear MIE to 0. 
//
//              INT_RETURNED (mret):
//              1) Send the value in MEPC back to PC
//              2) Copy back the value from MPIE to MIE and clear MPIE to 0. 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CSR(
    input CSR_RST,                      // reset the internal registers
    input CSR_mret_exec,                // dictates a mret instruction execution
    input CSR_INT_TAKEN,                // dictates an interrupt taken 
    input [31:20] CSR_ADDR,             // read the address from this value
    input CSR_WR_EN,                    // enable writing to CSR
    input [31:0] CSR_PC,                // current PC value to store for later use
    input [31:0] CSR_WD,                // data to write to CSR
    input CSR_CLK,                      // clk used
    output logic CSR_MSTATUS_B3,        // MSTATUS bit 3. Alias mie. Enable interrupts.
    output logic [31:0] CSR_MEPC,       // current value of MEPC in CSR (return PC)
    output logic [31:0] CSR_MTVEC,      // value of MTVEC in CSR (ISR addr)
    output logic [31:0] CSR_RD          // value of selected address of data
    );

    // the CSR is essentially another REG_FILE so I'm designing it as such
    logic[31:0] csr_mtvec, csr_mepc, csr_mstatus;

    // like with REG_FILE we'll just reset everything to 0's on boot.
    // initial begin
    //     csr_mtvec = 0;
    //     csr_mepc = 0;
    //     csr_mstatus = 0;
    // end

    // write operations. Like with REG_FILE always synch
    always_ff @ (posedge CSR_CLK) begin

        if(CSR_RST) begin
            csr_mtvec <= 0;
            csr_mepc <= 0;
            csr_mstatus <= 0;
        end

        else if(CSR_WR_EN) begin
            case (CSR_ADDR)
                12'h300: csr_mstatus <= CSR_WD;  // MSTATUS at    0x300
                12'h341: csr_mepc <= CSR_WD;     // MEPC at       0x341
                12'h305: csr_mtvec <= CSR_WD;    // MTVEC at      0x305
                default: ; // don't write lol
            endcase
        end

        else if(CSR_MSTATUS_B3) begin        // check for intterupts now!
            // when we do an INT_TAKEN
            if(CSR_INT_TAKEN) begin
                // save current PC count. Needs to be here since PC count is dependent on intr PC.
                csr_mepc <= CSR_PC;

                // copy mtvec to PC. PC source helps read mtvec, so nothing here

                // save bit 3 of mstatus to bit 7 and disable (set to 0)
                csr_mstatus[7] <= csr_mstatus[3];
                csr_mstatus[3] <= 0;
            end
        end

        if (CSR_mret_exec) begin // mret
                // load the current value in mepc to CSR_MEPC (output)
                // handled in the combinational logic

                // mtvec doesn't ever really change. 

                // return bit 3 from bit 7.
                csr_mstatus[3] <= csr_mstatus[7];
                csr_mstatus[7] <= 0;
        end
    end

    // read operations. Like with REG_FILE always asynch
    always_comb begin
        // always be putting out what's currently being read in the ADDR register.
        case (CSR_ADDR)
            12'h300: CSR_RD = csr_mstatus;  // MSTATUS at    0x300
            12'h341: CSR_RD = csr_mepc;     // MEPC at       0x341
            12'h305: CSR_RD = csr_mtvec;    // MTVEC at      0x305
            default: CSR_RD = 0;            // default by reading 0's. 
        endcase

        // the following are always just output and have constant addresses per the manual.
        CSR_MSTATUS_B3 = csr_mstatus[3];        // MSTATUS at    0x300. Access bit 3.
        CSR_MEPC = csr_mepc;                    // MEPC at       0x341
        CSR_MTVEC = csr_mtvec;                  // MTVEC at      0x305              
    end

endmodule
