
`timescale 1ns / 1ps

module cache_sim;

	// Inputs
	reg clk;
	reg rst;
	reg [31:0] addr;
	reg load;
	reg replace;
	reg store;
	reg invalid;
	reg [2:0] u_b_h_w;
	reg [31:0] din;

	// Outputs
	wire hit;
	wire [31:0] dout;
	wire valid;
	wire dirty;
	wire [22:0] tag;

	// Instantiate the Unit Under Test (UUT)
	cache uut (
		.clk(clk), 
		.rst(rst), 
		.addr(addr), 
		.load(load),
		.replace(replace), 
		.store(store), 
		.invalid(invalid), 
		.u_b_h_w(u_b_h_w),
		.din(din), 
		.hit(hit), 
		.dout(dout), 
		.valid(valid), 
		.dirty(dirty), 
		.tag(tag)
	);

	initial begin
		clk = 1;
		forever #0.5 clk = ~clk;
	end

	reg [31:0]counter = -1;

	always @(posedge clk) begin
		counter = counter + 32'b1;

		case (counter)
			// Initialize Inputs
			32'd0: begin
				rst <= 1;
				addr <= 0;
				load <= 0;
				replace <= 0;
				store <= 0;
				invalid <= 0;
				u_b_h_w <= 0;
				din <= 0;
			end
			
			32'd1: begin
				rst <= 0;
				load <= 0;
				store <= 0;
				replace <= 1;
				invalid <= 0;
				addr <= 32'h4;//100
				din <= 32'h12345678;
				u_b_h_w <= 2;
			end

			32'd2: begin
				load <= 0;
				store <= 0;
				replace <= 1;
				invalid <= 0;
				addr <= 32'hc;//1100
				din <= 32'h23456789;
				u_b_h_w <= 2;
			end

			32'd3: begin
				load <= 0;
				store <= 0;
				replace <= 1;
				invalid <= 0;
				addr <= 32'h10;//10000
				din <= 32'h34568890;
				u_b_h_w <= 2;
			end

			32'd4: begin
				load <= 0;
				store <= 0;
				replace <= 1;
				invalid <= 0;
				addr <= 32'h14;//10100
				din <= 32'h45678901;
				u_b_h_w <= 2;
			end

			32'd5: begin
				load <= 1;
				store <= 0;
				replace <= 0;
				invalid <= 0;
				addr <= 32'h20;//100000
				din <= 32'h0;
				u_b_h_w <= 2;
			end

			32'd6: begin
				load <= 1;
				store <= 0;
				replace <= 0;
				invalid <= 0;
				addr <= 32'h10;//10000
				din <= 32'h0;
				u_b_h_w <= 1;
			end

			32'd7: begin
				load <= 0;
				store <= 1;
				replace <= 0;
				invalid <= 0;
				addr <= 32'h24;//100100
				din <= 32'h56789012;
				u_b_h_w <= 1;
			end

			32'd8: begin
				load <= 0;
				store <= 1;
				replace <= 0;
				invalid <= 0;
				addr <= 32'h11;//10001
				din <= 32'h67890123;
				u_b_h_w <= 0;
			end

			32'd9: begin
				load <= 0;
				store <= 0;
				replace <= 1;
				invalid <= 0;
				addr <= 32'h200;//100000000
				din <= 32'h78901234;
				u_b_h_w <= 2;
			end

			32'd10: begin
				load <= 0;
				store <= 1;
				replace <= 0;
				invalid <= 0;
				addr <= 32'h204;//100000100
				din <= 32'h89012345;
				u_b_h_w <= 0;
			end

			32'd11: begin
				load <= 0;
				store <= 0;
				replace <= 0;
				invalid <= 0;
				addr <= 32'h400;//1000000000
				din <= 32'h0;
				u_b_h_w <= 2;
			end

			32'd12: begin
				load <= 1;
				store <= 0;
				replace <= 0;
				invalid <= 0;
				addr <= 32'hd;//1101
				din <= 32'h0;
				u_b_h_w <= 4;
			end

			32'd13: begin
				load <= 0;
				store <= 0;
				replace <= 1;
				invalid <= 0;
				addr <= 32'h60;//110000
				din <= 32'ha98ac7;
				u_b_h_w <= 2;
			end

			32'd14: begin
				load <= 0;
				store <= 0;
				replace <= 1;
				invalid <= 0;
				addr <= 32'h160;//10110000
				din <= 32'h153158e;
				u_b_h_w <= 2;
			end

			32'd15: begin
				load <= 0;
				store <= 0;
				replace <= 1;
				invalid <= 0;
				addr <= 32'h260;//100110000
				din <= 32'h1fca055;
				u_b_h_w <= 2;
			end

			32'd16: begin
				load <= 0;
				store <= 0;
				replace <= 1;
				invalid <= 0;
				addr <= 32'h360;//110110000
				din <= 32'h2a62b1c;
				u_b_h_w <= 2;
			end

			32'd17: begin
				load <= 1;
				store <= 0;
				replace <= 0;
				invalid <= 0;
				addr <= 32'h560;//1010110000
				din <= 32'h0;
				u_b_h_w <= 2;
			end

			32'd18: begin
				load <= 1;
				store <= 0;
				replace <= 0;
				invalid <= 0;
				addr <= 32'h60;//1100000
				din <= 32'h0;
				u_b_h_w <= 2;
			end

			32'd19: begin
				load <= 1;
				store <= 0;
				replace <= 0;
				invalid <= 0;
				addr <= 32'h560;//1010110000
				din <= 32'h0;
				u_b_h_w <= 2;
			end

			32'd20: begin
				load <= 0;
				store <= 0;
				replace <= 1;
				invalid <= 0;
				//00010000000000000000000011110000
				addr <= 32'h100000f0;
				din <= 32'h11111111;
				u_b_h_w <= 1;
			end

			32'd21: begin
				load <= 0;
				store <= 0;
				replace <= 1;
				invalid <= 0;
				//00100000000000000000000011110000
				addr <= 32'h200000f0;
				din <= 32'h22222222;
				u_b_h_w <= 1;
			end

			32'd22: begin
				load <= 0;
				store <= 0;
				replace <= 1;
				invalid <= 0;
				//00110000000000000000000011110000
				addr <= 32'h300000f0;
				din <= 32'h33333333;
				u_b_h_w <= 1;
			end

			default: begin
				$finish;
			end
		endcase
	end

endmodule

