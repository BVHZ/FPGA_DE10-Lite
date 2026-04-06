//module btn_1(
//	input wire KEY0,
//	output wire [9:0] LED
//);
//
//	assign LED[0] = ~KEY0;
//	assign LED[9:1] = 9'b0;
//endmodule

module btn_1(
	input wire clk,
	input wire KEY0,
	output reg [9:0] LED
);
	reg key_prev;
	
	always @(posedge clk) begin
		key_prev <= KEY0;
		
		if (key_prev == 0 && KEY0 == 1)
			LED <= ~LED;
		end
endmodule



