`timescale 1ns / 1ps

module FU_mem(
    input clk, EN, mem_w,
    input[2:0] bhw,
    input[31:0] rs1_data, rs2_data, imm,
    output[31:0] mem_data
);

    reg[1:0] state;//用来强行延迟执行来模拟latency
    initial begin
        state = 0;
    end

    reg mem_w_reg;
    reg[2:0] bhw_reg;
    reg[31:0] rs1_data_reg, rs2_data_reg, imm_reg,addr;
    wire ack,stall;
    wire[31:0] mem_data_wire;
    reg [31:0] mem_data_reg;
    always@(posedge clk) begin
        TO_BE_FILLED <= 0;//这里需要填入一段逻辑，用来模拟latency，可以参照其它FU的写法
    end
    
    RAM_B ram(.clk(clk),.rst(1'b0),.cs(state>0),.we(mem_w_reg),.addr(addr),.din(rs2_data_reg),.dout(mem_data_wire),.stall(stall),.ack(ack));
    assign mem_data = mem_data_reg;

endmodule