module pwm_sw(
	input wire clk,
	input wire [1:0] SW,
	output reg LED
);
	localparam PWM_PERIOD = 50_000;
	
	reg [15:0] counter;
	reg [15:0] duty;
	
	always @(*) begin
		case (SW)
			2'b00: begin
				duty = 16'd0; // 0%
			end
			2'b01: begin
				duty = 16'd12_500; // 25%
			end
			2'b10: begin
				duty = 16'd25_000; // 50%
			end
			2'b11: begin
				duty = 16'd50_000;
			end
			default: begin
				duty = 16'd0;
			end
		endcase	
	end
	
	always @(posedge clk) begin
		if (counter == PWM_PERIOD - 1) begin
			counter <= 0;
		end else begin
			counter <= counter + 1;
		end
	end
	
	always @(posedge clk) begin
		if (counter < duty) begin
			LED <= 1'b1;
		end else begin
			LED <= 1'b0;
		end
	end
endmodule
