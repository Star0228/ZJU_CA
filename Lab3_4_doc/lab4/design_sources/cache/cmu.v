module cmu (
        // CPU side
		input clk,
		input rst,
		input [31:0] addr_rw,
		input en_r,
		input en_w,
        input [2:0] u_b_h_w,
		input [31:0] data_w,
		output [31:0] data_r,
		output stall,

        // mem side
		output reg mem_cs_o = 0,
		output reg mem_we_o = 0,
		output reg [31:0] mem_addr_o = 0,
		input [31:0] mem_data_i,
		output [31:0] mem_data_o,
		input mem_ack_i,

        // debug info
        output [2:0] cmu_state
	);

    `include "addr_define.vh"
    reg TO_BE_FILLED = 0;
    reg [ADDR_BITS-1:0] cache_addr = 0;
    reg cache_load = 0;
    reg cache_replace = 0;
    reg cache_store = 0;
    reg [2:0] cache_u_b_h_w = 0;
    reg [WORD_BITS-1:0] cache_din = 0;
    wire cache_hit;
    wire [WORD_BITS-1:0] cache_dout;
    wire cache_valid;
    wire cache_dirty;
    wire [TAG_BITS-1:0] cache_tag;

    cache CACHE (
        .clk(clk),
        .rst(rst),
        .addr(cache_addr),
        .load(cache_load),
        .replace(cache_replace),
        .store(cache_store),
        .invalid(1'b0),
        .u_b_h_w(cache_u_b_h_w),
        .din(cache_din),
        .hit(cache_hit),
        .dout(cache_dout),
        .valid(cache_valid),
        .dirty(cache_dirty),
        .tag(cache_tag)
    );

    localparam
        S_IDLE = 0,
        // S_PRE_BACK = 1, //This state is redundant.
        S_BACK = 2,
        S_FILL = 3,
        S_WAIT = 4;

    reg [2:0]state = 0;
    reg [2:0]next_state = 0;
    reg [ELEMENT_WORDS_WIDTH-1:0]word_count = 0;
    reg [ELEMENT_WORDS_WIDTH-1:0]next_word_count = 0;
    assign cmu_state = state;
    reg sstall;
    always @ (posedge clk) begin
        if (rst) begin
            state <= S_IDLE;
            word_count <= 2'b00;
        end
        else begin
            state <= next_state;
            word_count <= next_word_count;
        end
    end


    // state ctrl
    always @ (*) begin

            case (state)
                S_IDLE: begin
                    if (en_r || en_w) begin
                        if (cache_hit)
                            next_state = S_IDLE;//TO_BE_FILLED;
                        else if (cache_valid && cache_dirty)
                            next_state = S_BACK;//TO_BE_FILLED;
                        else
                            next_state = S_FILL;//TO_BE_FILLED;
                    end
                    else begin
                        next_state = S_IDLE;//TO_BE_FILLED;
                    end
                    next_word_count = 2'b00;
                end

                S_BACK: begin
                    if (mem_ack_i && word_count == {ELEMENT_WORDS_WIDTH{1'b1}})    // 2'b11 in default case
                        next_state = S_FILL;//TO_BE_FILLED;
                    else
                        next_state = S_BACK;//TO_BE_FILLED;

                    if (mem_ack_i)
                        next_word_count = word_count+1;
                    else
                        next_word_count = word_count;
                end

                S_FILL: begin
                    if (mem_ack_i && word_count == {ELEMENT_WORDS_WIDTH{1'b1}})
                        next_state = S_WAIT;//TO_BE_FILLED;
                    else
                        next_state = S_FILL;//TO_BE_FILLED;

                    if (mem_ack_i)
                        next_word_count = word_count+1;
                    else
                        next_word_count = word_count;
                end

                S_WAIT: begin
                    next_state = S_IDLE;//TO_BE_FILLED;
                    next_word_count = 2'b00;
                end

                default: begin
                    next_state = 3'hx;
                    next_word_count = 2'bxx;
                end
            endcase

    end
    
    // cache ctrl
    always @ (*) begin
        case(state)
            S_IDLE, S_WAIT: begin
                cache_addr = addr_rw;
                cache_load = en_r;
                cache_store = en_w;
                cache_replace = 1'b0;
                cache_u_b_h_w = u_b_h_w;
                cache_din = data_w;
            end
            S_BACK: begin
               cache_addr = {addr_rw[ADDR_BITS-1:BLOCK_WIDTH], word_count, {ELEMENT_WORDS_WIDTH{1'b0}}};//TO_BE_FILLED;
                cache_load = 1'b0;
                cache_store = 1'b0;
                cache_replace = 1'b0;
                cache_u_b_h_w = 3'b010;
                cache_din = 32'b0;
            end
            S_FILL: begin
                cache_addr = {addr_rw[ADDR_BITS-1:BLOCK_WIDTH], word_count, {ELEMENT_WORDS_WIDTH{1'b0}}};//TO_BE_FILLED;
                cache_load = 1'b0;
                cache_store = 1'b0;
                cache_replace = mem_ack_i;
                cache_u_b_h_w = 3'b010;
                cache_din = mem_data_i;
            end

            default: begin
                cache_addr = 32'hxxxxxxxx;
                cache_load = 1'hx;
                cache_store = 1'hx;
                cache_replace = 1'bx;
                cache_u_b_h_w = 3'hx;
                cache_din = 32'hxxxxxxxx;
            end
        endcase
    end
    assign data_r = cache_dout;

    // mem ctrl
    always @ (*) begin
        case (state)
            S_IDLE, S_WAIT: begin
                mem_cs_o = 1'b0;
                mem_we_o = 1'b0;
                mem_addr_o = 32'b0;
            end

            S_BACK: begin
                mem_addr_o = {cache_tag, addr_rw[ADDR_BITS-TAG_BITS-1:BLOCK_WIDTH], word_count, {ELEMENT_WORDS_WIDTH{1'b0}}};
                mem_cs_o = 1'b1;
                mem_we_o = 1'b1;
            end

            S_FILL: begin
                mem_addr_o = {addr_rw[ADDR_BITS-1:BLOCK_WIDTH], word_count, {ELEMENT_WORDS_WIDTH{1'b0}}};
                mem_cs_o = 1'b1;
                mem_we_o = 1'b0;
            end

            default: begin
                mem_addr_o = 32'hxxxxxxxx;
                mem_cs_o = 1'bx;
                mem_we_o = 1'bx;
            end
        endcase
    end


    assign mem_data_o = cache_dout;
    assign stall = (next_state!=S_IDLE);//TO_BE_FILLED;

endmodule
