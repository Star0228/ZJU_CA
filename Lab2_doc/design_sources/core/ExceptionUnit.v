`timescale 1ns / 1ps

module ExceptionUnit(
    input clk, rst,
    input csr_rw_in,
    // write/set/clear (funct bits from instruction)
    input[1:0] csr_wsc_mode_in,
    input csr_w_imm_mux,
    input[11:0] csr_rw_addr_in,
    input[31:0] csr_w_data_reg,
    input[4:0] csr_w_data_imm,
    output[31:0] csr_r_data_out,

    input interrupt,
    input illegal_inst,
    input l_access_fault,
    input s_access_fault,
    input ecall_m,

    input mret,

    input[31:0] epc_cur,
    input[31:0] epc_next,
    output[31:0] PC_redirect,
    output redirect_mux,

    output reg_FD_flush, reg_DE_flush, reg_EM_flush, reg_MW_flush, 
    output RegWrite_cancel
);
    reg TO_BE_FILLED = 0;

    reg[11:0] csr_waddr;
    reg[31:0] csr_wdata;
    reg csr_w;
    reg[1:0] csr_wsc;
    wire[11:0] csr_raddr;
    wire[31:0] csr_rdata;

    wire[31:0] mstatus;
    wire[31:0] mepc;
    wire[31:0] mtvec;
    wire[31:0] mie;

    wire interrupt_or_exception;
    wire[31:0] mepc_w;
    wire[31:0] mcause_w;
    wire[31:0] mtval_w;

    wire[3:0] waddr_map;
    wire enable_exception;

    wire [3:0] exception_index;

    assign exception_index = TO_BE_FILLED; //请查阅RV32I手册，确定mcause中illegal_inst，l_access_fault，s_access_fault和ecall_m的编码，另外注意interrupt和exception的关系

    assign enable_exception = mstatus[3];

    assign interrupt_or_exception = TO_BE_FILLED;
    
    assign reg_FD_flush = interrupt_or_exception | mret;
    assign reg_DE_flush = TO_BE_FILLED;
    assign reg_EM_flush = TO_BE_FILLED;
    assign reg_MW_flush = TO_BE_FILLED;
    assign RegWrite_cancel = TO_BE_FILLED;
    assign redirect_mux = TO_BE_FILLED;

    assign PC_redirect = TO_BE_FILLED;
    assign csr_raddr = csr_rw_addr_in;
    assign mepc_w = TO_BE_FILLED;
    assign mcause_w = {interrupt,{27{1'b0}},exception_index};
    assign mtval_w = epc_cur;
    assign csr_r_data_out = csr_rdata;

    CSRRegs csr(.clk(clk),.rst(rst),.csr_w(csr_w),.raddr(csr_raddr),.waddr(csr_waddr),
        .wdata(csr_wdata),.rdata(csr_rdata),.mstatus(mstatus),.csr_wsc_mode(csr_wsc),
        .mtvec(mtvec),.mepc(mepc),.interrupt(interrupt_or_exception),.mepc_w(mepc_w),
        .mcause_w(mcause_w),.mtval_w(mtval_w),.mret(mret),.waddr_map(waddr_map),.mie(mie));

    always @ (negedge clk or posedge rst) begin
        if(rst) begin
          csr_waddr<=0;
          csr_wdata<=0;
          csr_w<=0;
          csr_wsc<=0;
        end
        else begin
            if(csr_rw_in) begin
                csr_waddr <= csr_rw_addr_in;
                csr_wdata <= TO_BE_FILLED ? {{27{1'b0}},TO_BE_FILLED} : TO_BE_FILLED;
                csr_w <= 1;
                csr_wsc <= csr_wsc_mode_in;
            end 
            else begin
                csr_waddr<=0;
                csr_wdata<=0;
                csr_w<=0;
                csr_wsc<=0;
            end            
        end
    end
endmodule