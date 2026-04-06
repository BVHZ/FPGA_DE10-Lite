// ============================================================
// File    : keypad_7seg.v
// Mô tả   : Keypad 4x4 hiển thị lên 1 LED 7 thanh - DE10-Lite
// Kit     : DE10-Lite (10M50DAF484C7G), clock 50MHz
// ============================================================

module keypad (
    input        CLOCK_50,

    // Keypad
    output reg [3:0] ROW,
    input      [3:0] COL,

    // LED 7 đoạn (tích cực thấp)
    output reg [6:0] HEX0
);

// ============================================================
// 1. Tạo xung scan_clk ~1 kHz từ 50 MHz
// ============================================================
parameter CLK_DIV = 50_000;

reg [15:0] div_cnt;
reg        scan_clk;

always @(posedge CLOCK_50) begin
    if (div_cnt == CLK_DIV - 1) begin
        div_cnt  <= 0;
        scan_clk <= ~scan_clk;
    end else begin
        div_cnt <= div_cnt + 1;
    end
end

// ============================================================
// 2. Quét hàng xoay vòng
// ============================================================
reg [1:0] row_idx;

always @(posedge scan_clk)
    row_idx <= row_idx + 1;

always @(*) begin
    case (row_idx)
        2'd0: ROW = 4'b1110;
        2'd1: ROW = 4'b1101;
        2'd2: ROW = 4'b1011;
        2'd3: ROW = 4'b0111;
    endcase
end

// ============================================================
// 3. Đọc phím: row_idx trễ 1 tick để điện áp ổn định
// ============================================================
reg [1:0] row_idx_d;
always @(posedge scan_clk)
    row_idx_d <= row_idx;

reg [3:0] key_code;
reg       key_valid;

always @(posedge scan_clk) begin
    key_valid <= 1;
    case ({row_idx_d, ~COL})
        6'b00_0001: key_code <= 4'h1;
        6'b00_0010: key_code <= 4'h2;
        6'b00_0100: key_code <= 4'h3;
        6'b00_1000: key_code <= 4'hA;

        6'b01_0001: key_code <= 4'h4;
        6'b01_0010: key_code <= 4'h5;
        6'b01_0100: key_code <= 4'h6;
        6'b01_1000: key_code <= 4'hB;

        6'b10_0001: key_code <= 4'h7;
        6'b10_0010: key_code <= 4'h8;
        6'b10_0100: key_code <= 4'h9;
        6'b10_1000: key_code <= 4'hC;

        6'b11_0001: key_code <= 4'hF;  // *
        6'b11_0010: key_code <= 4'h0;  // 0
        6'b11_0100: key_code <= 4'hE;  // #
        6'b11_1000: key_code <= 4'hD;

        default: key_valid <= 0;
    endcase
end

// ============================================================
// 4. Chốt phím cuối cùng hợp lệ
// ============================================================
reg [3:0] display_code;

always @(posedge CLOCK_50) begin
    if (key_valid)
        display_code <= key_code;
end

// ============================================================
// 5. Giải mã 7 đoạn (tích cực thấp → đảo bit)
// ============================================================
reg [6:0] seg;

always @(*) begin
    case (display_code)
        4'h0: seg = 7'b0111111;
        4'h1: seg = 7'b0000110;
        4'h2: seg = 7'b1011011;
        4'h3: seg = 7'b1001111;
        4'h4: seg = 7'b1100110;
        4'h5: seg = 7'b1101101;
        4'h6: seg = 7'b1111101;
        4'h7: seg = 7'b0000111;
        4'h8: seg = 7'b1111111;
        4'h9: seg = 7'b1101111;
        4'hA: seg = 7'b1110111;
        4'hB: seg = 7'b1111100;
        4'hC: seg = 7'b0111001;
        4'hD: seg = 7'b1011110;
        4'hE: seg = 7'b1111001;
        4'hF: seg = 7'b1110001;
        default: seg = 7'b0000000;
    endcase
end

always @(*) HEX0 = ~seg;

endmodule
