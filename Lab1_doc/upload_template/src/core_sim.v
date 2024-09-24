`timescale 1ns / 1ps

module core_sim;
    input clk, rst;

    RV32core core(
        .debug_en(1'b0),
        .debug_step(1'b0),
        .debug_addr(7'b0),
        .debug_data(),
        .clk(clk),
        .rst(rst),
        .interrupter(1'b0)
    );

    integer i;

    // signals here
    wire [31:0] pc = core.PC_IF;
    reg [31:0] regs [1:31];
    always @* begin
        for(i = 1; i < 32; i = i + 1) begin
            regs[i] <= core.register.register[i];
        end
    end
    wire pc_en = core.PC_EN_IF;
    wire fd_en = core.reg_FD_EN;
    wire fd_stall = core.reg_FD_stall;
    wire fd_flush = core.reg_FD_flush;
    wire de_en = core.reg_DE_EN;
    wire de_flush = core.reg_DE_flush;
    wire em_en = core.reg_EM_EN;
    wire em_flush = core.reg_EM_flush;
    wire mw_en = core.reg_MW_EN;

endmodule