// | ----------- address 32 ----------- |
// | 31   9 | 8     4 | 3    2 | 1    0 |
// | tag 23 | index 5 | word 2 | byte 2 |

module cache (
	input wire clk,  // clock
	input wire rst,  // reset
	input wire [ADDR_BITS-1:0] addr,  // address
    input wire load,    //  read refreshes recent bit
	input wire replace,  // set valid to 1 and reset dirty to 0
	input wire store,  // set dirty to 1
	input wire invalid,  // reset valid to 0
    input wire [2:0] u_b_h_w, // select signed or not & data width
                              // please refer to definition of LB, LH, LW, LBU, LHU in RV32I Instruction Set  
	input wire [31:0] din,  // data write in
	output reg hit = 0,  // hit or not
	output reg [31:0] dout = 0,  // data read out
	output reg valid = 0,  // valid bit
	output reg dirty = 0,  // dirty bit
	output reg [TAG_BITS-1:0] tag = 0// tag bits
	);

    `include "addr_define.vh"
    reg TO_BE_FILLED = 0;
    wire [31:0] word1, word2;
    wire [15:0] half_word1, half_word2;
    wire [7:0]  byte1, byte2;
    wire recent1, recent2, valid1, valid2, dirty1, dirty2;
    wire [TAG_BITS-1:0] tag1, tag2;
    wire hit1, hit2;
    reg [ELEMENT_NUM-1:0] inner_recent = 0;
    reg [ELEMENT_NUM-1:0] inner_valid = 0;
    reg [ELEMENT_NUM-1:0] inner_dirty = 0;
    reg [TAG_BITS-1:0] inner_tag [0:ELEMENT_NUM-1];
    // 64 elements, 2 ways set associative => 32 sets
    reg [31:0] inner_data [0:ELEMENT_NUM*ELEMENT_WORDS-1];

    // initialize tag and data with 0
    integer i;
    initial begin
        for (i = 0; i < ELEMENT_NUM; i = i + 1)
            inner_tag[i] = 23'b0;

        for (i = 0; i < ELEMENT_NUM*ELEMENT_WORDS; i = i + 1)
            inner_data[i] = 32'b0;
    end

    // the bits in an input address:
    wire [TAG_BITS-1:0] addr_tag;
    wire [SET_INDEX_WIDTH-1:0] addr_index;     // idx of set
    wire [ELEMENT_WORDS_WIDTH+WORD_BYTES_WIDTH-WORD_BYTES_WIDTH-1:0] addr_word;
    wire [ELEMENT_INDEX_WIDTH-1:0] addr_element1; 
    wire [ELEMENT_INDEX_WIDTH-1:0] addr_element2;     // idx of element
    wire [ELEMENT_INDEX_WIDTH+ELEMENT_WORDS_WIDTH-1:0] addr_word1;
    wire [ELEMENT_INDEX_WIDTH+ELEMENT_WORDS_WIDTH-1:0] addr_word2; // element index + word index

    assign addr_tag = addr[ADDR_BITS-1:ADDR_BITS-TAG_BITS];
    assign addr_index = TO_BE_FILLED;
    assign addr_word = TO_BE_FILLED;

    assign addr_element1 = {addr_index, 1'b0};
    assign addr_element2 = {addr_index, 1'b1};      
    assign addr_word1 = {addr_element1, addr_word};
    assign addr_word2 = {addr_element2, addr_word};           

    assign word1 = inner_data[addr_word1];
    assign word2 = inner_data[addr_word2];    
    assign half_word1 = addr[1] ? word1[31:16] : word1[15:0];
    assign half_word2 = addr[1] ? word2[31:16] : word2[15:0];           
    assign byte1 = addr[1] ?
                    addr[0] ? word1[31:24] : word1[23:16] :
                    addr[0] ? word1[15:8] :  word1[7:0]   ;
    assign byte2 =  addr[1] ?
                    addr[0] ? word2[31:24] : word2[23:16] :
                    addr[0] ? word2[15:8] :  word2[7:0]   ;    

    assign recent1 = inner_recent[addr_element1];
    assign recent2 = inner_recent[addr_element2];  
    assign valid1 = inner_valid[addr_element1];
    assign valid2 = inner_valid[addr_element2];   
    assign dirty1 = inner_dirty[addr_element1];
    assign dirty2 = inner_dirty[addr_element2] ;   
    assign tag1 = inner_tag[addr_element1];
    assign tag2 = inner_tag[addr_element2];     
    assign hit1 = valid1 & (tag1 == addr_tag);
    assign hit2 = valid2 & (tag2 == addr_tag) ;     

    always @ (*) begin
        valid <= TO_BE_FILLED; // if both not hit, set to the recent value
        dirty <= TO_BE_FILLED; // if both not hit, set to the recent value
        tag <= TO_BE_FILLED; // if both not hit, set to the recent value
        hit <= hit1 | hit2;
        if (load & hit1) begin
            dout <= u_b_h_w[1] ? word1 :
            u_b_h_w[0] ? {u_b_h_w[2] ? 16'b0 : {16{half_word1[15]}}, half_word1} :
            {u_b_h_w[2] ? 24'b0 : {24{byte1[7]}}, byte1};
        end
        else if (load & hit2) begin
            dout <= u_b_h_w[1] ? word2 :
            u_b_h_w[0] ? {u_b_h_w[2] ? 16'b0 : {16{half_word2[15]}}, half_word2} :
            {u_b_h_w[2] ? 24'b0 : {24{byte1[7]}}, byte2};
        end
        else begin
            dout <= recent1 ? word2 : word1;
        end
    end

    always @ (posedge clk) begin
        if (load) begin
            if (hit1) begin
                inner_recent[TO_BE_FILLED] <= TO_BE_FILLED;
                inner_recent[TO_BE_FILLED] <= TO_BE_FILLED;
            end
            else if (hit2) begin
                inner_recent[TO_BE_FILLED] <= TO_BE_FILLED;
                inner_recent[TO_BE_FILLED] <= TO_BE_FILLED;  
            end
        end

        if (store) begin
            if (hit1) begin
                inner_data[addr_word1] <= u_b_h_w[1] ? din
                    : u_b_h_w[0] ? addr[1] ? {din[15:0], word1[15:0]} : {word1[31:16], din[15:0]} 
                        :addr[1] ? addr[0] ? {din[7:0], word1[23:0]} : {word1[31:24], din[7:0], word1[15:0]}
                            :addr[0] ? {word1[31:16], din[7:0], word1[7:0]} : {word1[31:8], din[7:0]};
                inner_dirty[TO_BE_FILLED] <= TO_BE_FILLED;
                inner_recent[TO_BE_FILLED] <= TO_BE_FILLED;
                inner_recent[TO_BE_FILLED] <= TO_BE_FILLED;
            end
            else if (hit2) begin
                inner_data[addr_word2] <= u_b_h_w[1] ? din
                    :u_b_h_w[0] ? addr[1] ? {din[15:0], word2[15:0]} : {word2[31:16], din[15:0]} 
                        :addr[1] ? addr[0] ? {din[7:0], word2[23:0]} : {word2[31:24], din[7:0], word2[15:0]}
                            :addr[0] ? {word2[31:16], din[7:0], word2[7:0]} : {word2[31:8], din[7:0]};
                inner_dirty[TO_BE_FILLED] <= TO_BE_FILLED;
                inner_recent[TO_BE_FILLED] <= TO_BE_FILLED;
                inner_recent[TO_BE_FILLED] <= TO_BE_FILLED;
            end
        end

        if (replace) begin
            if (hit2 | ((~hit1) & recent1)) begin
                inner_data[addr_word2] <= din;
                inner_valid[TO_BE_FILLED] <= TO_BE_FILLED;
                inner_dirty[TO_BE_FILLED] <= TO_BE_FILLED;
                inner_tag[TO_BE_FILLED] <= addr_tag;
                inner_recent[TO_BE_FILLED] <= TO_BE_FILLED;
                inner_recent[TO_BE_FILLED] <= TO_BE_FILLED;         
            end else begin
                inner_data[addr_word1] <= din;
                inner_valid[TO_BE_FILLED] <= TO_BE_FILLED;
                inner_dirty[TO_BE_FILLED] <= TO_BE_FILLED;
                inner_tag[TO_BE_FILLED] <= addr_tag;
                inner_recent[TO_BE_FILLED] <= TO_BE_FILLED;
                inner_recent[TO_BE_FILLED] <= TO_BE_FILLED; 
            end
        end

        // not used currently, can be used to reset the cache.
        if (invalid) begin
            inner_recent[addr_element1] <= 1'b0;
            inner_recent[addr_element2] <= 1'b0;
            inner_valid[addr_element1] <= 1'b0;
            inner_valid[addr_element2] <= 1'b0;
            inner_dirty[addr_element1] <= 1'b0;
            inner_dirty[addr_element2] <= 1'b0;
        end
    end

endmodule
