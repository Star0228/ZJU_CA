`timescale 1ns / 1ps

module ROM_D(
    input[6:0] a,
    output[31:0] spo
);

    reg[31:0] inst_data[0:127];

    initial	begin
        $readmemh("D:/CS/Verilog-studying/CA/Lab3_4_doc/lab4/riscv_sources/rom.hex", inst_data);
    end

    assign spo = inst_data[a];

endmodule