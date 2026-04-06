module top_module(
	input [3:0] in,
	output out_and,
	output out_or,
	output out_xor
);

	assign out_and = &in;   // AND tất cả bit
	assign out_or  = |in;   // OR tất cả bit
	assign out_xor = ^in;   // XOR tất cả bit

endmodule
