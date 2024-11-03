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
        .interrupter(interrupt)
    );

    integer i;

    // signals here
    localparam
        DATA_MEM_SIZE = 2048,      // change according to lab4.json
        CACHE_SIZE_IN_WORD = 256;  // change according to lab4.json
    
    wire [31:0] pc = core.PC_IF;
    reg [31:0] regs [1:31];
    always @* begin
        for(i = 1; i < 32; i = i + 1) begin
            regs[i] = core.register.register[i];
        end
    end
    wire[31:0] mem_addr = core.ram_addr;
    wire mem_ack = core.ram_ack;
    wire[31:0] cache_o_data = core.Datain_MEM;
    wire cmu_stall = core.cmu_stall;
    reg[31:0] data_mem[0:DATA_MEM_SIZE-1];
    always @* begin
        for (i = 0; i < DATA_MEM_SIZE; i = i + 1) begin
            data_mem[i] = core.RAM.data[i];
        end
    end
    reg[31:0] cache_data[0:CACHE_SIZE_IN_WORD-1];
    always @* begin
        for (i = 0; i < CACHE_SIZE_IN_WORD; i = i + 1) begin
            cache_data[i] = core.CMU.CACHE.inner_data[i];
        end
    end

endmodule