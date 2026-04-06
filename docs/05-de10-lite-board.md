# Hướng dẫn DE10-Lite — Intel MAX 10 FPGA (10M50DAF484C7G)

> **Các phần khác**: [README.md](README.md) | [index.md](index.md) | [CLAUDE.md](CLAUDE.md) | [techniques.md](techniques.md)

---

## Mục lục

- [1. Tổng quan DE10-Lite](#1-tổng-quan-de10-lite)
- [2. Thông số FPGA 10M50DAF484C7G](#2-thông-số-fpga-10m50daf484c7g)
- [3. Sơ đồ ngoại vi & Pin Assignment](#3-sơ-đồ-ngoại-vi--pin-assignment)
- [4. Hướng dẫn Quartus Prime](#4-hướng-dẫn-quartus-prime)
- [5. Ví dụ 1: Blink LED](#5-ví-dụ-1-blink-led)
- [6. Ví dụ 2: Điều khiển LED bằng Switch](#6-ví-dụ-2-điều-khiển-led-bằng-switch)
- [7. Ví dụ 3: Hiển thị 7-Segment](#7-ví-dụ-3-hiển-thị-7-segment)
- [8. Ví dụ 4: Bộ đếm BCD 4 chữ số](#8-ví-dụ-4-bộ-đếm-bcd-4-chữ-số)
- [9. Ví dụ 5: LED chạy đuổi](#9-ví-dụ-5-led-chạy-đuổi)
- [10. GPIO & Xuất IO ra ngoài](#10-gpio--xuất-io-ra-ngoài)
- [11. Lỗi thường gặp & Troubleshooting](#11-lỗi-thường-gặp--troubleshooting)

---

## 1. Tổng quan DE10-Lite

### 1.1 Board DE10-Lite là gì?

**DE10-Lite** là board phát triển FPGA giá rẻ (~$80) của **Terasic**, dùng chip **Intel MAX 10 FPGA**. Phù hợp cho học tập và prototype.

### 1.2 Thành phần trên board

| Thành phần | Số lượng | Mô tả |
|------------|---------|-------|
| **FPGA** | 1 | 10M50DAF484C7G (MAX 10) |
| **LED đỏ** | 10 | LEDR[9:0] — tích cực mức cao |
| **Slide Switch** | 10 | SW[9:0] — UP = HIGH, DOWN = LOW |
| **Push Button** | 2 | KEY[1:0] — nhấn = LOW (active low) |
| **7-Segment** | 6 | HEX0~HEX5 — common anode (active LOW) |
| **Clock** | 1 | 50 MHz (MAX10_CLK1_50) |
| **SDRAM** | 64MB | IS42S16320D (16-bit bus) |
| **VGA** | 1 | 4-bit resistor-network (15 pin) |
| **Accelerometer** | 1 | ADXL345 (SPI/I2C) |
| **GPIO** | 1 | 2x20 header (36 IO + power) |
| **Arduino Header** | 1 | 16 GPIO + 6 ADC |
| **USB-Blaster** | 1 | On-board, để nạp FPGA |
| **ADC** | 2 | Tích hợp trong MAX 10 |

---

## 2. Thông số FPGA 10M50DAF484C7G

| Thông số | Giá trị |
|----------|---------|
| **Họ FPGA** | Intel MAX 10 |
| **Logic Elements (LE)** | 49,760 |
| **Embedded Memory** | 1,677 Kbits |
| **User Flash** | 3,200 Kbits |
| **18x18 Multipliers** | 144 |
| **PLLs** | 4 |
| **User I/O** | 360 |
| **Package** | 484-pin FBGA |
| **Speed Grade** | C7G (Commercial) |
| **Cấu hình** | Internal flash (không cần ROM ngoài) |
| **ADC** | 2 × 12-bit, 1 MSPS |
| **Điện áp IO** | 3.3V (LVCMOS33) |

> **Đặc biệt**: MAX 10 cấu hình từ **flash nội** → bật nguồn là chạy ngay, không cần nạp lại!

---

## 3. Sơ đồ ngoại vi & Pin Assignment

### 3.1 Clock

| Tín hiệu | FPGA Pin | Mô tả |
|-----------|----------|-------|
| `MAX10_CLK1_50` | `PIN_P11` | Clock 50 MHz chính |
| `MAX10_CLK2_50` | `PIN_N14` | Clock 50 MHz phụ |

### 3.2 LED (10 LEDs — Active HIGH)

> Gán `1` → LED sáng, gán `0` → LED tắt

| Tín hiệu | FPGA Pin | | Tín hiệu | FPGA Pin |
|-----------|----------|-|-----------|----------|
| `LEDR[0]` | `PIN_A8` | | `LEDR[5]` | `PIN_B11` |
| `LEDR[1]` | `PIN_A9` | | `LEDR[6]` | `PIN_A11` |
| `LEDR[2]` | `PIN_A10`| | `LEDR[7]` | `PIN_D14` |
| `LEDR[3]` | `PIN_B10`| | `LEDR[8]` | `PIN_E14` |
| `LEDR[4]` | `PIN_D13`| | `LEDR[9]` | `PIN_C13` |

### 3.3 Slide Switches (10 SW — UP = HIGH)

| Tín hiệu | FPGA Pin | | Tín hiệu | FPGA Pin |
|-----------|----------|-|-----------|----------|
| `SW[0]` | `PIN_C10` | | `SW[5]` | `PIN_A14` |
| `SW[1]` | `PIN_C11` | | `SW[6]` | `PIN_B14` |
| `SW[2]` | `PIN_D12` | | `SW[7]` | `PIN_A15` |
| `SW[3]` | `PIN_C12` | | `SW[8]` | `PIN_A16` |
| `SW[4]` | `PIN_A13` | | `SW[9]` | `PIN_B16` |

### 3.4 Push Buttons (2 KEYs — Nhấn = LOW)

| Tín hiệu | FPGA Pin | Mô tả |
|-----------|----------|-------|
| `KEY[0]` | `PIN_B8` | Nút nhấn 0 (active low) |
| `KEY[1]` | `PIN_A7` | Nút nhấn 1 (active low) |

### 3.5 7-Segment Displays (6 displays — Active LOW)

> **Common Anode**: gán `0` → segment sáng, gán `1` → segment tắt

Mỗi display có 7 segment: `HEXn[6:0]` = `{g, f, e, d, c, b, a}`

```
 aaaa Bit mapping:
 f b HEXn[0] = a
 f b HEXn[1] = b
 gggg HEXn[2] = c
 e c HEXn[3] = d
 e c HEXn[4] = e
 dddd HEXn[5] = f
 HEXn[6] = g
```

**HEX0:**

| Segment | Pin | | Segment | Pin |
|---------|-----|-|---------|-----|
| `HEX0[0]` (a) | `PIN_C14` | | `HEX0[4]` (e) | `PIN_E15` |
| `HEX0[1]` (b) | `PIN_E16` | | `HEX0[5]` (f) | `PIN_C15` |
| `HEX0[2]` (c) | `PIN_D17` | | `HEX0[6]` (g) | `PIN_C16` |
| `HEX0[3]` (d) | `PIN_C17` | | | |

**HEX1:**

| Segment | Pin | | Segment | Pin |
|---------|-----|-|---------|-----|
| `HEX1[0]` (a) | `PIN_C18` | | `HEX1[4]` (e) | `PIN_B20` |
| `HEX1[1]` (b) | `PIN_D18` | | `HEX1[5]` (f) | `PIN_A20` |
| `HEX1[2]` (c) | `PIN_E18` | | `HEX1[6]` (g) | `PIN_B19` |
| `HEX1[3]` (d) | `PIN_B16` | | | |

**HEX2:**

| Segment | Pin | | Segment | Pin |
|---------|-----|-|---------|-----|
| `HEX2[0]` (a) | `PIN_B22` | | `HEX2[4]` (e) | `PIN_B21` |
| `HEX2[1]` (b) | `PIN_C22` | | `HEX2[5]` (f) | `PIN_A21` |
| `HEX2[2]` (c) | `PIN_B21` | | `HEX2[6]` (g) | `PIN_A19` |
| `HEX2[3]` (d) | `PIN_D22` | | | |

**HEX3:**

| Segment | Pin | | Segment | Pin |
|---------|-----|-|---------|-----|
| `HEX3[0]` (a) | `PIN_B17` | | `HEX3[4]` (e) | `PIN_A18` |
| `HEX3[1]` (b) | `PIN_A18` | | `HEX3[5]` (f) | `PIN_A17` |
| `HEX3[2]` (c) | `PIN_A17` | | `HEX3[6]` (g) | `PIN_B17` |
| `HEX3[3]` (d) | `PIN_B17` | | | |

**HEX4 & HEX5:** Tham khảo file `.qsf` đầy đủ ở [Mục 4.5](#45-file-pin-assignment-hoàn-chỉnh-qsf).

### 3.6 GPIO Header (JP1 — 2x20 pins)

| Tín hiệu | FPGA Pin | | Tín hiệu | FPGA Pin |
|-----------|----------|-|-----------|----------|
| `GPIO[0]` | `PIN_V10` | | `GPIO[1]` | `PIN_W10` |
| `GPIO[2]` | `PIN_V9` | | `GPIO[3]` | `PIN_W9` |
| `GPIO[4]` | `PIN_V8` | | `GPIO[5]` | `PIN_W8` |
| `GPIO[6]` | `PIN_V7` | | `GPIO[7]` | `PIN_W7` |
| `GPIO[8]` | `PIN_W6` | | `GPIO[9]` | `PIN_V5` |
| `GPIO[10]`| `PIN_W5` | | `GPIO[11]`| `PIN_AA15`|
| ... | ... | | `GPIO[35]` | ... |

> ️ GPIO hoạt động ở **3.3V**. Không nối trực tiếp với thiết bị 5V!

---

## 4. Hướng dẫn Quartus Prime

### 4.1 Cài đặt

1. Tải **Quartus Prime Lite** (miễn phí) từ [intel.com/fpga](https://www.intel.com/content/www/us/en/products/details/fpga/development-tools/quartus-prime/resource.html)
2. Chọn **MAX 10 device support** khi cài đặt
3. Cài USB-Blaster driver (tự động hoặc từ `quartus/drivers/usb-blaster`)

### 4.2 Tạo Project mới

```
1. File → New Project Wizard
2. Chọn thư mục dự án, đặt tên project
3. Add Files: thêm file .v (hoặc thêm sau)
4. Family: MAX 10
 Device: 10M50DAF484C7G
5. Finish
```

### 4.3 Quy trình nạp FPGA

```
┌──────────────────────────────────┐
│ 1. Viết code Verilog (.v) │
└──────────┬───────────────────────┘
 ↓
┌──────────────────────────────────┐
│ 2. Analysis & Synthesis │
│ (Processing → Start) │
│ Kiểm tra syntax, tạo netlist │
└──────────┬───────────────────────┘
 ↓
┌──────────────────────────────────┐
│ 3. Pin Assignment │
│ (Assignments → Pin Planner) │
│ Gán chân FPGA cho IO │
└──────────┬───────────────────────┘
 ↓
┌──────────────────────────────────┐
│ 4. Full Compilation │
│ (Processing → Start │
│ Compilation) │
│ Synthesis + Fitter + Timing │
└──────────┬───────────────────────┘
 ↓
┌──────────────────────────────────┐
│ 5. Program Device │
│ (Tools → Programmer) │
│ File: output_files/*.sof │
│ Mode: JTAG → Start │
└──────────────────────────────────┘
```

### 4.4 Pin Planner — Gán chân

Mở: **Assignments → Pin Planner**

- Cột **Node Name**: tên port trong Verilog
- Cột **Location**: gán pin FPGA (ví dụ: `PIN_A8`)
- Cột **I/O Standard**: chọn `3.3-V LVTTL` hoặc `3.3 V LVCMOS`

### 4.5 File Pin Assignment hoàn chỉnh (.qsf)

Thay vì gán thủ công, thêm vào file `.qsf` của project:

```tcl
# ============================================
# DE10-Lite Pin Assignments
# ============================================

# Clock
set_location_assignment PIN_P11 -to MAX10_CLK1_50
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to MAX10_CLK1_50

# LEDs
set_location_assignment PIN_A8 -to LEDR[0]
set_location_assignment PIN_A9 -to LEDR[1]
set_location_assignment PIN_A10 -to LEDR[2]
set_location_assignment PIN_B10 -to LEDR[3]
set_location_assignment PIN_D13 -to LEDR[4]
set_location_assignment PIN_B11 -to LEDR[5]
set_location_assignment PIN_A11 -to LEDR[6]
set_location_assignment PIN_D14 -to LEDR[7]
set_location_assignment PIN_E14 -to LEDR[8]
set_location_assignment PIN_C13 -to LEDR[9]

# Switches
set_location_assignment PIN_C10 -to SW[0]
set_location_assignment PIN_C11 -to SW[1]
set_location_assignment PIN_D12 -to SW[2]
set_location_assignment PIN_C12 -to SW[3]
set_location_assignment PIN_A13 -to SW[4]
set_location_assignment PIN_A14 -to SW[5]
set_location_assignment PIN_B14 -to SW[6]
set_location_assignment PIN_A15 -to SW[7]
set_location_assignment PIN_A16 -to SW[8]
set_location_assignment PIN_B16 -to SW[9]

# Push Buttons
set_location_assignment PIN_B8 -to KEY[0]
set_location_assignment PIN_A7 -to KEY[1]

# HEX0
set_location_assignment PIN_C14 -to HEX0[0]
set_location_assignment PIN_E16 -to HEX0[1]
set_location_assignment PIN_D17 -to HEX0[2]
set_location_assignment PIN_C17 -to HEX0[3]
set_location_assignment PIN_E15 -to HEX0[4]
set_location_assignment PIN_C15 -to HEX0[5]
set_location_assignment PIN_C16 -to HEX0[6]

# HEX1
set_location_assignment PIN_C18 -to HEX1[0]
set_location_assignment PIN_D18 -to HEX1[1]
set_location_assignment PIN_E18 -to HEX1[2]
set_location_assignment PIN_B16 -to HEX1[3]
set_location_assignment PIN_B20 -to HEX1[4]
set_location_assignment PIN_A20 -to HEX1[5]
set_location_assignment PIN_B19 -to HEX1[6]

# HEX2
set_location_assignment PIN_B22 -to HEX2[0]
set_location_assignment PIN_C22 -to HEX2[1]
set_location_assignment PIN_B21 -to HEX2[2]
set_location_assignment PIN_D22 -to HEX2[3]
set_location_assignment PIN_E22 -to HEX2[4]
set_location_assignment PIN_A21 -to HEX2[5]
set_location_assignment PIN_A19 -to HEX2[6]

# HEX3
set_location_assignment PIN_F21 -to HEX3[0]
set_location_assignment PIN_E22 -to HEX3[1]
set_location_assignment PIN_E21 -to HEX3[2]
set_location_assignment PIN_C19 -to HEX3[3]
set_location_assignment PIN_C20 -to HEX3[4]
set_location_assignment PIN_D19 -to HEX3[5]
set_location_assignment PIN_E17 -to HEX3[6]

# HEX4
set_location_assignment PIN_F18 -to HEX4[0]
set_location_assignment PIN_E20 -to HEX4[1]
set_location_assignment PIN_E19 -to HEX4[2]
set_location_assignment PIN_J18 -to HEX4[3]
set_location_assignment PIN_H19 -to HEX4[4]
set_location_assignment PIN_F19 -to HEX4[5]
set_location_assignment PIN_F20 -to HEX4[6]

# HEX5
set_location_assignment PIN_J20 -to HEX5[0]
set_location_assignment PIN_K20 -to HEX5[1]
set_location_assignment PIN_L18 -to HEX5[2]
set_location_assignment PIN_N18 -to HEX5[3]
set_location_assignment PIN_M20 -to HEX5[4]
set_location_assignment PIN_N19 -to HEX5[5]
set_location_assignment PIN_N20 -to HEX5[6]

# GPIO Header JP1
set_location_assignment PIN_V10 -to GPIO[0]
set_location_assignment PIN_W10 -to GPIO[1]
set_location_assignment PIN_V9 -to GPIO[2]
set_location_assignment PIN_W9 -to GPIO[3]
set_location_assignment PIN_V8 -to GPIO[4]
set_location_assignment PIN_W8 -to GPIO[5]
set_location_assignment PIN_V7 -to GPIO[6]
set_location_assignment PIN_W7 -to GPIO[7]
set_location_assignment PIN_W6 -to GPIO[8]
set_location_assignment PIN_V5 -to GPIO[9]
set_location_assignment PIN_W5 -to GPIO[10]
set_location_assignment PIN_AA15 -to GPIO[11]
set_location_assignment PIN_AA14 -to GPIO[12]

# IO Standard for all
set_global_assignment -name RESERVE_ALL_UNUSED_PINS_WEAK_PULLUP "AS BIDIRECTIONAL"
```

### 4.6 Nạp xuống FPGA

```
1. Tools → Programmer
2. Hardware Setup: chọn "USB-Blaster"
 (nếu không thấy → cài driver USB-Blaster)
3. Mode: JTAG
4. File: Add File → chọn output_files/<project>.sof
5. Tick Program/Configure
6. Nhấn Start

Lưu ý:
- .sof = SRAM Object File → mất khi tắt nguồn
- .pof = Programmer Object File → lưu vĩnh viễn vào flash
 (File → Convert Programming Files → .pof)
```

---

## 5. Ví dụ 1: Blink LED

### Blink LED mỗi giây (50 MHz clock → chia 25 triệu)

```verilog
module blink_led(
 input wire MAX10_CLK1_50, // 50 MHz clock
 input wire [1:0] KEY, // KEY[0] làm reset
 output reg [9:0] LEDR // 10 LEDs
);

 // 50_000_000 / 2 = 25_000_000 (toggle mỗi 0.5s → chu kỳ 1s)
 localparam HALF_SEC = 25_000_000;

 reg [24:0] counter; // clog2(25_000_000) = 25 bit

 always @(posedge MAX10_CLK1_50 or negedge KEY[0]) begin
 if (!KEY[0]) begin
 // Reset (KEY nhấn = LOW)
 counter <= 0;
 LEDR <= 10'b0;
 end else begin
 if (counter == HALF_SEC - 1) begin
 counter <= 0;
 LEDR[0] <= ~LEDR[0]; // Toggle LED 0
 end else begin
 counter <= counter + 1;
 end
 end
 end

endmodule
```

### Blink tất cả LED với tốc độ khác nhau

```verilog
module blink_all_leds(
 input wire MAX10_CLK1_50,
 input wire [1:0] KEY,
 output reg [9:0] LEDR
);

 reg [31:0] counter;

 always @(posedge MAX10_CLK1_50 or negedge KEY[0]) begin
 if (!KEY[0])
 counter <= 0;
 else
 counter <= counter + 1;
 end

 // Mỗi LED nhấp nháy ở tần số khác nhau
 // LED0: nhanh nhất, LED9: chậm nhất
 always @(posedge MAX10_CLK1_50) begin
 LEDR[0] <= counter[21]; // ~12 Hz
 LEDR[1] <= counter[22]; // ~6 Hz
 LEDR[2] <= counter[23]; // ~3 Hz
 LEDR[3] <= counter[24]; // ~1.5 Hz
 LEDR[4] <= counter[25]; // ~0.75 Hz
 LEDR[5] <= counter[26];
 LEDR[6] <= counter[27];
 LEDR[7] <= counter[28];
 LEDR[8] <= counter[29];
 LEDR[9] <= counter[30];
 end

endmodule
```

---

## 6. Ví dụ 2: Điều khiển LED bằng Switch

```verilog
// Switch ON → LED sáng (kết nối trực tiếp)
module sw_to_led(
 input wire [9:0] SW,
 output wire [9:0] LEDR
);
 assign LEDR = SW;
endmodule
```

```verilog
// Nâng cao: Logic giữa SW và LED
module sw_led_logic(
 input wire [9:0] SW,
 output wire [9:0] LEDR
);
 assign LEDR[0] = SW[0] & SW[1]; // AND
 assign LEDR[1] = SW[0] | SW[1]; // OR
 assign LEDR[2] = SW[0] ^ SW[1]; // XOR
 assign LEDR[3] = ~SW[0]; // NOT
 assign LEDR[4] = SW[2] & SW[3] & SW[4]; // 3-input AND
 assign LEDR[9:5] = SW[9:5]; // Pass-through
endmodule
```

---

## 7. Ví dụ 3: Hiển thị 7-Segment

### 7.1 Decoder — Chuyển HEX sang 7-segment (Active LOW)

```verilog
module hex_to_7seg(
 input wire [3:0] hex, // 0-F
 output reg [6:0] seg // Active LOW: 0=sáng, 1=tắt
);
 // gfedcba
 always @(*) begin
 case (hex)
 4'h0: seg = 7'b1000000; // 0
 4'h1: seg = 7'b1111001; // 1
 4'h2: seg = 7'b0100100; // 2
 4'h3: seg = 7'b0110000; // 3
 4'h4: seg = 7'b0011001; // 4
 4'h5: seg = 7'b0010010; // 5
 4'h6: seg = 7'b0000010; // 6
 4'h7: seg = 7'b1111000; // 7
 4'h8: seg = 7'b0000000; // 8
 4'h9: seg = 7'b0010000; // 9
 4'hA: seg = 7'b0001000; // A
 4'hB: seg = 7'b0000011; // b
 4'hC: seg = 7'b1000110; // C
 4'hD: seg = 7'b0100001; // d
 4'hE: seg = 7'b0000110; // E
 4'hF: seg = 7'b0001110; // F
 default: seg = 7'b1111111; // Tắt
 endcase
 end
endmodule
```

### 7.2 Hiển thị giá trị Switch lên HEX

```verilog
module sw_to_hex(
 input wire [9:0] SW,
 output wire [6:0] HEX0, // Hiển thị SW[3:0]
 output wire [6:0] HEX1, // Hiển thị SW[7:4]
 output wire [6:0] HEX2, // Tắt
 output wire [6:0] HEX3, // Tắt
 output wire [6:0] HEX4, // Tắt
 output wire [6:0] HEX5 // Tắt
);

 hex_to_7seg u_hex0 (.hex(SW[3:0]), .seg(HEX0));
 hex_to_7seg u_hex1 (.hex(SW[7:4]), .seg(HEX1));

 // Tắt các display không dùng (tất cả segment = 1)
 assign HEX2 = 7'b1111111;
 assign HEX3 = 7'b1111111;
 assign HEX4 = 7'b1111111;
 assign HEX5 = 7'b1111111;

endmodule
```

---

## 8. Ví dụ 4: Bộ đếm BCD 4 chữ số

```verilog
module bcd_counter_4digit(
 input wire MAX10_CLK1_50,
 input wire [1:0] KEY,
 input wire [9:0] SW,
 output wire [6:0] HEX0, HEX1, HEX2, HEX3,
 output wire [6:0] HEX4, HEX5,
 output wire [9:0] LEDR
);
 wire rst_n = KEY[0];
 wire pause = SW[0]; // SW[0] = 1 → tạm dừng

 // Chia tần 50MHz → 1Hz
 reg [25:0] clk_div;
 wire tick_1hz = (clk_div == 26'd49_999_999);

 always @(posedge MAX10_CLK1_50 or negedge rst_n) begin
 if (!rst_n) clk_div <= 0;
 else if (tick_1hz) clk_div <= 0;
 else clk_div <= clk_div + 1;
 end

 // 4 bộ đếm BCD nối tiếp
 reg [3:0] ones, tens, hundreds, thousands;
 wire en = tick_1hz & ~pause;

 always @(posedge MAX10_CLK1_50 or negedge rst_n) begin
 if (!rst_n) begin
 ones <= 0;
 tens <= 0;
 hundreds <= 0;
 thousands <= 0;
 end else if (en) begin
 if (ones == 4'd9) begin
 ones <= 0;
 if (tens == 4'd9) begin
 tens <= 0;
 if (hundreds == 4'd9) begin
 hundreds <= 0;
 if (thousands == 4'd9)
 thousands <= 0;
 else
 thousands <= thousands + 1;
 end else
 hundreds <= hundreds + 1;
 end else
 tens <= tens + 1;
 end else
 ones <= ones + 1;
 end
 end

 // Hiển thị lên 7-segment
 hex_to_7seg u0 (.hex(ones), .seg(HEX0));
 hex_to_7seg u1 (.hex(tens), .seg(HEX1));
 hex_to_7seg u2 (.hex(hundreds), .seg(HEX2));
 hex_to_7seg u3 (.hex(thousands), .seg(HEX3));
 assign HEX4 = 7'b1111111;
 assign HEX5 = 7'b1111111;

 // LED hiển thị trạng thái
 assign LEDR[0] = tick_1hz;
 assign LEDR[9] = pause;
 assign LEDR[8:1] = 8'd0;

endmodule
```

---

## 9. Ví dụ 5: LED chạy đuổi

```verilog
module led_runner(
 input wire MAX10_CLK1_50,
 input wire [1:0] KEY,
 input wire [9:0] SW,
 output reg [9:0] LEDR
);
 wire rst_n = KEY[0];
 wire dir = SW[0]; // 0=trái, 1=phải
 wire [3:0] speed = SW[4:1]; // Tốc độ (0=nhanh, 15=chậm)

 // Chia tần theo speed
 reg [25:0] counter;
 wire tick = (counter == {speed, 22'b0} + 26'd2_000_000);

 always @(posedge MAX10_CLK1_50 or negedge rst_n) begin
 if (!rst_n) counter <= 0;
 else if (tick) counter <= 0;
 else counter <= counter + 1;
 end

 // Dịch vòng LED
 always @(posedge MAX10_CLK1_50 or negedge rst_n) begin
 if (!rst_n)
 LEDR <= 10'b0000000001;
 else if (tick) begin
 if (dir)
 LEDR <= {LEDR[0], LEDR[9:1]}; // Dịch phải vòng
 else
 LEDR <= {LEDR[8:0], LEDR[9]}; // Dịch trái vòng
 end
 end

endmodule
```

---

## 10. GPIO & Xuất IO ra ngoài

### 10.1 Xuất tín hiệu ra GPIO Header

```verilog
module gpio_output(
 input wire MAX10_CLK1_50,
 input wire [1:0] KEY,
 output wire [35:0] GPIO // 36 GPIO pins
);
 wire rst_n = KEY[0];
 reg [31:0] counter;

 always @(posedge MAX10_CLK1_50 or negedge rst_n) begin
 if (!rst_n) counter <= 0;
 else counter <= counter + 1;
 end

 // Xuất tín hiệu ra GPIO
 assign GPIO[0] = counter[25]; // ~0.75 Hz square wave
 assign GPIO[1] = counter[24]; // ~1.5 Hz
 assign GPIO[2] = counter[23]; // ~3 Hz
 assign GPIO[35:3] = 33'b0; // Các pin còn lại = LOW

endmodule
```

### 10.2 Đọc tín hiệu từ GPIO

```verilog
module gpio_input(
 input wire MAX10_CLK1_50,
 input wire [1:0] KEY,
 input wire [35:0] GPIO, // GPIO làm input
 output wire [9:0] LEDR
);
 // Đồng bộ hóa GPIO input (chống metastability)
 reg [7:0] gpio_sync1, gpio_sync2;

 always @(posedge MAX10_CLK1_50) begin
 gpio_sync1 <= GPIO[7:0];
 gpio_sync2 <= gpio_sync1;
 end

 assign LEDR[7:0] = gpio_sync2;
 assign LEDR[9:8] = 2'b0;

endmodule
```

### 10.3 GPIO Bidirectional (Hai chiều)

```verilog
module gpio_bidir(
 input wire MAX10_CLK1_50,
 input wire [9:0] SW,
 inout wire [7:0] GPIO // Bidirectional!
);
 wire dir = SW[9]; // 1=output, 0=input
 reg [7:0] gpio_out;

 always @(posedge MAX10_CLK1_50)
 gpio_out <= SW[7:0];

 // Tri-state: output khi dir=1, hi-z khi dir=0
 assign GPIO[7:0] = dir ? gpio_out : 8'bz;

endmodule
```

### 10.4 Sơ đồ kết nối GPIO → Breadboard

```
 DE10-Lite GPIO Header (JP1)
 ┌─────────────────────────┐
 │ 3.3V GPIO[0] GPIO[1] │
 │ GND GPIO[2] GPIO[3] │ → ┌──────────────┐
 │ ... ... ... │ → │ Breadboard │
 │ 3.3V GPIO[34] GPIO[35]│ → │ LED + 330Ω │
 │ GND 5V │ → │ Sensor │
 └─────────────────────────┘ └──────────────┘

 Kết nối LED ra GPIO:
 GPIO[0] ──→ 330Ω ──→ LED(+) ──→ GND

 Kết nối nút nhấn vào GPIO:
 3.3V ──→ 10kΩ (pull-up) ──→ GPIO[0]
 ↓
 Button ──→ GND
```

> ️ **Quan trọng**: GPIO pin hoạt động **3.3V**. Nếu kết nối với thiết bị 5V, cần **level shifter** hoặc **voltage divider**.

---

## 11. Lỗi thường gặp & Troubleshooting

| Lỗi | Nguyên nhân | Giải pháp |
|------|------------|-----------|
| **USB-Blaster not found** | Chưa cài driver | Cài driver từ `quartus/drivers/usb-blaster` |
| **No device detected** | Cáp USB lỏng | Kiểm tra kết nối, thử cổng USB khác |
| **Pin conflict** | 2 tín hiệu gán cùng pin | Kiểm tra .qsf, mỗi pin chỉ 1 tín hiệu |
| **7-Segment hiển thị ngược** | Active LOW | Đảo bit: `seg = ~seg_active_high` |
| **LED không sáng** | Active level sai | DE10-Lite LED active HIGH |
| **KEY luôn = 0** | Active LOW | `!KEY[0]` để detect nhấn |
| **Timing violation** | Logic quá phức tạp | Thêm pipeline, giảm tần số |
| **BRAM not inferred** | Đọc bất đồng bộ | Đọc phải đồng bộ (trong always@posedge) |
| **.sof mất khi tắt nguồn** | SRAM config | Chuyển sang .pof (flash) |

### Chuyển đổi .sof → .pof (lưu vĩnh viễn)

```
File → Convert Programming Files
 → Programming file type: .pof
 → Configuration device: CFM (Internal Configuration)
 → Add input file: .sof
 → Generate
```

---

> **Tài liệu tham khảo**: [DE10-Lite User Manual (Terasic)](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=1021&PartNo=4) | [MAX 10 FPGA Datasheet (Intel)](https://www.intel.com/content/www/us/en/docs/programmable/683794/) | [Quartus Prime Handbook](https://www.intel.com/content/www/us/en/docs/programmable/683283/)
