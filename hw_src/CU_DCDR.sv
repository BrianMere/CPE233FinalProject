`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California Polytechnic State University, San Luis Obispo
// Engineer: Brian Mere
// 
// Create Date: 02/21/2023 11:27:10 PM
// Design Name: OTTER_MCU
// Module Name: CU_DCDR
// Project Name: HW6
// Target Devices: Basys3 Boards
// Description: Main decoder for OTTER, handles Mux selections. 
// 
// Dependencies: None
//////////////////////////////////////////////////////////////////////////////////


module CU_DCDR(
    input [6:0] OPCODE,             // IR[6:0] gives the opcode for most instructions.
    input [14:12] SIZE_SIGN,        // From IR[14:12], gives the size and sign
    input [30:30] IR,               // IR[30]. Really only needed for srai vs. slti vs...
    input int_taken,                // Used in CSR. Says that we are in an interrupt (interrupt state) 
    input br_eq,                    // Whether a beq was true or false
    input br_lt,                    // Whether a blt was true or false
    input br_ltu,                   // Whether a bltu was true or false
    output logic [3:0] alu_fun,     // Tells ALU what calculation to do
    output logic [1:0] alu_srcA,    // Sets the input to srcA to ALU
    output logic [2:0] alu_srcB,    // Sets the input to srcB to ALU    
    output logic [2:0] pcSource,    // Says what new value PC should become (usually is 0)
    output logic [1:0] rf_wr_sel    // Indicates what to write to selected register.
    );

    always_comb begin
        // initialize all outputs to 0s to avoid latches
        alu_fun = 0;
        alu_srcA = 0;
        alu_srcB = 0;
        pcSource = 0;
        rf_wr_sel = 0;

        if(int_taken) begin // on interrupts we REALLY just want pcSource to be 4 and others as 0. 
            pcSource = 4;
        end
        else begin //TODO: check if this is the right idea...
            case(OPCODE)
                // Let's go in order of the opcode size...
                7'b0000011: begin // lb, lbu, lh, lhu, lw
                    // always ...
                    alu_srcA =  0;
                    alu_srcB =  1; // changed from 0
                    pcSource =  0;
                    rf_wr_sel = 2;
                    alu_fun = 0;
                end
                7'b0010011: begin // add, addi, andi, ... (all immediate ones + add)
                    // Note that all types are I-Types here
                    alu_srcA = 0;
                    alu_srcB = 1; // all I-types and immediates
                    pcSource = 0; // always just PC += 4;
                    rf_wr_sel = 3; // always writing result to wd
                    case(SIZE_SIGN)
                        3'b000: begin   // addi
                            alu_fun = 4'b0000;
                        end
                        3'b001: begin   // slli
                            alu_fun = 4'b0001;
                        end
                        3'b010: begin   // slti
                            alu_fun = 4'b0010;
                        end
                        3'b011: begin   // sltiu
                            alu_fun = 4'b0011;
                        end
                        3'b100: begin   // xori
                            alu_fun = 4'b0100;
                        end
                        3'b101: begin   // srai, srli
                            case (IR)
                                1'b1: alu_fun = 4'b1101; // is srai
                                1'b0: alu_fun = 4'b0101; // is srli              
                            endcase
                        end
                        3'b110: begin   // ori
                            alu_fun = 4'b0110;
                        end
                        3'b111: begin   // andi
                            alu_fun = 4'b0111;
                        end
                    endcase
                end
                7'b0110011: begin // add, and, or, sll, slt, sltu, sra, srl, sub, xor
                    // All R-Type
                    // always
                    alu_srcA = 0;
                    alu_srcB = 0;
                    pcSource = 0; // PC++4;
                    rf_wr_sel = 3; // always writing to wd
                    case(SIZE_SIGN)
                        3'b000: begin   // add, sub
                            case (IR)
                                1'b1: alu_fun = 4'b1000; // sub
                                1'b0: alu_fun = 4'b0000; // add
                            endcase
                        end
                        3'b001: begin   // sll
                            alu_fun = 4'b0001;
                        end
                        3'b010: begin   // slt
                            alu_fun = 4'b0010;
                        end
                        3'b011: begin   // sltu
                            alu_fun = 4'b0011;
                        end
                        3'b100: begin   // xor
                            alu_fun = 4'b0100;
                        end
                        3'b101: begin   // sra, srl
                            case (IR)
                                1'b1: alu_fun = 4'b1101; // is sra
                                1'b0: alu_fun = 4'b0101; // is srl              
                            endcase
                        end
                        3'b110: begin   // or
                            alu_fun = 4'b0110;
                        end
                        3'b111: begin   // and
                            alu_fun = 4'b0111;
                        end
                    endcase 
                end
                7'b0110111: begin // only for lui
                    // Is U-TYPE
                    alu_srcA = 1;
                    // DON'T CARE WHAT alu_srcB is!
                    pcSource = 0;  //PC++4;
                    rf_wr_sel = 3; // writing to register
                    alu_fun = 4'b1001; // lui is special!
                end
                7'b0010111: begin // only for auipc
                    // Is U-TYPE
                    alu_srcA = 1;
                    alu_srcB = 3;
                    pcSource = 0; // PC++4;
                    rf_wr_sel = 3; // writing to register
                    alu_fun = 4'b0000; // just add
                end
                7'b1100011: begin // beq, bge, bgeu, blt, bltu, and bne
                    // use br_...
                    // don't care about alu_srcA/B, nor about rf_wr_sel since no write.
                    // alu_fun also doesn't matter here.
                    case (SIZE_SIGN)
                        // for each of the following, pcSource = 2 indicates a
                        // need to branch. = 0 says the case failed here. 
                        3'b000: begin // beq
                            case (br_eq)
                                1'b1: pcSource = 2; 
                                1'b0: pcSource = 0;
                            endcase
                        end
                        3'b001: begin // bne
                            case (br_eq)
                                1'b0: pcSource = 2; 
                                1'b1: pcSource = 0;
                            endcase
                        end
                        3'b100: begin // blt
                            case (br_lt)
                                1'b1: pcSource = 2; 
                                1'b0: pcSource = 0;
                            endcase
                        end
                        3'b101: begin // bge
                            case (br_lt)
                                1'b0: pcSource = 2; 
                                1'b1: pcSource = 0;
                            endcase
                        end
                        3'b110: begin // bltu
                            case (br_ltu)
                                1'b1: pcSource = 2; 
                                1'b0: pcSource = 0;
                            endcase
                        end
                        3'b111: begin // bgeu
                            case (br_ltu)
                                1'b0: pcSource = 2; 
                                1'b1: pcSource = 0;
                            endcase
                        end
                        default: begin // shouldn't happen, but just in case ignore!
                            pcSource = 0; // by default just keep on swimming
                        end
                    endcase
                end
                7'b1101111: begin // just jal
                    // J-TYPE
                    // alu not used here ...
                    pcSource = 3;
                    rf_wr_sel = 0; // rd needs PC + 4 part
                end
                7'b1100111: begin // just jalr
                    // I_TYPE
                    // again ALU not used here
                    pcSource = 1;
                    rf_wr_sel = 0; // rd needs PC + 4 part
                end
                7'b0100011: begin // sb, sh, sw
                    alu_srcA = 0;
                    alu_srcB = 2;
                    pcSource = 0; // PC++4;
                    // don't care about rf_wr_sel. regWrite should be off anyways.
                    alu_fun = 4'b0000; // just add
                end
                7'b1110011: begin // csrrw, mret.
                    case (SIZE_SIGN)
                        3'b001: begin   // csrrw
                            alu_fun = 4'b1001; // use lui-copy since we want to extract rs1 contents toward CSR_WD
                            alu_srcA =      0; // need to select the correct register
                            // note that srcB doesn't matter here, as lui-copy doesn't use it. 
                            pcSource =      0; // we are always just doing the instruction and moving on ...
                            rf_wr_sel =     1; // when loading data to register need to use CSR_RD
                        end
                        3'b010: begin   // csrrs TODO
                            alu_fun = 4'b0110; // OR: CSR[csr] | rs1
                            alu_srcA =      0; // use just rs1
                            alu_srcB =      4; // use CSR[csr]
                            pcSource =      0; // PC++4
                            rf_wr_sel =     1; // write to register via CSR
                        end
                        3'b011: begin   // csrrc
                            alu_fun = 4'b0111; // AND: CSR[csr] & ~rs1 
                            alu_srcA =      2; // use ~rs1
                            alu_srcB =      4; // use CSR[csr]
                            pcSource =      0; // PC++4
                            rf_wr_sel =     1; // write to register via CSR
                        end
                        3'b000: begin   // mret
                            // alu stuff doesn't matter here... use defaults.
                            pcSource =  5; // need to load mepc back in...
                            rf_wr_sel = 0; // don't write to a register!
                        end
                        default: begin  // should never happen but just in case.
                            alu_fun =   0;
                            alu_srcA =  0;
                            alu_srcB =  0;
                            pcSource =  0;
                            rf_wr_sel = 0;
                        end
                    endcase
                end
                default: begin // contains some of the cases where we have
                    alu_fun = 0;
                    alu_srcA = 0;
                    alu_srcB = 0;
                    pcSource = 0;
                    rf_wr_sel = 0;
                end         
            endcase
        end
    end
endmodule
