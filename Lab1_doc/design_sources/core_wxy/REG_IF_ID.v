`timescale 1ns / 1ps

module    REG_IF_ID(input clk,                                      //IF/ID Latch
                    input rst,
                    input EN,                                       //流水寄存器使能
                    input Data_stall,                               //数据竞争等待
                    input flush,                                    //控制竞争清除并等待
                    input [31:0] PCOUT,                             //指令存储器指针
                    input [31:0] IR,                                //指令存储器输出

                    output reg[31:0] IR_ID,                         //取指锁存
                    output reg[31:0] PCurrent_ID                    //当前存在指令地址
                );
                
    reg TO_BE_FILLED = 0; //所有这个寄存器占的位置都需要填入正确的值
                          //可能是wire或reg的名称，可能是一个算式，也可能是某个常数
    always @(posedge clk or posedge rst) begin
        if(rst) begin           //RESET
             IR_ID                  <= TO_BE_FILLED;
             PCurrent_ID            <= TO_BE_FILLED;
        end
        else if(EN)begin
            if(Data_stall)begin //STALL
                IR_ID               <= TO_BE_FILLED;
                PCurrent_ID         <= TO_BE_FILLED;
            end         
            else if(flush)begin //FLUSH
                IR_ID               <= TO_BE_FILLED;
                PCurrent_ID         <= TO_BE_FILLED;
            end    
            else begin          //NORMAL
                IR_ID               <= TO_BE_FILLED;
                PCurrent_ID         <= TO_BE_FILLED;
            end         
        end
        else begin
            IR_ID                   <= TO_BE_FILLED;
            PCurrent_ID             <= TO_BE_FILLED;
        end
    end

endmodule