`timescale 1ps/1ps

module HazardDetectionUnit(
    input clk,
    input Branch_ID, rs1use_ID, rs2use_ID,
    input[1:0] hazard_optype_ID,
    input[4:0] rd_EXE, rd_MEM, rs1_ID, rs2_ID, rs2_EXE,
    input cmu_stall,
    output PC_EN_IF, reg_FD_EN, reg_FD_stall, reg_FD_flush,
        reg_DE_EN, reg_DE_flush, reg_EM_EN, reg_EM_flush, reg_MW_EN, reg_MW_flush,
    output forward_ctrl_ls,
    output[1:0] forward_ctrl_A, forward_ctrl_B
);
    reg TO_BE_FILLED = 0;
    assign reg_FD_EN = ~cmu_stall;//TO_BE_FILLED;
    assign reg_DE_EN = ~cmu_stall;//TO_BE_FILLED;
    assign reg_EM_EN = ~cmu_stall;//TO_BE_FILLED;
    assign reg_MW_EN = ~cmu_stall;//TO_BE_FILLED;
    assign reg_EM_flush = 0;
    assign reg_MW_flush = 0;

    reg[1:0] hazard_optype_EXE, hazard_optype_MEM;
    always@(posedge clk) begin
        hazard_optype_MEM <= hazard_optype_EXE & {2{~reg_EM_flush}};
        hazard_optype_EXE <= hazard_optype_ID & {2{~reg_DE_flush}};
    end

    parameter hazard_optype_ALU = 2'd1;
    parameter hazard_optype_LOAD = 2'd2;
    parameter hazard_optype_STORE = 2'd3;

    wire rs1_forward_1     = rs1use_ID && rs1_ID == rd_EXE && rd_EXE && hazard_optype_EXE == hazard_optype_ALU;
    wire rs1_forward_stall = rs1use_ID && rs1_ID == rd_EXE && rd_EXE && hazard_optype_EXE == hazard_optype_LOAD
                             && hazard_optype_ID != hazard_optype_STORE;
    wire rs1_forward_2     = rs1use_ID && rs1_ID == rd_MEM && rd_MEM && hazard_optype_MEM == hazard_optype_ALU && !rs1_forward_1;
    wire rs1_forward_3     = rs1use_ID && rs1_ID == rd_MEM && rd_MEM && hazard_optype_MEM == hazard_optype_LOAD;

    wire rs2_forward_1     = rs2use_ID && rs2_ID == rd_EXE && rd_EXE && hazard_optype_EXE == hazard_optype_ALU;
    wire rs2_forward_stall = rs2use_ID && rs2_ID == rd_EXE && rd_EXE && hazard_optype_EXE == hazard_optype_LOAD
                             && hazard_optype_ID != hazard_optype_STORE;
    wire rs2_forward_2     = rs2use_ID && rs2_ID == rd_MEM && rd_MEM && hazard_optype_MEM == hazard_optype_ALU && !rs2_forward_1;
    wire rs2_forward_3     = rs2use_ID && rs2_ID == rd_MEM && rd_MEM && hazard_optype_MEM == hazard_optype_LOAD;

    wire load_stall = rs1_forward_stall | rs2_forward_stall;

    assign PC_EN_IF = ~load_stall & ~cmu_stall;//TO_BE_FILLED;
    assign reg_FD_stall = load_stall;
    assign reg_FD_flush = Branch_ID;
    assign reg_DE_flush = load_stall;

    assign forward_ctrl_A = {2{rs1_forward_1}} & 2'd1 |
                            {2{rs1_forward_2}} & 2'd2 |
                            {2{rs1_forward_3}} & 2'd3 ;

    assign forward_ctrl_B = {2{rs2_forward_1}} & 2'd1 |
                            {2{rs2_forward_2}} & 2'd2 |
                            {2{rs2_forward_3}} & 2'd3 ;

    assign forward_ctrl_ls = rs2_EXE == rd_MEM && hazard_optype_EXE == hazard_optype_STORE
                            && hazard_optype_MEM == hazard_optype_LOAD;

endmodule