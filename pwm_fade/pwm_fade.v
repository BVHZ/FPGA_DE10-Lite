module pwm_fade (
    input  wire       clk,
    output reg        LED
);

    localparam PWM_PERIOD  = 50_000;
    localparam FADE_STEP   = 500;           // tăng/giảm mỗi bước
    localparam FADE_SLOW   = 50_000;        // tốc độ fade (1 step mỗi 1ms)

    reg [15:0] pwm_counter;                 // counter PWM
    reg [15:0] fade_counter;                // counter tốc độ fade
    reg [15:0] duty;                        // duty cycle hiện tại
    reg        direction;                   // 0=tăng, 1=giảm

    // PWM counter
    always @(posedge clk) begin
        if (pwm_counter == PWM_PERIOD - 1) begin
            pwm_counter <= 0;
        end else begin
            pwm_counter <= pwm_counter + 1;
        end
    end

    // Fade counter — cập nhật duty mỗi FADE_SLOW chu kỳ
    always @(posedge clk) begin
        if (fade_counter == FADE_SLOW - 1) begin
            fade_counter <= 0;

            if (direction == 1'b0) begin    // đang tăng
                if (duty >= PWM_PERIOD - FADE_STEP) begin
                    duty      <= PWM_PERIOD;
                    direction <= 1'b1;      // đổi chiều giảm
                end else begin
                    duty <= duty + FADE_STEP;
                end
            end else begin                  // đang giảm
                if (duty <= FADE_STEP) begin
                    duty      <= 0;
                    direction <= 1'b0;      // đổi chiều tăng
                end else begin
                    duty <= duty - FADE_STEP;
                end
            end

        end else begin
            fade_counter <= fade_counter + 1;
        end
    end

    // PWM output
    always @(posedge clk) begin
        if (pwm_counter < duty) begin
            LED <= 1'b1;
        end else begin
            LED <= 1'b0;
        end
    end

endmodule
