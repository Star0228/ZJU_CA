`timescale 1ns / 1ps

module FU_jump(
	input clk, EN, JALR,
	input[3:0] cmp_ctrl,
	input[31:0] rs1_data, rs2_data, imm, PC,
	output[31:0] PC_jump, PC_wb,
	output is_jump, finish
);
	reg TO_BE_FILLED = 0;
	wire cmp_res;
    reg state;
    assign finish = TO_BE_FILLED;
	initial begin
        state = 0;
    end

	reg JALR_reg;
	reg[3:0] cmp_ctrl_reg = 0;
	reg[31:0] rs1_data_reg = 0, rs2_data_reg = 0, imm_reg = 0, PC_reg = 0;

	always@(posedge clk) begin
		if(EN & ~state) begin // state == 0
			// 这里需要填入多行 Multiple rows need to be filled in here
            TO_BE_FILLED <= 0;
			state <= 1;
		end
		else state <= 0;
	end

	cmp_32 cmp(.a(rs1_data_reg),.b(rs2_data_reg),.ctrl(cmp_ctrl_reg[3:1]),.c(cmp_res));

	add_32 a(.a(JALR_reg ? rs1_data_reg : PC_reg),.b(imm_reg),.c(PC_jump));

	add_32 b(.a(PC_reg),.b(32'd4),.c(PC_wb));

	assign is_jump = TO_BE_FILLED;

endmodule