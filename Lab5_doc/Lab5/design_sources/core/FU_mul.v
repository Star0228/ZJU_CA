`timescale 1ns / 1ps

module FU_mul(
    input clk, EN,
    input[31:0] A, B,
    output[31:0] res
);

    reg[6:0] state;//用来强行延迟执行来模拟latency
    initial begin
        state = 0;
    end
    
    reg TO_BE_FILLED = 0;
    reg[31:0] A_reg, B_reg;
    
    always@(posedge clk) begin
        if(EN & ~|state) begin
            A_reg <= A;
            B_reg <= B;
            state <= TO_BE_FILLED;
        end
        else state <= {1'b0, TO_BE_FILLED};//这里的作用就是强行将这个模块延迟N个周期再输出结果，使其符合config.json的设定
    end
    


    wire [63:0] mulres;
    multiplier mul(.CLK(clk),.A(A_reg),.B(B_reg),.P(mulres));

    assign res = mulres[TO_BE_FILLED:TO_BE_FILLED];

endmodule