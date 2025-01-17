`timescale 1ns / 1ps

module CtrlUnit(
    input clk,
    input rst,

    input[31:0] inst,
    input valid_ID,
    
    input cmp_res_FU,

    // IF
    output reg_IF_en, branch_ctrl,

    // ID
    output reg_ID_en, reg_ID_flush,
    output[2:0] ImmSel,
    output ALU_en, MEM_en, MUL_en, DIV_en, JUMP_en,
    
    // FU
    output[3:0] JUMP_op,
    output[3:0] ALU_op,
    output ALUSrcA,
    output ALUSrcB,
    output MEM_we,
    
    // WB
    output reg[2:0] write_sel,
    output reg[4:0] rd_ctrl,
    output reg reg_write
);
    reg TO_BE_FILLED = 0;
    always  @(posedge clk or posedge rst) begin
        if(rst) begin
            reg_write <= 0;
            rd_ctrl <= 0;
            write_sel <= 0;
        end else begin
            reg_write <= FU_writeback_en[reservation_reg[0]];
            rd_ctrl <= FU_write_to[reservation_reg[0]];
            write_sel <= reservation_reg[0];
        end
    end

    // instruction field
    wire[6:0] funct7 = inst[31:25];
    wire[2:0] funct3 = inst[14:12];
    wire[6:0] opcode = inst[6:0];
    wire[4:0] rd = inst[11:7];
    wire[4:0] rs1 = inst[19:15];
    wire[4:0] rs2 = inst[24:20];

    // type specification
    wire Rop = opcode == 7'b0110011;
    wire Iop = opcode == 7'b0010011;
    wire Bop = opcode == 7'b1100011;
    wire Lop = opcode == 7'b0000011;
    wire Sop = opcode == 7'b0100011;

    wire funct7_0  = funct7 == 7'h0;
    wire funct7_1  = funct7 == 7'h1;
    wire funct7_32 = funct7 == 7'h20;

    wire funct3_0 = funct3 == 3'h0;
    wire funct3_1 = funct3 == 3'h1;
    wire funct3_2 = funct3 == 3'h2;
    wire funct3_3 = funct3 == 3'h3;
    wire funct3_4 = funct3 == 3'h4;
    wire funct3_5 = funct3 == 3'h5;
    wire funct3_6 = funct3 == 3'h6;
    wire funct3_7 = funct3 == 3'h7;

    wire ADD  = Rop & funct3_0 & funct7_0;
    wire SUB  = Rop & funct3_0 & funct7_32;
    wire SLL  = Rop & funct3_1 & funct7_0;
    wire SLT  = Rop & funct3_2 & funct7_0;
    wire SLTU = Rop & funct3_3 & funct7_0;
    wire XOR  = Rop & funct3_4 & funct7_0;
    wire SRL  = Rop & funct3_5 & funct7_0;
    wire SRA  = Rop & funct3_5 & funct7_32;
    wire OR   = Rop & funct3_6 & funct7_0;
    wire AND  = Rop & funct3_7 & funct7_0;

    wire MUL    = Rop & funct3_0 & funct7_1;
    wire MULH   = Rop & funct3_1 & funct7_1;
    wire MULHSU = Rop & funct3_2 & funct7_1;
    wire MULHU  = Rop & funct3_3 & funct7_1;
    wire DIV    = Rop & funct3_4 & funct7_1;
    wire DIVU   = Rop & funct3_5 & funct7_1;
    wire REM    = Rop & funct3_6 & funct7_1;
    wire REMU    = Rop & funct3_7 & funct7_1;

    wire ADDI  = Iop & funct3_0;	
    wire SLTI  = Iop & funct3_2;
    wire SLTIU = Iop & funct3_3;
    wire XORI  = Iop & funct3_4;
    wire ORI   = Iop & funct3_6;
    wire ANDI  = Iop & funct3_7;
    wire SLLI  = Iop & funct3_1 & funct7_0;
    wire SRLI  = Iop & funct3_5 & funct7_0;
    wire SRAI  = Iop & funct3_5 & funct7_32;

    wire BEQ = Bop & funct3_0;
    wire BNE = Bop & funct3_1;
    wire BLT = Bop & funct3_4;
    wire BGE = Bop & funct3_5;
    wire BLTU = Bop & funct3_6;
    wire BGEU = Bop & funct3_7;

    wire LB =  Lop & funct3_0;
    wire LH =  Lop & funct3_1;
    wire LW =  Lop & funct3_2;
    wire LBU = Lop & funct3_4;
    wire LHU = Lop & funct3_5;

    wire SB = Sop & funct3_0;
    wire SH = Sop & funct3_1;
    wire SW = Sop & funct3_2;

    wire LUI   = opcode == 7'b0110111;
    wire AUIPC = opcode == 7'b0010111;

    wire JAL  =  opcode == 7'b1101111;
    wire JALR = (opcode == 7'b1100111) && funct3_0;

    wire R_valid = AND | OR | ADD | XOR | SLL | SRL | SRA | SUB | SLT | SLTU 
        | MUL | MULH | MULHSU | MULHU | DIV | DIVU | REM | REMU;
    wire I_valid = ANDI | ORI | ADDI | XORI | SLLI | SRLI | SRAI | SLTI | SLTIU;
    wire B_valid = BEQ | BNE | BLT | BGE | BLTU | BGEU;
    wire L_valid = LW | LH | LB | LHU | LBU;
    wire S_valid = SW | SH | SB;

    wire rd_used = R_valid | I_valid | JAL | JALR | L_valid | LUI | AUIPC;

    wire use_ALU = AND | OR | ADD | XOR | SLL | SRL | SRA | SUB | SLT | SLTU
        | I_valid | LUI | AUIPC;
    wire use_MEM = L_valid | S_valid;
    wire use_MUL = MUL | MULH | MULHSU | MULHU;
    wire use_DIV = DIV | DIVU | REM | REMU;
    wire use_JUMP = B_valid | JAL | JALR;

    wire[2:0] use_FU =  {3{use_ALU}}  & 3'd1 |
                        {3{use_MEM}}  & 3'd2 |
                        {3{use_MUL}}  & 3'd3 |
                        {3{use_DIV}}  & 3'd4 |
                        {3{use_JUMP}} & 3'd5 ;

    reg B_in_FU, J_in_FU;
    reg[5:0] FU_status;
    reg[2:0] reservation_reg [0:31];
    reg[4:0] FU_write_to [5:0];
    reg[5:0] FU_writeback_en;
    reg[4:0] FU_delay_cycles [5:0];
    reg reg_ID_flush_next;
    integer i;
    wire WAW = rd != 0 && ( ((rd == FU_write_to[1]) && !(
                                                            reservation_reg[0]==1&&0<FU_delay_cycles[use_FU]
                            ))||
                            ((rd == FU_write_to[2]) && !(
                                                            (reservation_reg[0]==2&&0<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[1]==2&&1<FU_delay_cycles[use_FU])
                            ))||
                            ((rd == FU_write_to[3]) && !(
                                                            (reservation_reg[0]==3&&0<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[1]==3&&1<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[2]==3&&2<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[3]==3&&3<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[4]==3&&4<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[5]==3&&5<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[6]==3&&6<FU_delay_cycles[use_FU])
                            ))||
                            ((rd == FU_write_to[4]) && !(
                                                            (reservation_reg[0]==4&&0<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[1]==4&&1<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[2]==4&&2<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[3]==4&&3<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[4]==4&&4<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[5]==4&&5<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[6]==4&&6<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[7]==4&&7<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[8]==4&&8<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[9]==4&&9<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[10]==4&&10<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[11]==4&&11<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[12]==4&&12<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[13]==4&&13<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[14]==4&&14<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[15]==4&&15<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[16]==4&&16<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[17]==4&&17<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[18]==4&&18<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[19]==4&&19<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[20]==4&&20<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[21]==4&&21<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[22]==4&&22<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[23]==4&&23<FU_delay_cycles[use_FU])
                            ))||
                            ((rd == FU_write_to[5]) && !(
                                                            (reservation_reg[0]==5&&0<FU_delay_cycles[use_FU])||
                                                            (reservation_reg[1]==5&&1<FU_delay_cycles[use_FU])
                            ))
                            );//TO_BE_FILLED;
    wire RAW_rs1 = rs1!=0 && (  rs1 == FU_write_to[1]||
                                rs1 == FU_write_to[2]||
                                rs1 == FU_write_to[3]||
                                rs1 == FU_write_to[4]||
                                rs1 == FU_write_to[5]);//TO_BE_FILLED;
    wire RAW_rs2 = rs2!=0 && (  rs2 == FU_write_to[1]||
                                rs2 == FU_write_to[2]||
                                rs2 == FU_write_to[3]||
                                rs2 == FU_write_to[4]||
                                rs2 == FU_write_to[5]);//TO_BE_FILLED;
    wire WB_structure_hazard = reservation_reg[FU_delay_cycles[use_FU]] != 0;//TO_BE_FILLED;
    wire FU_structure_hazard = FU_status[use_FU] == 1 && (reservation_reg[0]!=use_FU);//TO_BE_FILLED;
    wire FU_hazard = WAW|RAW_rs1|RAW_rs2|WB_structure_hazard|FU_structure_hazard;

    initial begin
        B_in_FU = 0;
        J_in_FU = 0;
        FU_status <= 6'b0;
        FU_writeback_en <= 6'b0;
        for (i=0; i<32; i=i+1)
		    reservation_reg[i] <= 0;
        for (i=0; i<6; i=i+1)
		    FU_write_to[i] <= 0;
        FU_delay_cycles[1] <= 5'd1;         // ALU cycles
        FU_delay_cycles[2] <= 5'd2;         // MEM cycles
        FU_delay_cycles[3] <= 5'd7;         // MUL cycles
        FU_delay_cycles[4] <= 5'd24;        // DIV cycles
        FU_delay_cycles[5] <= 5'd2;         // JUMP cycles
        reg_ID_flush_next <= 0;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            B_in_FU <= 0;
            J_in_FU <= 0;
            FU_status <= 6'b0;
            FU_writeback_en <= 6'b0;
            for (i=0; i<32; i=i+1)
                reservation_reg[i] <= 0;
            for (i=0; i<6; i=i+1)
                FU_write_to[i] <= 0;
            FU_delay_cycles[1] <= 5'd1;         // ALU cycles
            FU_delay_cycles[2] <= 5'd2;         // MEM cycles
            FU_delay_cycles[3] <= 5'd7;         // MUL cycles
            FU_delay_cycles[4] <= 5'd24;        // DIV cycles
            FU_delay_cycles[5] <= 5'd2;         // JUMP cycles
        end
        else begin
            if (reservation_reg[0] != 0) begin  // FU写回将在这周期完成，这里需要联系39行
                FU_writeback_en[reservation_reg[0]] <= 1'b0;//[TO_BE_FILLED] <= TO_BE_FILLED;
                FU_status[reservation_reg[0]] <= 0; //[TO_BE_FILLED] <= TO_BE_FILLED;
                FU_write_to[reservation_reg[0]] <= 0;//[TO_BE_FILLED] <= TO_BE_FILLED;
            end

            if (use_FU == 0 | reg_ID_flush_next) begin
                for (i = 0; i < 31; i=i+1)begin
                    reservation_reg[i] <= reservation_reg[i+1];
                end
                reservation_reg[31] <= 0;
                //TO_BE_FILLED <= 0; //这里需要编写多行代码，完成reservation_reg的移位操作，第2位移到第1位，第3位移到第2位，以此类推。最后一位清零。推荐尝试for循环（当然手写三十多行赋值也可以）。
                B_in_FU <= 0;
                J_in_FU <= 0;
            end
            else if (FU_hazard | reg_ID_flush) begin
                for (i = 0; i < 31; i=i+1)begin
                    reservation_reg[i] <= reservation_reg[i+1];
                end
                reservation_reg[31] <= 0;
                //TO_BE_FILLED <= 0; //这里需要编写多行代码，完成reservation_reg的移位操作，第2位移到第1位，第3位移到第2位，以此类推。最后一位清零。推荐尝试for循环（当然手写三十多行赋值也可以）。
                B_in_FU <= 0;
                J_in_FU <= 0;
                end
            else if(valid_ID) begin  // regist FU operation
                reservation_reg[FU_delay_cycles[use_FU]] = use_FU;//must be blocked if you want to get scores(doge 
                for (i = 0; i < 31; i=i+1)begin
                    reservation_reg[i] <= reservation_reg[i+1];
                end
                reservation_reg[31] <= 0;
                //TO_BE_FILLED <= 0; //这里需要编写多行代码，完成reservation_reg的移位操作，第2位移到第1位，第3位移到第2位，以此类推。最后一位清零。推荐尝试for循环（当然手写三十多行赋值也可以）。
                FU_status[use_FU] <= 1;//[TO_BE_FILLED] <= TO_BE_FILLED;
                if(rd_used)begin
                    FU_write_to[use_FU] <= rd;//[TO_BE_FILLED] <= TO_BE_FILLED;
                    FU_writeback_en[use_FU] <= 1'b1;//[TO_BE_FILLED] <= TO_BE_FILLED;
                end
                B_in_FU <= B_valid;
                J_in_FU <= JAL | JALR;
            end
        end
    end

    assign reg_IF_en = ~FU_hazard | branch_ctrl;

    assign reg_ID_en = reg_IF_en;

    assign branch_ctrl = (B_in_FU & cmp_res_FU) |  J_in_FU;

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            reg_ID_flush_next <= 0;
        end
        else begin
            reg_ID_flush_next <= branch_ctrl;
        end
    end
    assign reg_ID_flush = branch_ctrl;

    localparam Imm_type_I = 3'b001;
    localparam Imm_type_B = 3'b010;
    localparam Imm_type_J = 3'b011;
    localparam Imm_type_S = 3'b100;
    localparam Imm_type_U = 3'b101;
    assign ImmSel = {3{JALR | L_valid | I_valid}} & Imm_type_I |
                    {3{B_valid}}                  & Imm_type_B |
                    {3{JAL}}                      & Imm_type_J |
                    {3{S_valid}}                  & Imm_type_S |
                    {3{LUI | AUIPC}}              & Imm_type_U ;
    
    assign ALU_en = reg_IF_en & use_ALU & valid_ID & ~reg_ID_flush;
    assign MEM_en = reg_IF_en & use_MEM & valid_ID & ~reg_ID_flush;
    assign MUL_en = reg_IF_en & use_MUL & valid_ID & ~reg_ID_flush;
    assign DIV_en = reg_IF_en & use_DIV & valid_ID & ~reg_ID_flush;
    assign JUMP_en = reg_IF_en & use_JUMP & valid_ID & ~reg_ID_flush;

    localparam JUMP_BEQ  = 4'b0_001;
    localparam JUMP_BNE  = 4'b0_010;
    localparam JUMP_BLT  = 4'b0_011;
    localparam JUMP_BGE  = 4'b0_100;
    localparam JUMP_BLTU = 4'b0_101;
    localparam JUMP_BGEU = 4'b0_110;
    localparam JUMP_JAL  = 4'b0_000;
    localparam JUMP_JALR = 4'b1_000;
    assign JUMP_op ={4{BEQ}}  & JUMP_BEQ  |
                    {4{BNE}}  & JUMP_BNE  |
                    {4{BLT}}  & JUMP_BLT  |
                    {4{BGE}}  & JUMP_BGE  |
                    {4{BLTU}} & JUMP_BLTU |
                    {4{BGEU}} & JUMP_BGEU |
                    {4{JAL}}  & JUMP_JAL  |
                    {4{JALR}} & JUMP_JALR ;
    
    localparam ALU_ADD  = 4'b0001;
    localparam ALU_SUB  = 4'b0010;
    localparam ALU_AND  = 4'b0011;
    localparam ALU_OR   = 4'b0100;
    localparam ALU_XOR  = 4'b0101;
    localparam ALU_SLL  = 4'b0110;
    localparam ALU_SRL  = 4'b0111;
    localparam ALU_SLT  = 4'b1000;
    localparam ALU_SLTU = 4'b1001;
    localparam ALU_SRA  = 4'b1010;
    localparam ALU_Ap4  = 4'b1011;
    localparam ALU_Bout = 4'b1100;
    assign ALU_op = {4{ADD | ADDI | AUIPC}} & ALU_ADD  |
                    {4{SUB}}                & ALU_SUB  |
                    {4{AND | ANDI}}         & ALU_AND  |
                    {4{OR | ORI}}           & ALU_OR   |
                    {4{XOR | XORI}}         & ALU_XOR  |
                    {4{SLL | SLLI}}         & ALU_SLL  |
                    {4{SRL | SRLI}}         & ALU_SRL  |
                    {4{SLT | SLTI}}         & ALU_SLT  |
                    {4{SLTU | SLTIU}}       & ALU_SLTU |
                    {4{SRA | SRAI}}         & ALU_SRA  |
                    {4{LUI}}                & ALU_Bout ;

    assign ALUSrcA = AUIPC;

    assign ALUSrcB = I_valid | LUI | AUIPC;

    assign MEM_we = S_valid;
endmodule