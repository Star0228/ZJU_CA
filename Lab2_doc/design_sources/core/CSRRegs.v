`timescale 1ns / 1ps

module CSRRegs(
    input clk, rst,
    input[11:0] raddr, waddr,
    input[31:0] wdata,
    input csr_w,
    input[1:0] csr_wsc_mode,
    output[31:0] rdata,
    output[31:0] mstatus,
    output[31:0] mtvec,
    output[31:0] mepc,
    output[31:0] mie,
    input interrupt,
    input[31:0] mepc_w,
    input[31:0] mcause_w,
    input[31:0] mtval_w,
    input mret,

    output[3:0] waddr_map
);
    reg TO_BE_FILLED = 0;
    
    reg[31:0] CSR[0:15];

    // Address mapping. The address is 12 bits, but only 4 bits are used in this module.
    wire raddr_valid = raddr[11:7] == 5'h6 && raddr[5:3] == 3'h0;
    wire[3:0] raddr_map = (raddr[6] << 3) + raddr[2:0];
    wire waddr_valid = waddr[11:7] == 5'h6 && waddr[5:3] == 3'h0;
    
    assign waddr_map = (waddr[6] << 3) + waddr[2:0];

    assign mstatus = CSR[0];
    assign mepc = CSR[9];
    assign mtvec = CSR[5];
    assign mie = CSR[4];
    assign rdata = CSR[raddr_map];

    always@(posedge clk or posedge rst) begin
        if(rst) begin
			CSR[0] <= 32'h88;//mstatus
			CSR[1] <= 0;
			CSR[2] <= 0;
			CSR[3] <= 0;
			CSR[4] <= 32'hfff;//mie
			CSR[5] <= 0;//mtvec
			CSR[6] <= 0;
			CSR[7] <= 0;
			CSR[8] <= 0;
			CSR[9] <= 0;//mepc
			CSR[10] <= 0;//mcause
			CSR[11] <= 0;//mtval
			CSR[12] <= 0;
			CSR[13] <= 0;
			CSR[14] <= 0;
			CSR[15] <= 0;
		end
        else if(interrupt) begin
            CSR[0][7] <= TO_BE_FILLED;
            CSR[0][3] <= 0;
            CSR[9] <= TO_BE_FILLED;
            CSR[10] <= TO_BE_FILLED;
            CSR[11] <= TO_BE_FILLED;
        end
        else if(mret) begin
            CSR[0][3] <= TO_BE_FILLED;
            CSR[0][7] <= 1;
        end
        else if(csr_w) begin
            case(csr_wsc_mode)
                2'b01: CSR[waddr_map] <= TO_BE_FILLED;
                2'b10: CSR[waddr_map] <= TO_BE_FILLED;
                2'b11: CSR[waddr_map] <= TO_BE_FILLED;
                default: CSR[waddr_map] <= wdata;
            endcase            
        end
    end
endmodule