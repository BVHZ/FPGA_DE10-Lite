# 📙 Tài liệu Lập trình Verilog — Phần 3: Testbench, Mô phỏng & Kỹ thuật Nâng cao

> **Phần trước**: [README.md](README.md) — Tổng quan & Cú pháp cơ bản | [index.md](index.md) — Thiết kế mạch số

---

## 📑 Mục lục

- [1. Testbench — Khái niệm & Cấu trúc](#1-testbench--khái-niệm--cấu-trúc)
- [2. System Tasks & Functions](#2-system-tasks--functions)
- [3. Directive — Chỉ thị tiền xử lý](#3-directive--chỉ-thị-tiền-xử-lý)
- [4. Ví dụ Testbench hoàn chỉnh](#4-ví-dụ-testbench-hoàn-chỉnh)
- [5. Kỹ thuật Verification](#5-kỹ-thuật-verification)
- [6. Tổng hợp (Synthesis) & Tối ưu](#6-tổng-hợp-synthesis--tối-ưu)
- [7. Quy trình công cụ EDA](#7-quy-trình-công-cụ-eda)
- [8. Bài tập thực hành](#8-bài-tập-thực-hành)
- [9. Thuật ngữ Verilog](#9-thuật-ngữ-verilog)

---

## 1. Testbench — Khái niệm & Cấu trúc

### 1.1 Testbench là gì?

**Testbench** là module Verilog đặc biệt dùng để **kiểm tra** (verify) module thiết kế (DUT — Design Under Test). Testbench:
- **Không có port** (không input/output)
- **Không được tổng hợp** — chỉ dùng cho mô phỏng
- Tạo tín hiệu kích thích (stimulus) → đưa vào DUT → quan sát output

### 1.2 Cấu trúc Testbench cơ bản

```
┌─────────────────────────────────────────┐
│              TESTBENCH                  │
│                                         │
│  ┌──────────┐          ┌──────────┐    │
│  │ Stimulus │ ──────── │   DUT    │    │
│  │ Generator│  inputs  │ (Module  │    │
│  └──────────┘          │  cần     │    │
│                        │  test)   │    │
│  ┌──────────┐          └────┬─────┘    │
│  │ Response │ ◄─────────────┘          │
│  │ Checker  │   outputs                │
│  └──────────┘                          │
│                                         │
│  ┌──────────┐                          │
│  │ Clock    │                          │
│  │ Generator│                          │
│  └──────────┘                          │
└─────────────────────────────────────────┘
```

### 1.3 Template Testbench

```verilog
`timescale 1ns / 1ps

module module_name_tb;    // Testbench KHÔNG có port

    // ========================================
    // 1. Khai báo tín hiệu
    // ========================================
    reg         clk;
    reg         rst_n;
    reg  [7:0]  data_in;
    wire [7:0]  data_out;
    wire        valid;

    // ========================================
    // 2. Khởi tạo DUT (Design Under Test)
    // ========================================
    module_name u_dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .data_in  (data_in),
        .data_out (data_out),
        .valid    (valid)
    );

    // ========================================
    // 3. Tạo Clock
    // ========================================
    parameter CLK_PERIOD = 20;   // 20ns → 50 MHz

    initial clk = 1'b0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // ========================================
    // 4. Stimulus — Tạo tín hiệu kích thích
    // ========================================
    initial begin
        // Khởi tạo
        rst_n   = 1'b0;
        data_in = 8'd0;

        // Reset
        #(CLK_PERIOD * 5);
        rst_n = 1'b1;
        #(CLK_PERIOD * 2);

        // Test case 1: Gửi dữ liệu
        @(posedge clk);
        data_in = 8'hAB;

        // Test case 2
        @(posedge clk);
        data_in = 8'hCD;

        // Test case 3
        @(posedge clk);
        data_in = 8'h00;

        // Chờ và kết thúc
        #(CLK_PERIOD * 10);
        $display("=== SIMULATION COMPLETE ===");
        $finish;
    end

    // ========================================
    // 5. Monitor — Quan sát kết quả
    // ========================================
    initial begin
        $monitor("Time=%0t | rst_n=%b | data_in=%h | data_out=%h | valid=%b",
                 $time, rst_n, data_in, data_out, valid);
    end

    // ========================================
    // 6. Dump waveform (cho GTKWave, ModelSim, etc.)
    // ========================================
    initial begin
        $dumpfile("module_name_tb.vcd");
        $dumpvars(0, module_name_tb);
    end

endmodule
```

---

## 2. System Tasks & Functions

### 2.1 Hiển thị và Debug

```verilog
// $display — In ra terminal rồi xuống dòng (như printf + \n)
$display("Hello Verilog!");
$display("Time=%0t, a=%b, b=%h, c=%d", $time, a, b, c);
$display("Signed value: %0d", $signed(data));

// $write — In ra KHÔNG xuống dòng
$write("Data: ");
$write("%h ", data);

// $strobe — In ra cuối time step (sau khi tất cả assignments hoàn thành)
$strobe("Time=%0t, q=%b", $time, q);

// $monitor — Tự động in mỗi khi bất kỳ tham số nào thay đổi
// Chỉ gọi 1 lần — sau đó tự động theo dõi
$monitor("Time=%0t | clk=%b rst=%b data=%h", $time, clk, rst, data);
$monitoron;     // Bật monitor
$monitoroff;    // Tắt monitor
```

### 2.2 Format Specifier

| Specifier | Ý nghĩa | Ví dụ |
|-----------|----------|-------|
| `%b` | Binary | `1010` |
| `%o` | Octal | `12` |
| `%d` | Decimal | `10` |
| `%h` | Hexadecimal | `A` |
| `%s` | String | `"hello"` |
| `%t` | Time | (`$time`) |
| `%0d` | Decimal (không padding) | `10` thay vì `        10` |
| `%m` | Module path | `top.u_dut.u_alu` |

### 2.3 Điều khiển mô phỏng

```verilog
// Kết thúc mô phỏng
$finish;            // Dừng hoàn toàn
$finish(0);         // Dừng, không in thống kê
$finish(1);         // Dừng, in thời gian mô phỏng
$finish(2);         // Dừng, in đầy đủ thống kê

$stop;              // Tạm dừng (có thể tiếp tục trong simulator)

// Thời gian
$time               // Trả về thời gian mô phỏng (integer, 64-bit)
$realtime           // Trả về thời gian thực (real)
$stime              // Trả về thời gian (32-bit)
```

### 2.4 Đọc/Ghi File

```verilog
// === Đọc file vào memory ===
reg [7:0] mem [0:255];

initial begin
    // Đọc file hex
    $readmemh("data.hex", mem);         // Đọc hex vào mem
    $readmemh("data.hex", mem, 0, 15);  // Chỉ đọc ô 0-15
    
    // Đọc file binary
    $readmemb("data.bin", mem);         // Đọc binary vào mem
end

// === Ghi ra file ===
integer fd;     // file descriptor

initial begin
    fd = $fopen("output.txt", "w");     // Mở file để ghi
    
    if (fd == 0) begin
        $display("ERROR: Cannot open file!");
        $finish;
    end
    
    $fdisplay(fd, "Time, Data");        // Ghi header
    
    repeat (100) begin
        @(posedge clk);
        $fdisplay(fd, "%0t, %h", $time, data_out);
    end
    
    $fclose(fd);                         // Đóng file
end

// Các hàm ghi file tương tự display
$fdisplay(fd, ...);    // Ghi + xuống dòng
$fwrite(fd, ...);      // Ghi không xuống dòng
$fstrobe(fd, ...);     // Ghi cuối time step
$fmonitor(fd, ...);    // Ghi khi giá trị thay đổi
```

### 2.5 Waveform Dump

```verilog
// VCD (Value Change Dump) — chuẩn IEEE
initial begin
    $dumpfile("waveform.vcd");      // Tên file output
    $dumpvars(0, testbench_name);   // Dump tất cả tín hiệu
    // 0 = tất cả levels, testbench_name = module gốc
    
    $dumpvars(1, testbench_name);   // Chỉ level 1 (không đệ quy)
    $dumpvars(0, u_dut.u_alu);     // Chỉ dump module cụ thể
end

// Điều khiển dump
$dumpon;       // Bật dump
$dumpoff;      // Tắt dump (tiết kiệm dung lượng)
$dumpall;      // Dump checkpoint
$dumplimit(1_000_000);  // Giới hạn file 1MB
```

### 2.6 Hàm toán học

```verilog
$clog2(N)       // Ceiling log2 — tính số bit cần cho N giá trị
                // $clog2(8) = 3, $clog2(9) = 4, $clog2(256) = 8

$signed(a)      // Chuyển thành số có dấu
$unsigned(a)    // Chuyển thành số không dấu

// Các hàm dùng trong testbench (không tổng hợp):
$random         // Số ngẫu nhiên 32-bit có dấu
$random % 256   // Số ngẫu nhiên 0-255
$urandom        // Số ngẫu nhiên 32-bit không dấu
$urandom_range(max, min)  // Ngẫu nhiên trong khoảng
```

---

## 3. Directive — Chỉ thị tiền xử lý

### 3.1 Timescale

```verilog
// Cú pháp: `timescale <time_unit> / <time_precision>
`timescale 1ns / 1ps
// • time_unit: đơn vị cho #delay (1ns)
// • time_precision: độ chính xác nhỏ nhất (1ps)

// Ví dụ:
`timescale 1ns / 1ps
module test;
    initial begin
        #10;        // Chờ 10ns
        #10.5;      // Chờ 10.5ns (làm tròn đến ps)
        #0.001;     // Chờ 1ps
    end
endmodule

// Các tổ hợp phổ biến:
`timescale 1ns / 1ns       // Cho thiết kế đơn giản
`timescale 1ns / 1ps       // Phổ biến nhất
`timescale 1ps / 1ps       // Cho timing simulation chính xác
```

### 3.2 Define & Macro

```verilog
// Định nghĩa macro
`define DATA_WIDTH 8
`define ADDR_WIDTH 16
`define CLK_PERIOD 20

// Sử dụng macro (CÓ dấu `)
wire [`DATA_WIDTH-1:0] data;
wire [`ADDR_WIDTH-1:0] addr;
always #(`CLK_PERIOD/2) clk = ~clk;

// Macro có tham số
`define MAX(a, b) ((a) > (b) ? (a) : (b))
assign max_val = `MAX(x, y);

// Kiểm tra macro đã định nghĩa chưa
`ifdef DEBUG
    // Code chỉ biên dịch khi DEBUG được define
    initial $display("Debug mode ON");
`else
    // Code cho chế độ bình thường
`endif

// Xóa macro
`undef DATA_WIDTH
```

### 3.3 Include

```verilog
// Nhúng file khác (giống #include trong C)
`include "defines.vh"      // File chứa các `define
`include "module_a.v"      // KHÔNG khuyến khích — dùng file list

// File defines.vh thường chứa:
`ifndef _DEFINES_VH_       // Include guard
`define _DEFINES_VH_

`define CLK_FREQ   50_000_000
`define BAUD_RATE  115200
`define DATA_WIDTH 8

`endif
```

### 3.4 Conditional Compilation

```verilog
`define SIMULATION   // Comment dòng này khi synthesis

module design(
    input wire clk,
    // ...
);
    `ifdef SIMULATION
        // Chỉ có trong mô phỏng
        initial begin
            $display("Running in simulation mode");
        end
    `elsif SYNTHESIS
        // Chỉ có khi synthesis
    `else
        // Mặc định
    `endif
endmodule
```

---

## 4. Ví dụ Testbench hoàn chỉnh

### 4.1 Testbench cho Full Adder

```verilog
`timescale 1ns / 1ps

module full_adder_tb;

    // Tín hiệu
    reg  a, b, cin;
    wire sum, cout;

    // DUT
    full_adder u_dut (
        .a    (a),
        .b    (b),
        .cin  (cin),
        .sum  (sum),
        .cout (cout)
    );

    // Test tất cả tổ hợp input (exhaustive testing)
    integer i;
    reg [2:0] test_vector;
    reg       expected_sum, expected_cout;
    integer   errors = 0;

    initial begin
        $display("===========================================");
        $display("   Full Adder Testbench");
        $display("===========================================");
        $display("  a  b cin | sum cout | expected | status");
        $display("-------------------------------------------");

        for (i = 0; i < 8; i = i + 1) begin
            test_vector = i;
            {a, b, cin} = test_vector;

            // Tính giá trị mong đợi
            {expected_cout, expected_sum} = a + b + cin;

            #10;  // Chờ mạch ổn định

            // Kiểm tra
            if (sum !== expected_sum || cout !== expected_cout) begin
                $display("  %b  %b  %b  |  %b    %b   |  %b    %b   | FAIL ✗",
                         a, b, cin, sum, cout, expected_sum, expected_cout);
                errors = errors + 1;
            end else begin
                $display("  %b  %b  %b  |  %b    %b   |  %b    %b   | PASS ✓",
                         a, b, cin, sum, cout, expected_sum, expected_cout);
            end
        end

        $display("-------------------------------------------");
        if (errors == 0)
            $display("  ALL TESTS PASSED! (%0d/8)", 8);
        else
            $display("  FAILED: %0d errors found", errors);
        $display("===========================================");
        $finish;
    end

    // Waveform
    initial begin
        $dumpfile("full_adder_tb.vcd");
        $dumpvars(0, full_adder_tb);
    end

endmodule
```

### 4.2 Testbench cho Counter (Mạch tuần tự)

```verilog
`timescale 1ns / 1ps

module counter_tb;

    // Parameters
    parameter CLK_PERIOD = 20;  // 50 MHz
    parameter WIDTH = 8;

    // Signals
    reg                  clk;
    reg                  rst_n;
    reg                  enable;
    wire [WIDTH-1:0]     count;
    wire                 max_tick;

    // DUT
    up_counter #(.WIDTH(WIDTH)) u_dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .enable   (enable),
        .count    (count),
        .max_tick (max_tick)
    );

    // Clock generation
    initial clk = 1'b0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // Task helper: reset
    task automatic do_reset;
        begin
            rst_n = 1'b0;
            @(posedge clk);
            @(posedge clk);
            rst_n = 1'b1;
            @(posedge clk);
        end
    endtask

    // Task helper: chờ N clock cycles
    task automatic wait_clocks;
        input integer n;
        integer j;
        begin
            for (j = 0; j < n; j = j + 1)
                @(posedge clk);
        end
    endtask

    // Main test
    integer errors = 0;

    initial begin
        $display("=== Counter Testbench ===");
        
        // Khởi tạo
        enable = 1'b0;

        // Test 1: Reset
        $display("[Test 1] Reset...");
        do_reset;
        if (count !== 0) begin
            $display("  FAIL: count=%0d, expected 0", count);
            errors = errors + 1;
        end else
            $display("  PASS: count=0 after reset");

        // Test 2: Enable counting
        $display("[Test 2] Enable counting...");
        enable = 1'b1;
        wait_clocks(10);
        $display("  count after 10 clocks = %0d", count);
        if (count !== 10) begin
            $display("  FAIL: expected 10");
            errors = errors + 1;
        end else
            $display("  PASS");

        // Test 3: Disable counting
        $display("[Test 3] Disable counting...");
        enable = 1'b0;
        wait_clocks(5);
        if (count !== 10) begin
            $display("  FAIL: count changed to %0d", count);
            errors = errors + 1;
        end else
            $display("  PASS: count held at %0d", count);

        // Test 4: Resume counting
        $display("[Test 4] Resume counting...");
        enable = 1'b1;
        wait_clocks(5);
        if (count !== 15) begin
            $display("  FAIL: count=%0d, expected 15", count);
            errors = errors + 1;
        end else
            $display("  PASS: count=%0d", count);

        // Test 5: Overflow (rollover)
        $display("[Test 5] Overflow test...");
        do_reset;
        enable = 1'b1;
        wait_clocks(256);    // 8-bit counter rolls over at 256
        if (count !== 0) begin
            $display("  FAIL: count=%0d after 256 clocks", count);
            errors = errors + 1;
        end else
            $display("  PASS: count rolled over to 0");

        // Summary
        $display("\n=== RESULTS ===");
        if (errors == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("FAILED: %0d errors", errors);

        #100;
        $finish;
    end

    // Waveform
    initial begin
        $dumpfile("counter_tb.vcd");
        $dumpvars(0, counter_tb);
    end

endmodule
```

### 4.3 Testbench cho ALU

```verilog
`timescale 1ns / 1ps

module alu_tb;

    parameter WIDTH = 8;

    reg  [WIDTH-1:0] a, b;
    reg  [3:0]       alu_op;
    wire [WIDTH-1:0] result;
    wire             zero, carry, overflow;

    alu #(.WIDTH(WIDTH)) u_dut (
        .a        (a),
        .b        (b),
        .alu_op   (alu_op),
        .result   (result),
        .zero     (zero),
        .carry    (carry),
        .overflow (overflow)
    );

    // ALU opcodes
    localparam ALU_ADD = 4'b0000;
    localparam ALU_SUB = 4'b0001;
    localparam ALU_AND = 4'b0010;
    localparam ALU_OR  = 4'b0011;
    localparam ALU_XOR = 4'b0100;

    // Task: test một phép toán
    task automatic test_alu;
        input [3:0]       op;
        input [WIDTH-1:0] in_a, in_b;
        input [WIDTH-1:0] expected;
        input [80*8-1:0]  test_name;    // String
        begin
            alu_op = op;
            a = in_a;
            b = in_b;
            #10;
            if (result !== expected)
                $display("FAIL [%0s]: %0d op %0d = %0d (expected %0d)",
                         test_name, in_a, in_b, result, expected);
            else
                $display("PASS [%0s]: %0d op %0d = %0d",
                         test_name, in_a, in_b, result);
        end
    endtask

    initial begin
        $display("=== ALU Testbench ===\n");

        // Addition tests
        test_alu(ALU_ADD, 8'd10,  8'd20,  8'd30,  "ADD basic");
        test_alu(ALU_ADD, 8'd0,   8'd0,   8'd0,   "ADD zero");
        test_alu(ALU_ADD, 8'd255, 8'd1,   8'd0,   "ADD overflow");

        // Subtraction tests
        test_alu(ALU_SUB, 8'd20,  8'd10,  8'd10,  "SUB basic");
        test_alu(ALU_SUB, 8'd10,  8'd10,  8'd0,   "SUB zero result");

        // AND tests
        test_alu(ALU_AND, 8'hFF,  8'h0F,  8'h0F,  "AND basic");
        test_alu(ALU_AND, 8'hAA,  8'h55,  8'h00,  "AND no overlap");

        // OR tests
        test_alu(ALU_OR,  8'hA0,  8'h0B,  8'hAB,  "OR basic");

        // XOR tests
        test_alu(ALU_XOR, 8'hFF,  8'hFF,  8'h00,  "XOR same");
        test_alu(ALU_XOR, 8'hAA,  8'h55,  8'hFF,  "XOR complement");

        // Random tests
        $display("\n--- Random Tests ---");
        repeat (20) begin
            a = $random;
            b = $random;
            alu_op = ALU_ADD;
            #10;
            if (result !== (a + b))
                $display("FAIL: %0d + %0d = %0d (expected %0d)", a, b, result, a+b);
        end

        $display("\n=== ALU Test Complete ===");
        $finish;
    end

    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);
    end

endmodule
```

---

## 5. Kỹ thuật Verification

### 5.1 Self-checking Testbench

```verilog
// Thay vì kiểm tra bằng mắt → tự động kiểm tra

// Mô hình tham chiếu (reference model)
function [8:0] expected_add;
    input [7:0] a, b;
    input       cin;
    begin
        expected_add = a + b + cin;
    end
endfunction

// So sánh tự động
always @(posedge clk) begin
    if (valid_out) begin
        if (result !== expected_add(a_reg, b_reg, cin_reg)) begin
            $display("ERROR at time %0t: got %h, expected %h",
                     $time, result, expected_add(a_reg, b_reg, cin_reg));
            error_count = error_count + 1;
        end
    end
end
```

### 5.2 Task và Function trong Testbench

```verilog
// === TASK: có thể chứa delay, nhiều lệnh ===
task automatic send_byte;
    input [7:0] byte_data;
    integer i;
    begin
        // Start bit
        tx = 1'b0;
        #(BIT_PERIOD);

        // 8 data bits (LSB first)
        for (i = 0; i < 8; i = i + 1) begin
            tx = byte_data[i];
            #(BIT_PERIOD);
        end

        // Stop bit
        tx = 1'b1;
        #(BIT_PERIOD);
    end
endtask

// Sử dụng:
initial begin
    send_byte(8'hA5);
    send_byte(8'h3C);
end

// === FUNCTION: không có delay, trả về 1 giá trị ===
function [7:0] reverse_bits;
    input [7:0] data;
    integer i;
    begin
        for (i = 0; i < 8; i = i + 1)
            reverse_bits[i] = data[7-i];
    end
endfunction

// Sử dụng:
wire [7:0] reversed = reverse_bits(8'hA5);  // => 8'hA5 reversed
```

### 5.3 So sánh Task vs Function

| Tiêu chí | `task` | `function` |
|-----------|--------|-----------|
| Delay (`#`, `@`, `wait`) | ✅ Có thể | ❌ Không |
| Giá trị trả về | Không (dùng output) | 1 giá trị |
| Gọi task khác | ✅ Có thể | ❌ Không |
| Gọi function | ✅ Có thể | ✅ Có thể |
| Dùng cho | Tạo stimulus, protocol | Tính toán, chuyển đổi |
| Tổng hợp | Hạn chế | ✅ Tổng hợp được |

### 5.4 Coverage-Driven Verification

```verilog
// Đếm số test case đã thực hiện
integer test_count = 0;
integer pass_count = 0;
integer fail_count = 0;

task automatic check_result;
    input [7:0] actual, expected;
    input [255:0] test_name;
    begin
        test_count = test_count + 1;
        if (actual === expected) begin
            pass_count = pass_count + 1;
            $display("[%0d] PASS: %0s | result=%h", test_count, test_name, actual);
        end else begin
            fail_count = fail_count + 1;
            $display("[%0d] FAIL: %0s | got=%h, expected=%h",
                     test_count, test_name, actual, expected);
        end
    end
endtask

// Cuối simulation
initial begin
    // ... các test cases ...
    
    #1000;
    $display("\n========== TEST SUMMARY ==========");
    $display("  Total:  %0d", test_count);
    $display("  Passed: %0d", pass_count);
    $display("  Failed: %0d", fail_count);
    $display("  Rate:   %0d%%", pass_count * 100 / test_count);
    $display("==================================");
    
    if (fail_count > 0)
        $display("STATUS: ❌ FAILED");
    else
        $display("STATUS: ✅ ALL PASSED");
    
    $finish;
end
```

### 5.5 Randomized Testing

```verilog
// Random seed
integer seed = 42;

initial begin
    repeat (1000) begin
        a = $random(seed);
        b = $random(seed);
        alu_op = $random(seed) % 10;
        
        #10;
        
        // Kiểm tra với reference model
        case (alu_op)
            0: expected = a + b;
            1: expected = a - b;
            // ...
        endcase
        
        if (result !== expected[WIDTH-1:0]) begin
            $display("RANDOM TEST FAIL at seed=%0d", seed);
            errors = errors + 1;
        end
    end
    
    $display("Random testing: %0d errors in 1000 tests", errors);
end
```

---

## 6. Tổng hợp (Synthesis) & Tối ưu

### 6.1 Synthesizable vs Non-synthesizable

| Tổng hợp được ✅ | KHÔNG tổng hợp được ❌ |
|---|---|
| `module`, `endmodule` | `initial` block |
| `input`, `output`, `inout` | `#delay` |
| `wire`, `reg` | `$display`, `$monitor` |
| `assign` | `$finish`, `$stop` |
| `always @(posedge/negedge)` | `$readmemh`, `$dumpvars` |
| `always @(*)` | `$random` |
| `if/else`, `case` | `real`, `time` |
| `for` (biết trước số lần lặp) | `while` (với điều kiện runtime) |
| `generate` | `wait` |
| `parameter`, `localparam` | `===`, `!==` |
| `function` (không delay) | `fork/join` |

### 6.2 Inferred Hardware

```verilog
// === Wire / Assign → Combinational Logic ===
assign y = a & b;           // → AND gate

// === always @(*) → Combinational Logic ===
always @(*) begin
    y = a + b;               // → Adder
end

// === always @(posedge clk) → Flip-Flop ===
always @(posedge clk) begin
    q <= d;                  // → D Flip-Flop
end

// === if without else in always @(*) → LATCH ===
always @(*) begin
    if (en) q = d;           // → LATCH ⚠️ (Không mong muốn!)
end

// === Incomplete case → LATCH ===
always @(*) begin
    case (sel)
        2'b00: y = a;
        2'b01: y = b;
        // Thiếu 2'b10, 2'b11 → LATCH!
    endcase
end
```

### 6.3 Coding for Synthesis — Best Practices

```verilog
// ✅ 1. Dùng non-blocking (<=) cho sequential
always @(posedge clk) begin
    a <= b;
    c <= d;
end

// ✅ 2. Dùng blocking (=) cho combinational
always @(*) begin
    y = a & b;
end

// ✅ 3. Có default/else đầy đủ
always @(*) begin
    y = 0;              // Default
    case (sel)
        2'b00: y = a;
        2'b01: y = b;
        default: y = 0;
    endcase
end

// ✅ 4. Tránh latch — luôn gán tất cả output
always @(*) begin
    out1 = 0;
    out2 = 0;
    if (condition) begin
        out1 = a;
        out2 = b;
    end
end

// ✅ 5. Dùng parameter thay magic number
parameter BAUD_DIV = 434;  // 50MHz / 115200 ≈ 434

// ✅ 6. Tránh gated clock — dùng clock enable thay thế
// ❌ SAI:
// wire gated_clk = clk & enable;
// always @(posedge gated_clk) ...

// ✅ ĐÚNG:
always @(posedge clk) begin
    if (enable)
        q <= d;
end
```

### 6.4 Tối ưu tài nguyên

```verilog
// === Resource Sharing: Dùng chung bộ cộng ===
// ❌ Dùng 2 bộ cộng:
assign result = sel ? (a + b) : (c + d);

// ✅ Dùng 1 bộ cộng:
wire [7:0] mux_a = sel ? a : c;
wire [7:0] mux_b = sel ? b : d;
assign result = mux_a + mux_b;

// === Pipelining: Tăng tốc bằng chia giai đoạn ===
// Pipeline 2 stage cho phép nhân
always @(posedge clk) begin
    // Stage 1: Nhân
    mult_result <= a * b;
    
    // Stage 2: Cộng
    final_result <= mult_result + c;
end
```

---

## 7. Quy trình công cụ EDA

### 7.1 Công cụ mô phỏng miễn phí

| Công cụ | Nền tảng | Mô tả |
|---------|---------|-------|
| **Icarus Verilog** | Windows/Linux/Mac | Mô phỏng Verilog miễn phí phổ biến nhất |
| **GTKWave** | Windows/Linux/Mac | Xem waveform (.vcd) |
| **Verilator** | Linux/Mac | Mô phỏng nhanh, chuyển Verilog→C++ |
| **EDA Playground** | Web | Mô phỏng online, không cần cài đặt |

### 7.2 Quy trình với Icarus Verilog

```bash
# 1. Biên dịch
iverilog -o output.vvp design.v testbench.v

# 2. Chạy mô phỏng
vvp output.vvp

# 3. Xem waveform
gtkwave waveform.vcd

# Biên dịch nhiều file
iverilog -o sim.vvp \
    src/top_module.v \
    src/sub_module.v \
    tb/testbench.v

# Sử dụng file list
# files.lst:
# src/top_module.v
# src/sub_module.v
# tb/testbench.v
iverilog -o sim.vvp -f files.lst
```

### 7.3 Công cụ FPGA

| Nhà sản xuất | Công cụ | FPGA |
|-------------|---------|------|
| **Xilinx (AMD)** | Vivado | Artix, Kintex, Zynq |
| **Intel (Altera)** | Quartus Prime | Cyclone, MAX, Stratix |
| **Lattice** | Lattice Diamond, Radiant | iCE40, ECP5 |
| **Gowin** | Gowin IDE | GW1N, GW2A |

### 7.4 Quy trình FPGA (Vivado)

```
1. Create Project
   └── Chọn FPGA target (ví dụ: xc7a35tcpg236-1)
   
2. Add Sources
   ├── Design Sources: *.v (RTL code)
   ├── Simulation Sources: *_tb.v (testbench)
   └── Constraints: *.xdc (pin mapping)

3. Run Simulation
   └── Behavioral Simulation (kiểm tra logic)

4. Run Synthesis
   └── Chuyển RTL → Netlist (cổng logic)

5. Run Implementation
   ├── Opt Design (tối ưu)
   ├── Place Design (đặt vị trí trên FPGA)
   └── Route Design (kết nối routing)

6. Generate Bitstream
   └── File .bit để nạp vào FPGA

7. Program Device
   └── Nạp bitstream vào FPGA
```

### 7.5 Constraints File (Xilinx .xdc)

```tcl
## Clock
set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports {clk}]
create_clock -add -name sys_clk -period 10.00 [get_ports {clk}]

## Reset button
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports {rst_n}]

## LEDs
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
set_property -dict { PACKAGE_PIN U19 IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
set_property -dict { PACKAGE_PIN V19 IOSTANDARD LVCMOS33 } [get_ports {led[3]}]

## Switches
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports {sw[0]}]
set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports {sw[1]}]

## 7-Segment Display
set_property -dict { PACKAGE_PIN W7 IOSTANDARD LVCMOS33 } [get_ports {seg[0]}]
set_property -dict { PACKAGE_PIN W6 IOSTANDARD LVCMOS33 } [get_ports {seg[1]}]
# ... (tiếp tục cho các segment còn lại)
```

---

## 8. Bài tập thực hành

### 📝 Mức cơ bản

| # | Bài tập | Kỹ năng |
|---|---------|---------|
| 1 | Viết module cổng AND/OR/XOR 4-bit | Cú pháp cơ bản, assign |
| 2 | MUX 8:1 dùng case | case, always @(*) |
| 3 | Full Adder 4-bit | generate, module instantiation |
| 4 | Decoder 4-to-16 | case, output vector |
| 5 | Comparator 8-bit | Toán tử so sánh |

### 📝 Mức trung bình

| # | Bài tập | Kỹ năng |
|---|---------|---------|
| 6 | Bộ đếm BCD 2 chữ số (00-99) | Counter, carry chain |
| 7 | Shift Register 8-bit SIPO + PISO | Sequential logic |
| 8 | ALU 8 phép toán | case, arithmetic |
| 9 | PWM 8-bit với duty cycle thay đổi | Counter, comparator |
| 10 | Debounce + Edge detector | Đồng bộ hóa, timing |

### 📝 Mức nâng cao

| # | Bài tập | Kỹ năng |
|---|---------|---------|
| 11 | UART Transmitter | FSM, baud rate |
| 12 | UART Receiver | FSM, sampling |
| 13 | SPI Master | FSM, shift register |
| 14 | I2C Controller | FSM phức tạp |
| 15 | VGA Controller 640x480 | Timing, counters |
| 16 | FIFO bất đồng bộ | Clock domain crossing |
| 17 | CPU đơn giản 8-bit | Kiến trúc máy tính |

### 📝 Template bài tập

```verilog
// =============================================
// Bài X: [Tên bài]
// Yêu cầu: [Mô tả]
// =============================================

// File: exercise_x.v
module exercise_x (
    // TODO: Khai báo ports
);
    // TODO: Viết logic
endmodule

// File: exercise_x_tb.v
`timescale 1ns / 1ps
module exercise_x_tb;
    // TODO: Viết testbench
    // 1. Khai báo tín hiệu
    // 2. Khởi tạo DUT
    // 3. Tạo clock (nếu cần)
    // 4. Viết test cases
    // 5. Kiểm tra kết quả tự động
endmodule
```

---

## 9. Thuật ngữ Verilog

| Thuật ngữ | Tiếng Việt | Giải thích |
|-----------|-----------|-----------|
| **HDL** | Ngôn ngữ mô tả phần cứng | Hardware Description Language |
| **RTL** | Mức thanh ghi truyền | Register Transfer Level — mức trừu tượng phổ biến |
| **DUT** | Thiết kế cần kiểm tra | Design Under Test |
| **Synthesis** | Tổng hợp | Chuyển code → netlist (cổng logic) |
| **Simulation** | Mô phỏng | Chạy code trên máy tính để kiểm tra logic |
| **Testbench** | Bàn thử | Module dùng để test DUT |
| **Netlist** | Danh sách kết nối | Mô tả mạch ở mức cổng logic |
| **Bitstream** | Luồng bit | File cấu hình nạp lên FPGA |
| **FPGA** | Mảng cổng lập trình | Field Programmable Gate Array |
| **ASIC** | Mạch tích hợp chuyên dụng | Application Specific Integrated Circuit |
| **Flip-Flop** | Mạch lật | Phần tử nhớ 1-bit |
| **Latch** | Chốt | Phần tử nhớ mức (thường không mong muốn) |
| **FSM** | Máy trạng thái | Finite State Machine |
| **Combinational** | Tổ hợp | Output chỉ phụ thuộc input hiện tại |
| **Sequential** | Tuần tự | Output phụ thuộc input + trạng thái trước |
| **Blocking** | Chặn | Gán tuần tự (=) |
| **Non-blocking** | Không chặn | Gán đồng thời (<=) |
| **Posedge** | Cạnh lên | Chuyển từ 0 → 1 |
| **Negedge** | Cạnh xuống | Chuyển từ 1 → 0 |
| **Metastability** | Bất ổn định | Trạng thái không xác định khi vi phạm setup/hold |
| **Glitch** | Xung nhiễu | Xung ngắn không mong muốn do delay |
| **Fanout** | Phân tán đầu ra | Số gate mà 1 output điều khiển |
| **Timing Closure** | Đóng timing | Đảm bảo setup/hold time thỏa mãn |

---

## 📚 Tổng kết tài liệu

| File | Nội dung | Link |
|------|----------|------|
| **README.md** | Tổng quan, cú pháp, kiểu dữ liệu, toán tử, module cơ bản | [→ README.md](README.md) |
| **index.md** | Mạch tổ hợp, mạch tuần tự, FSM, Memory, giao tiếp ngoại vi | [→ index.md](index.md) |
| **CLAUDE.md** | Testbench, mô phỏng, verification, synthesis, bài tập | [→ CLAUDE.md](CLAUDE.md) |

---

> 💡 **Lời khuyên**: Học Verilog hiệu quả nhất bằng cách **viết code → mô phỏng → xem waveform → debug → lặp lại**. Hãy bắt đầu với bài tập đơn giản và tăng độ phức tạp dần!

---

*Tài liệu được tổng hợp từ IEEE 1364-2001, "Verilog HDL" — Samir Palnitkar, "Digital Design and Computer Architecture" — Harris & Harris, và các nguồn tham khảo trực tuyến.*
