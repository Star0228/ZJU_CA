`timescale 1ns / 1ps

module FU_div(
    input clk, EN,
    input[31:0] A, B,
    output[31:0] res
);
    reg TO_BE_FILLED = 0;
    wire res_valid;
    wire[63:0] divres;
    
    reg state;//用来强行延迟一个周期
    initial begin
        state = 0;
    end

    reg A_valid, B_valid;
    reg[31:0] A_reg, B_reg;

    always@(posedge clk) begin
        if(EN & ~state) begin
            A_reg <= TO_BE_FILLED;
            B_reg <= TO_BE_FILLED;
            A_valid <= 1;
            B_valid <= 1;
            state <= 1;
        end
        else if(res_valid) begin
            A_valid <= 0;
            B_valid <= 0;
            state <= 0;
        end
    end
    

    divider div(.aclk(clk),
        .s_axis_dividend_tvalid(A_valid),
        .s_axis_dividend_tdata(A_reg),
        .s_axis_divisor_tvalid(B_valid), 
        .s_axis_divisor_tdata(B_reg),
        .m_axis_dout_tvalid(res_valid), 
        .m_axis_dout_tdata(divres)
    );

    assign res = divres[TO_BE_FILLED:TO_BE_FILLED];

endmodule