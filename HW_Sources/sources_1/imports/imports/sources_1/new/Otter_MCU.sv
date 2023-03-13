`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California Polytechnic State University, San Luis Obispo
// Engineer: Brian Mere
// 
// Create Date: 02/21/2023 11:27:10 PM
// Design Name: OTTER_MCU
// Module Name: OTTER_MCU
// Project Name: HW6
// Target Devices: Basys3 Boards
// Description: Collective MCU TOP Module!
// 
// Dependencies: None
//////////////////////////////////////////////////////////////////////////////////


module Otter_MCU(
    input [31:0] IOBUS_IN,
    input RST,
    input INTR,
    input CLK,
    output logic [31:0] IOBUS_OUT,
    output logic [31:0] IOBUS_ADDR,
    output logic IOBUS_WR
    );

    // flags
    logic reset, PCWrite, memRDEN1, memRDEN2, memWE2, regWrite;
    logic br_eq, br_lt, br_ltu;
    logic [1:0] rf_wr_sel, alu_srcA;
    logic [2:0] pcSource, alu_srcB;
    logic [3:0] alu_fun;
    // note the following are csr
    logic [31:0] csr_RD, mtvec, mepc;
    logic int_taken, csr_WE, mret_exec, mstatus_b3;

    // general connections
    logic[31:0] PC, PCP4, jalr, jal, branch, J_TYPE, B_TYPE, S_TYPE, I_TYPE,
    U_TYPE, rs1, rs2, IR, DOUT2, wd, result, srcA, srcB;
    // Note: we've named DOUT1 = IR for convienience.

    // commence the connecting ...
    
    // components
    add4adder PLUS4(
        .operand(PC),
        .added_out(PCP4)
    );

    logic [31:0] PCDIN;

    mux6sel PCMUX(
        .PC_P4(PCP4),
        .JALR(jalr),
        .BRANCH(branch),
        .JAL(jal),
        .MTVEC(mtvec),
        .MEPC(mepc),
        .PC_SOURCE(pcSource),
        .PC_DOUT(PCDIN)
    );

    program_counter PROG_COUNT(
        .PC_WRITE(PCWrite),
        .PC_RST(reset),
        .PC_DIN(PCDIN),
        .CLK(CLK),
        .PC_COUNT(PC)
    );

    Memory otter_memory(
        .MEM_CLK(CLK),
        .MEM_RDEN1(memRDEN1),
        .MEM_RDEN2(memRDEN2),
        .MEM_WE2(memWE2),
        .MEM_ADDR1(PC[15:2]),
        .MEM_ADDR2(result),
        .MEM_DIN2(rs2),
        .MEM_SIZE(IR[13:12]),
        .MEM_SIGN(IR[14]),
        .IO_IN(IOBUS_IN),
        .IO_WR(IOBUS_WR),
        .MEM_DOUT1(IR),
        .MEM_DOUT2(DOUT2)
    );

    REG_FILE registers(
        .RF_ADR1(IR[19:15]),
        .RF_ADR2(IR[24:20]),
        .RF_WA(IR[11:7]),
        .RF_WD(wd),
        .RF_EN(regWrite),
        .CLK(CLK),
        .RF_RS1(rs1),
        .RF_RS2(rs2)
    );

    IMMED_GEN imm_generator(
        .INSTRUCT(IR[31:7]),
        .U_TYPE(U_TYPE),
        .I_TYPE(I_TYPE),
        .S_TYPE(S_TYPE),
        .J_TYPE(J_TYPE),
        .B_TYPE(B_TYPE)
    );

    BRANCH_ADDR_GEN br_addr_gen(
        .PC(PC),
        .J_TYPE(J_TYPE),
        .B_TYPE(B_TYPE),
        .I_TYPE(I_TYPE),
        .RS1(rs1),
        .JALR(jalr),
        .BRANCH(branch),
        .JAL(jal)
    );

    BRANCH_COND_GEN br_cond_gen(
        .RS1(rs1),
        .RS2(rs2),
        .BR_EQ(br_eq),
        .BR_LT(br_lt),
        .BR_LTU(br_ltu)
    );

    ALU alu(
        .srcA(srcA),
        .srcB(srcB),
        .alu_fun(alu_fun),
        .result(result)
    );

    CU_DCDR CU_Decoder(
        .OPCODE(IR[6:0]),
        .SIZE_SIGN(IR[14:12]),
        .IR(IR[30]),
        .int_taken(int_taken),
        .br_eq(br_eq),
        .br_lt(br_lt),
        .br_ltu(br_ltu),
        .alu_fun(alu_fun),
        .alu_srcA(alu_srcA),
        .alu_srcB(alu_srcB),
        .pcSource(pcSource),
        .rf_wr_sel(rf_wr_sel)
    );

    CU_FSM State_Machine(
        .RST(RST),
        .CS_INTR(INTR & mstatus_b3),
        .OPCODE(IR[6:0]),
        .SIZE_SIGN(IR[14:12]),
        .CLK(CLK),
        .PCWRITE(PCWrite),
        .regWRITE(regWrite),
        .memWE2(memWE2),
        .memRDEN1(memRDEN1),
        .memRDEN2(memRDEN2),
        .reset(reset),
        .csr_WE(csr_WE),
        .int_taken(int_taken),
        .mret_exec(mret_exec)
    );

    CSR CSR(
        .CSR_RST(RST),
        .CSR_mret_exec(mret_exec),
        .CSR_INT_TAKEN(int_taken),
        .CSR_ADDR(IR[31:20]),
        .CSR_WR_EN(csr_WE),
        .CSR_PC(PC),
        .CSR_WD(result),
        .CSR_CLK(CLK),
        .CSR_MSTATUS_B3(mstatus_b3),
        .CSR_MEPC(mepc),
        .CSR_MTVEC(mtvec),
        .CSR_RD(csr_RD)
    );

    always_comb begin
        
        // Mux into REG_FILE
        case (rf_wr_sel)
            2'b00: wd = PCP4;
            2'b01: wd = csr_RD;
            2'b10: wd = DOUT2;
            2'b11: wd = result;
        endcase

        // Mux ALU A
        case (alu_srcA)
            2'b00: srcA = rs1;
            2'b01: srcA = U_TYPE;
            2'b10: srcA = ~rs1;
            default: srcA = 0;
        endcase

        // Mux ALU B
        case (alu_srcB)
            3'b000: srcB = rs2;
            3'b001: srcB = I_TYPE;
            3'b010: srcB = S_TYPE;
            3'b011: srcB = PC;
            3'b100: srcB = csr_RD;
            default: srcB = 0;
        endcase

        IOBUS_ADDR = result;
        IOBUS_OUT = rs2;
    end

endmodule
