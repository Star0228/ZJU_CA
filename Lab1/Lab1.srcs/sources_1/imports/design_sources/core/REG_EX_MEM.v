`timescale 1ns / 1ps

module   REG_EX_MEM(input clk,
                    input rst,
                    input EN,
                    input flush,
                    input [31:0] IR_EX,
                    input [31:0] PCurrent_EX,
                    input [31:0] ALUO_EX,
                    input [31:0] B_EX,
                    input [4:0]  rd_EX,
                    input DatatoReg_EX, 
                    input RegWrite_EX,
                    input WR_EX,
                    input[2:0] u_b_h_w_EX,
                    input MIO_EX,

                    output reg[31:0] PCurrent_MEM,
                    output reg[31:0] IR_MEM,
                    output reg[31:0] ALUO_MEM,
                    output reg[31:0] Datao_MEM,
                    output reg[4:0]  rd_MEM, 
                    output reg       DatatoReg_MEM,
                    output reg       RegWrite_MEM, 
                    output reg       WR_MEM,
                    output reg[2:0]  u_b_h_w_MEM,
                    output reg       MIO_MEM
                );

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            IR_MEM       <= 0;
            PCurrent_MEM <= 0;
            rd_MEM       <= 0;
            RegWrite_MEM <= 0;
            WR_MEM       <= 0;
            MIO_MEM      <= 0;
        end
        else if(EN) begin                            
                IR_MEM       <= IR_EX;
                PCurrent_MEM <= PCurrent_EX;
                ALUO_MEM     <= ALUO_EX;
                Datao_MEM    <= B_EX;                   
                DatatoReg_MEM <= DatatoReg_EX;
                RegWrite_MEM  <= RegWrite_EX;
                WR_MEM        <= WR_EX;
                rd_MEM        <= rd_EX;
                u_b_h_w_MEM   <= u_b_h_w_EX;
                MIO_MEM       <= MIO_EX;
        end
    end

endmodule