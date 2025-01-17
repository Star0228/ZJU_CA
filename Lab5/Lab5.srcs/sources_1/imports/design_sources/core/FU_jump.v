`timescale 1ns / 1ps

module FU_jump(
	input clk, EN, JALR,
	input[2:0] cmp_ctrl,
	input[31:0] rs1_data, rs2_data, imm, PC,
	output[31:0] PC_jump, PC_wb,
	output cmp_res
);
    reg TO_BE_FILLED = 0;

    reg state;//用来强行延迟一个周期
	initial begin
        state = 0;
    end

	reg JALR_reg;
	reg[2:0] cmp_ctrl_reg;
	reg[31:0] rs1_data_reg, rs2_data_reg, imm_reg, PC_reg;
	
	always@(posedge clk) begin
        if(EN & ~state) begin
            JALR_reg <= JALR;
            cmp_ctrl_reg <= cmp_ctrl;
            rs1_data_reg <= rs1_data;
            rs2_data_reg <= rs2_data;
            imm_reg <= imm;
            PC_reg <= PC;
            state <= 1;
        end
        else state <= 0;
    end

    cmp_32 cmp(.a(rs1_data_reg), .b(rs2_data_reg), .ctrl(cmp_ctrl_reg), .c(cmp_res));//(.a(TO_BE_FILLED), .b(TO_BE_FILLED), .ctrl(TO_BE_FILLED), .c(cmp_res));

    add_32 add(.a(JALR_reg?rs1_data_reg:PC_reg), .b(imm_reg), .c(PC_jump));//(.a(TO_BE_FILLED), .b(TO_BE_FILLED), .c(PC_jump));//第一个空有坑

    add_32 add2(.a(PC_reg), .b(32'd4), .c(PC_wb));//(.a(PC_reg), .b(TO_BE_FILLED), .c(PC_wb));


endmodule