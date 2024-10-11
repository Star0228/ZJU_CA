`timescale 1ns / 1ps

module core_sim;
    input clk, rst;
    input interrupt;

    RV32core core(
        .debug_en(1'b0),
        .debug_step(1'b0),
        .debug_addr(7'b0),
        .debug_data(),
        .clk(clk),
        .rst(rst),
        .interrupter(interrupt)
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
    wire[31:0] mstatus = core.exp_unit.csr.CSR[0];
    wire[31:0] mie = core.exp_unit.csr.CSR[4];
    wire[31:0] mtvec = core.exp_unit.csr.CSR[5];
    wire[31:0] mepc = core.exp_unit.csr.CSR[9];
    wire[31:0] mcause = core.exp_unit.csr.CSR[10];
    wire[31:0] mip = core.exp_unit.csr.CSR[12];

endmodule