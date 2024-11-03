`timescale 1ns / 1ps

module multiplier(
    input wire CLK,
    input wire[31:0] A,
    input wire[31:0] B,
    output wire[31:0] P
    );
    integer i;

    reg[31:0] buffer[0:5];
    wire res = A * B;
    always @(posedge CLK) begin
        buffer[5] <= res;
        for(i=0; i<5; i=i+1) begin
            buffer[i] <= buffer[i+1];
        end
    end
    assign P = buffer[0];

endmodule

module divider(
    input wire aclk,
    input wire s_axis_dividend_tvalid,
    input wire[31:0] s_axis_dividend_tdata,
    input wire s_axis_divisor_tvalid,
    input wire[31:0] s_axis_divisor_tdata,
    output wire m_axis_dout_tvalid,
    output wire[31:0] m_axis_dout_tdata
    );
    integer i;

    reg[31:0] buffer[0:31];
    reg valid[0:31];
    wire res = s_axis_dividend_tdata / s_axis_divisor_tdata;
    always @(posedge aclk) begin
        buffer[31] <= res;
        valid[31] <= s_axis_dividend_tvalid & s_axis_divisor_tvalid;
        for(i=0; i<31; i=i+1) begin
            buffer[i] <= buffer[i+1];
            valid[i] <= valid[i+1];
        end
    end
    assign m_axis_dout_tvalid = valid[0];
    assign m_axis_dout_tdata = buffer[0];

endmodule

module debug_clk(
    input clk,
    input debug_en,
    input debug_step,
    output debug_clk
);
    assign debug_clk = clk;
endmodule

