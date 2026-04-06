module hex_display (
	output reg [6:0] HEX0,
	output reg [6:0] HEX1,
	output reg [6:0] HEX2,
	output reg [6:0] HEX3,
	output reg [6:0] HEX4,
	output reg [6:0] HEX5
);
	always @(*) begin
		HEX5 = 7'b1000000;    // 0
      HEX4 = 7'b1111001;    // 1
      HEX3 = 7'b0100100;    // 2
      HEX2 = 7'b0110000;    // 3
      HEX1 = 7'b0011001;    // 4
      HEX0 = 7'b0010010;    // 5
	end
endmodule

