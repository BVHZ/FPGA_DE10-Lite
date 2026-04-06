module blink_led (
	input wire clk,
	output wire [9:0] LED
);

	reg [25:0] cnt;
	
	always @(posedge clk) begin
		cnt <= cnt + 1;
	end
	
	assign LED = {10{cnt[25]}};
	
endmodule

