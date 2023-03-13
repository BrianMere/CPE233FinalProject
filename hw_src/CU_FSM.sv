`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California Polytechnic State University, San Luis Obispo
// Engineer: Brian Mere
// 
// Create Date: 02/21/2023 11:27:10 PM
// Design Name: OTTER_MCU
// Module Name: CU_FSM
// Project Name: HW6
// Target Devices: Basys3 Boards
// Description: FSM of OTTER_MCU that handles all flags (read/writes)
// 
// Dependencies: None
//////////////////////////////////////////////////////////////////////////////////

// Define all states here, as SV will handle the numbering for us :)

module CU_FSM(
    input RST,               // Reset the entirety of the computer. PC -> 0 and so on.
    input CS_INTR,           // Interrupt from CSR and externally.
    input [6:0] OPCODE,      // IR[6:0]: Gives the main opcode for each instruction
    input [14:12] SIZE_SIGN, // IR[12:14]: gives the size and sign for certain operations. 
    input CLK,                 
    output logic PCWRITE,    // Should we be writing to PC now?
    output logic regWRITE,   // Should we be writing to REG_FILE now?
    output logic memWE2,     // Should we write towards memory?
    output logic memRDEN1,   // Should we get the next instruction?
    output logic memRDEN2,   // Should we be reading from memory?
    output logic reset,      // Go high if the RST is high
    output logic csr_WE,     // Allows writes to CSR
    output logic int_taken,  // Say we are in an interrupt right now.
    output logic mret_exec   // Says that we are executing an mret instruction.
    );

    typedef enum  {  
    ST_INIT,        // default to here on startup
    ST_FETCH,       // waits an extra clock cycle to get the next intstruction
    ST_EXEC,        // have the instruction actually go through the main MCU
    ST_WRITEBACK,   // wait an extra clock cycle so that load instructions are handled.
    ST_INTRPT       // handle intterupts that come in here. Returns back to fetch even while in ISR.
    } state;

    state PS, NS; // define next-state and previous state under enum type

    // State register
    always_ff @ (posedge CLK) begin
        if(RST) begin
            PS <= ST_INIT;   // on reset, go to ST_INIT
        end
        else begin
            PS <= NS;        // usually just have present-state be the next state.
        end 
    end

    // Next-State Logic
    always_comb begin
        // intialize all outputs to 0's to remove latches.
        PCWRITE = 0;
        regWRITE = 0;
        memWE2 = 0;
        memRDEN1 = 0;
        memRDEN2 = 0;
        reset = 0;

        // By default have all csr stuff set to 0's ...
        csr_WE = 0;
        int_taken = 0;
        mret_exec = 0;

        case(PS)
            ST_INIT: begin // on init, we reset everything (PC) and go to NS
               reset = 1;
               NS = ST_FETCH; 
            end
            ST_FETCH: begin // on fetch, we are JUST getting the next instruction!
                reset = 0;
                memRDEN1 = 1;
                PCWRITE = 0; // don't write to PC!
                regWRITE = 0;
                memWE2 = 0;
                memRDEN2 = 0;

                NS = ST_EXEC;
            end
            ST_EXEC: begin
                reset = 0;

                // Here we only change to INTRPT by default if 
                // ~LD & CS_INTR
                if (CS_INTR) begin
                    // When INTR, try to go to INTRPT. If LD then it's already set WRITEBACK.
                    NS = ST_INTRPT;
                end
                else begin
                    NS = ST_FETCH;  // default state to go for.
                end
                case(OPCODE) 
                    // Let's go in the order of opcode size ...
                    7'b0000011: begin // lb, lbu, lh, lhu, lw
                        PCWRITE =   0; // again, not yet ...
                        regWRITE =  0; // not yet ...
                        memWE2 =    0; // don't want to write to any memory whatsoever. 
                        memRDEN1 =  1; // not needed, but makes sure we're still having the IR.
                        memRDEN2 =  1; // to load, you need to read. 

                        NS = ST_WRITEBACK;
                    end
                    7'b0010011: begin // addi, andi, ... (all immediate ones)
                        // always
                        PCWRITE =   1;
                        regWRITE =  1;
                        memWE2 =    0;
                        memRDEN1 =  1; // optional
                        memRDEN2 =  0;
                    end
                    7'b0110011: begin // add, and, or, sll, slt, sltu, sra, srl, sub, xor
                        PCWRITE =   1;
                        regWRITE =  1;
                        memWE2 =    0;
                        memRDEN1 =  1; // optional
                        memRDEN2 =  0;
                    end
                    7'b0110111: begin // only for lui
                        PCWRITE =   1;
                        regWRITE =  1;
                        memWE2 =    0;
                        memRDEN1 =  1; // optional
                        memRDEN2 =  0;
                    end
                    7'b0010111: begin // only for auipc
                        PCWRITE =   1;
                        regWRITE =  1;
                        memWE2 =    0;
                        memRDEN1 =  1; // optional
                        memRDEN2 =  0;
                    end
                    7'b1100011: begin // beq, bge, bgeu, blt, bltu, and bne
                        PCWRITE =   1;
                        regWRITE =  0; // no reg writes here
                        memWE2 =    0;
                        memRDEN1 =  1; // optional
                        memRDEN2 =  0;
                    end
                    7'b1101111: begin // just jal
                        PCWRITE =   1;
                        regWRITE =  1;
                        memWE2 =    0;
                        memRDEN1 =  1; // optional
                        memRDEN2 =  0;
                    end
                    7'b1100111: begin // just jalr
                        PCWRITE =   1;
                        regWRITE =  1;
                        memWE2 =    0;
                        memRDEN1 =  1; // optional
                        memRDEN2 =  0;
                    end
                    7'b0100011: begin // sb, sh, sw
                        PCWRITE =   1;
                        regWRITE =  0; // not used, so keep off...
                        memWE2 =    1;
                        memRDEN1 =  1; // optional
                        memRDEN2 =  0; // don't need as we are storing, not reading
                    end
                    7'b1110011: begin // csrrw, mret.
                        case (SIZE_SIGN)
                            3'b001: begin   // csrrw
                                PCWRITE =   1; // need to write to PC the ISR!
                                regWRITE =  1; // writing to a register per the ISA
                                memWE2 =    0; // no writing to memory here
                                memRDEN1 =  1; // optional
                                memRDEN2 =  0; // don't need as we are storing, not reading
                                reset =     0; 
                                csr_WE =    1; // NEED to write to csr the certain value.
                                int_taken = 0; // we aren't in an interrupt yet. Later ...
                                mret_exec = 0; // this isn't mret you silly billy!
                            end
                            3'b010: begin   // csrrs
                                PCWRITE =   1; // still writing lol
                                regWRITE =  1; // saving to rd
                                memWE2 =    0; // not writing to memory
                                memRDEN1 =  1; // get IR
                                memRDEN2 =  0; // not saving to memory
                                reset =     0; 
                                csr_WE =    1; // need to write to CSR
                                int_taken = 0; // not taken during these times
                                mret_exec = 0; // not mret.
                            end
                            3'b011: begin   // csrrc
                                PCWRITE =   1; // still writing lol
                                regWRITE =  1; // saving to rd
                                memWE2 =    0; // not writing to memory
                                memRDEN1 =  1; // get IR
                                memRDEN2 =  0; // not saving to memory
                                reset =     0; 
                                csr_WE =    1; // need to write to CSR
                                int_taken = 0; // not taken during these times
                                mret_exec = 0; // not mret.
                            end
                            3'b000: begin   // mret
                                PCWRITE =   1; // need to write to PC the mepc!
                                regWRITE =  0; // mret doesn't write to a register
                                memWE2 =    0; // no writing to memory here
                                memRDEN1 =  1; // optional
                                memRDEN2 =  0; // don't need as we are storing, not reading
                                reset =     0; 
                                csr_WE =    0; // should leave off as we are reading values in the isr.
                                int_taken = 0; // aren't in an interrupt here.
                                mret_exec = 1; // this IS mret you oh shoot!!
                            end
                            default: begin  // never should happen but just in case ...
                                PCWRITE = 0;
                                regWRITE = 0;
                                memWE2 = 0;
                                memRDEN1 = 0;
                                memRDEN2 = 0;
                                reset = 0;
                                csr_WE = 0;
                                int_taken = 0;
                                mret_exec = 0;
                            end
                        endcase
                    end
                    default: begin // this default shouldn't happen, but just set all 0's.
                        PCWRITE = 0;
                        regWRITE = 0;
                        memWE2 = 0;
                        memRDEN1 = 0;
                        memRDEN2 = 0;
                        reset = 0;
                        csr_WE = 0;
                        int_taken = 0;
                        mret_exec = 0;

                        NS = ST_INIT; // by default ...
                    end 
                endcase
            end
            ST_WRITEBACK: begin
                // We assume that we did a load instruction. See lb, lbu, ... above.
                reset = 0;
                PCWRITE =   1;
                regWRITE =  1;
                memWE2 =    0; // still don't really want to write to memory
                memRDEN1 =  1; // again, not needed but will help
                memRDEN2 =  1; // necessary as we are reading from memory here

                // only go back to fetch if we aren't interrupting
                if (CS_INTR) begin
                    NS = ST_INTRPT; 
                end
                else begin
                    NS = ST_FETCH;
                end

                // NS = ST_FETCH;
            end
            ST_INTRPT: begin   // on an interrupt
                reset = 0;
                PCWRITE =   1; // need to write to PC the ISR value
                regWRITE =  0; // don't mess with the registers
                memWE2 =    0; // aren't writing to memory now. 
                memRDEN1 =  1; // need to get instructions right?
                memRDEN2 =  0; // not loading from memory 

                csr_WE = 0;    // don't explicitly write to CSR here. Doing that in csrrw, ...
                int_taken = 1; // we need to let CSR know of our interrupt 
                mret_exec = 0; // not running mret right now. Used in ST_EXEC.

                NS = ST_FETCH; // return back to ST_FETCH after an interrupt ...
            end
            default: begin      // if we have some weird state, just reset!
                PCWRITE =   0;
                regWRITE =  0;
                memWE2 =    0;
                memRDEN1 =  0; 
                memRDEN2 =  0;
                NS = ST_INIT; 
            end
        endcase
    end

endmodule
