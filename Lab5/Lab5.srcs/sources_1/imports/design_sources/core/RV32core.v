`timescale 1ns / 1ps

module  RV32core(
        input debug_en,  // debug enable
        input debug_step,  // debug step clock
        input [6:0] debug_addr,  // debug address
        output[31:0] debug_data,  // debug data
        input clk,  // main clock
        input rst,  // synchronous reset
        input interrupter  // interrupt source, for future use
    );
    reg TO_BE_FILLED = 0;
    wire debug_clk;
    wire[31:0] debug_regs;

    debug_clk clock(.clk(clk),.debug_en(debug_en),.debug_step(debug_step),.debug_clk(debug_clk));

    wire reg_IF_EN, reg_ID_EN, reg_ID_flush, FU_ALU_EN, FU_mem_EN, FU_mul_EN, FU_div_EN, FU_jump_EN;
    wire RegWrite_ctrl, ALUSrcA_ctrl, ALUSrcB_ctrl, mem_w_ctrl, branch_ctrl;
    wire[2:0] ImmSel_ctrl, DatatoReg_ctrl;
    wire[3:0] ALUControl_ctrl, Jump_ctrl;
    wire[4:0] rd_ctrl;


    wire [31:0] PC_IF, next_PC_IF, PC_4_IF, inst_IF;

    wire valid_ID;
    wire[31:0]inst_ID, PC_ID, Imm_out_ID, rs1_data_ID, rs2_data_ID, ALUA_ID, ALUB_ID;

    wire cmp_res_FU;
    wire[31:0]ALUout_FU, mem_data_FU, mulres_FU, divres_FU, PC_jump_FU, PC_wb_FU;

    wire[31:0]ALUout_WB, mem_data_WB, mulres_WB, divres_WB, PC_wb_WB, wt_data_WB;


    // IF
    REG32 REG_PC(.clk(debug_clk),.rst(rst),.CE(reg_IF_EN),.D(next_PC_IF),.Q(PC_IF));
    
    add_32 add_IF(.a(PC_IF),.b(32'd4),.c(PC_4_IF));

    MUX2T1_32 mux_IF(.I0(PC_4_IF),.I1(PC_jump_FU),.s(branch_ctrl),.o(next_PC_IF));

    ROM_D inst_rom(.a(PC_IF[8:2]),.spo(inst_IF));


    //Issue
    REG_ID reg_ID(.clk(debug_clk),.rst(rst),.EN(reg_ID_EN),
        .flush(reg_ID_flush),.PCOUT(PC_IF),.IR(inst_IF),

        .IR_ID(inst_ID),.PCurrent_ID(PC_ID),.valid(valid_ID));
    
    CtrlUnit ctrl(.clk(debug_clk),.rst(rst),.inst(inst_ID),.valid_ID(valid_ID),
        .cmp_res_FU(cmp_res_FU),

        .reg_IF_en(reg_IF_EN),.branch_ctrl(branch_ctrl),.reg_ID_en(reg_ID_EN),
        .reg_ID_flush(reg_ID_flush),.ImmSel(ImmSel_ctrl),.ALU_en(FU_ALU_EN),
        .MEM_en(FU_mem_EN),.MUL_en(FU_mul_EN),.DIV_en(FU_div_EN),.JUMP_en(FU_jump_EN),
        .JUMP_op(Jump_ctrl),.ALU_op(ALUControl_ctrl),.MEM_we(mem_w_ctrl),
        .ALUSrcA(ALUSrcA_ctrl),.ALUSrcB(ALUSrcB_ctrl),
        .write_sel(DatatoReg_ctrl),.reg_write(RegWrite_ctrl),.rd_ctrl(rd_ctrl));

    ImmGen imm_gen(.ImmSel(ImmSel_ctrl), .inst_field(inst_ID), .Imm_out(Imm_out_ID));

    Regs register(.clk(debug_clk),.rst(rst),
        .R_addr_A(inst_ID[19:15]),.rdata_A(rs1_data_ID),
        .R_addr_B(inst_ID[24:20]),.rdata_B(rs2_data_ID),
        .L_S(RegWrite_ctrl),.Wt_addr(rd_ctrl),.Wt_data(wt_data_WB),
        .Debug_addr(debug_addr[4:0]),.Debug_regs(debug_regs));

    MUX2T1_32 mux_imm_ALU_ID_A(.I0(rs1_data_ID),.I1(PC_ID),.s(ALUSrcA_ctrl),.o(ALUA_ID));       

    MUX2T1_32 mux_imm_ALU_ID_B(.I0(rs2_data_ID),.I1(Imm_out_ID),.s(ALUSrcB_ctrl),.o(ALUB_ID));  


    // FU
    FU_ALU alu(.clk(debug_clk),.EN(FU_ALU_EN),
        .ALUControl(ALUControl_ctrl),.ALUA(ALUA_ID),.ALUB(ALUB_ID),.res(ALUout_FU),
        .zero(),.overflow());

    FU_mem mem(.clk(debug_clk),.EN(FU_mem_EN),
        .mem_w(mem_w_ctrl),.bhw(inst_ID[14:12]),.rs1_data(rs1_data_ID),.rs2_data(rs2_data_ID),
        .imm(Imm_out_ID),.mem_data(mem_data_FU));

    FU_mul mu(.clk(debug_clk),.EN(FU_mul_EN),
        .A(rs1_data_ID),.B(rs2_data_ID),.res(mulres_FU));

    FU_div du(.clk(debug_clk),.EN(FU_div_EN),
        .A(rs1_data_ID),.B(rs2_data_ID),.res(divres_FU));

    FU_jump ju(.clk(debug_clk),.EN(FU_jump_EN),
        .JALR(Jump_ctrl[3]),.cmp_ctrl(Jump_ctrl[2:0]),.rs1_data(rs1_data_ID),.rs2_data(rs2_data_ID),
        .imm(Imm_out_ID),.PC(PC_ID),.PC_jump(PC_jump_FU),.PC_wb(PC_wb_FU),.cmp_res(cmp_res_FU));


    // WB
    MUX8T1_32 mux_DtR(
        .s(DatatoReg_ctrl),

        .I0(32'b0),
        .I1(ALUout_FU),
        .I2(mem_data_FU),
        .I3(mulres_FU),
        .I4(divres_FU),
        .I5(PC_wb_FU),
        .I6(32'b0),
        .I7(32'b0),
        
        .o(wt_data_WB));
    // MUX8T1_32 mux_DtR(
    // .s(TO_BE_FILLED),

    // .I0(TO_BE_FILLED),
    // .I1(TO_BE_FILLED),
    // .I2(TO_BE_FILLED),
    // .I3(TO_BE_FILLED),
    // .I4(TO_BE_FILLED),
    // .I5(TO_BE_FILLED),
    // .I6(TO_BE_FILLED),
    // .I7(TO_BE_FILLED),
    
    // .o(TO_BE_FILLED));

wire [15:0] debug_reg_data = register.register[1] + register.register[2] + register.register[3] + register.register[4]
                      + register.register[5] + register.register[6] + register.register[7] + register.register[8]
                      + register.register[9] + register.register[10] + register.register[11] + register.register[12]
                      + register.register[13] + register.register[14] + register.register[15] + register.register[16]
                      + register.register[17] + register.register[18] + register.register[19] + register.register[20]
                      + register.register[21] + register.register[22] + register.register[23] + register.register[24]
                      + register.register[25] + register.register[26] + register.register[27] + register.register[28]
                      + register.register[29] + register.register[30] + register.register[31];
    wire [15:0] debug_addr_data = PC_IF;
    assign debug_data = {debug_addr_data, debug_reg_data};


endmodule