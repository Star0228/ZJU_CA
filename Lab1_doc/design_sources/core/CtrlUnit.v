`timescale 1ns / 1ps


module CtrlUnit(
    input[31:0] inst,
    input cmp_res,
    output Branch, ALUSrc_A, ALUSrc_B, DatatoReg, RegWrite, mem_w,
        MIO, rs1use, rs2use,
    output [1:0] hazard_optype,
    output [2:0] ImmSel, cmp_ctrl,
    output [3:0] ALUControl,
    output JALR
);
    reg TO_BE_FILLED = 0; //所有这个寄存器占的位置都需要填入正确的值
                          //可能是wire或reg的名称，可能是一个算式，也可能是某个常数
    
    wire[6:0] funct7   = inst[31:25];
    wire[2:0] funct3   = inst[14:12];
    wire[6:0] opcode   = TO_BE_FILLED;

    wire Rop = opcode == 7'b0110011;
    wire Iop = opcode == 7'b0010011;
    wire Bop = opcode == 7'b1100011;
    wire Lop = opcode == 7'b0000011;
    wire Sop = opcode == TO_BE_FILLED;

    wire funct7_0  = funct7 == 7'h0;
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
    wire OR   = Rop & TO_BE_FILLED;//该信号表示当前指令是否是一条or指令

    wire ADDI  = TO_BE_FILLED & funct3_0;	
    wire SLTI  = TO_BE_FILLED & funct3_2;
    wire SLTIU = TO_BE_FILLED & funct3_3;
    wire XORI  = TO_BE_FILLED & funct3_4;
    wire ANDI  = TO_BE_FILLED & funct3_7;
    wire SLLI  = TO_BE_FILLED & funct3_1 & funct7_0;
    wire SRLI  = TO_BE_FILLED & funct3_5 & funct7_0;
    wire SRAI  = TO_BE_FILLED & funct3_5 & funct7_32;

    wire BEQ = Bop & TO_BE_FILLED;
    wire BNE = Bop & funct3_1;
    wire BGE = Bop & funct3_5;
    wire BLTU = Bop & funct3_6;
    wire BGEU = Bop & funct3_7;

    wire LB =  Lop & funct3_0;
    wire LH =  Lop & funct3_1;
    wire LW =  Lop & funct3_2;
    wire LHU = Lop & funct3_5;

    wire SB = Sop & funct3_0;
    wire SH = Sop & funct3_1;
    wire SW = Sop & funct3_2;

    wire LUI   = opcode == TO_BE_FILLED;
    wire AUIPC = opcode == TO_BE_FILLED;
    
    wire AND  = TO_BE_FILLED;
    wire ORI  = TO_BE_FILLED;
    wire BLT = TO_BE_FILLED;
    wire LBU = TO_BE_FILLED;


    wire JAL  = opcode == 7'b1101111;
    assign JALR = TO_BE_FILLED;


    wire R_valid = AND | OR | ADD | XOR | SLL | SRL | SRA | SUB | SLT | SLTU;
    wire I_valid = ANDI | ORI | ADDI | XORI | SLLI | SRLI | SRAI | SLTI | SLTIU;
    wire B_valid = TO_BE_FILLED;
    wire L_valid = LW | LH | LB | LHU | LBU;
    wire S_valid = SW | SH | SB;


    assign Branch = TO_BE_FILLED;//是否转跳的信号，是个表达式

    parameter Imm_type_I = 3'b001;
    parameter Imm_type_B = 3'b010;
    parameter Imm_type_J = 3'b011;
    parameter Imm_type_S = 3'b100;
    parameter Imm_type_U = 3'b101;
    assign ImmSel = {3{I_valid | JALR | L_valid}} & Imm_type_I |
                    {3{B_valid}}                  & Imm_type_B |
                    {3{JAL}}                      & Imm_type_J |
                    {3{S_valid}}                  & Imm_type_S |
                    {3{LUI | AUIPC}}              & Imm_type_U ;
    parameter cmp_EQ  = 3'b001;
    parameter cmp_NE  = 3'b010;
    parameter cmp_LT  = 3'b011;
    parameter cmp_LTU = 3'b100;
    parameter cmp_GE  = 3'b101;
    parameter cmp_GEU = 3'b110;

    assign cmp_ctrl =  TO_BE_FILLED;//这个空比较长，用以控制CPU对两个操作数采取什么比较操作，比如大于比较，小于比较等，可以参照ImmSel和ALUControl的写法来赋值

    assign ALUSrc_A = TO_BE_FILLED;//控制第一个操作数来源于PC还是寄存器，该信号取决于指令的种类

    assign ALUSrc_B = TO_BE_FILLED;//控制第二个操作数来源于立即数还是寄存器等，该信号取决于指令的种类

    parameter ALU_ADD  = 4'b0001;
    parameter ALU_SUB  = 4'b0010;
    parameter ALU_AND  = 4'b0011;
    parameter ALU_OR   = 4'b0100;
    parameter ALU_XOR  = 4'b0101;
    parameter ALU_SLL  = 4'b0110;
    parameter ALU_SRL  = 4'b0111;
    parameter ALU_SLT  = 4'b1000;
    parameter ALU_SLTU = 4'b1001;
    parameter ALU_SRA  = 4'b1010;
    parameter ALU_Ap4  = 4'b1011;
    parameter ALU_Bout = 4'b1100;
    assign ALUControl = {4{ADD | ADDI | L_valid | S_valid | AUIPC}} & ALU_ADD  |
                        {4{SUB}}                                    & ALU_SUB  |
                        {4{AND | ANDI}}                             & ALU_AND  |
                        {4{OR | ORI}}                               & ALU_OR   |
                        {4{XOR | XORI}}                             & ALU_XOR  |
                        {4{SLL | SLLI}}                             & ALU_SLL  |
                        {4{SRL | SRLI}}                             & ALU_SRL  |
                        {4{SLT | SLTI}}                             & ALU_SLT  |
                        {4{SLTU | SLTIU}}                           & ALU_SLTU |
                        {4{SRA | SRAI}}                             & ALU_SRA  |
                        {4{JAL | JALR}}                             & ALU_Ap4  |
                        {4{LUI}}                                    & ALU_Bout ;

    assign DatatoReg = L_valid;

    assign RegWrite = R_valid | I_valid | JAL | JALR | L_valid | LUI | AUIPC;

    assign mem_w = S_valid;

    assign MIO = L_valid | S_valid;

    assign rs1use = R_valid | I_valid | B_valid | L_valid | S_valid | JALR;

    assign rs2use = TO_BE_FILLED;//是否用到了rs2
    
    parameter HAZARD_NO  = 2'b00 ;
    parameter HAZARD_EX  = 2'b01 ;
    parameter HAZARD_MEM = 2'b10 ;
    parameter HAZARD_ST  = 2'b11 ;

    assign hazard_optype = {2{R_valid | I_valid | JAL | JALR | LUI | AUIPC}}& HAZARD_EX  | 
                           {2{L_valid}}                                     & HAZARD_MEM |
                           {2{S_valid}}                                     & HAZARD_ST  ;


endmodule