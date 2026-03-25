# 📘 Tài liệu Lập trình Verilog — Phần 1: Tổng quan & Cú pháp Cơ bản

> **Tài liệu tham khảo**: IEEE 1364-2001 (Verilog-2001), "Digital Design and Computer Architecture" — David Harris & Sarah Harris, "Verilog HDL" — Samir Palnitkar

---

## 📑 Mục lục

- [1. Giới thiệu về Verilog](#1-giới-thiệu-về-verilog)
- [2. Hệ thống số trong Verilog](#2-hệ-thống-số-trong-verilog)
- [3. Kiểu dữ liệu (Data Types)](#3-kiểu-dữ-liệu-data-types)
- [4. Toán tử (Operators)](#4-toán-tử-operators)
- [5. Cấu trúc Module](#5-cấu-trúc-module)
- [6. Mức độ mô tả trong Verilog](#6-mức-độ-mô-tả-trong-verilog)
- [7. Câu lệnh gán (Assignments)](#7-câu-lệnh-gán-assignments)
- [8. Cấu trúc điều khiển](#8-cấu-trúc-điều-khiển)
- [9. Tham số (Parameters)](#9-tham-số-parameters)
- [10. Các quy tắc đặt tên & Coding Style](#10-các-quy-tắc-đặt-tên--coding-style)

---

## 1. Giới thiệu về Verilog

### 1.1 Verilog là gì?

**Verilog** là một **ngôn ngữ mô tả phần cứng** (HDL — Hardware Description Language) được sử dụng để:

- **Mô tả** cấu trúc và hành vi của mạch số
- **Mô phỏng** (simulate) để kiểm tra logic trước khi chế tạo
- **Tổng hợp** (synthesize) thành mạch thực trên FPGA hoặc ASIC

### 1.2 Lịch sử phát triển

| Năm | Sự kiện |
|------|---------|
| 1984 | Phil Moorby tạo Verilog tại Gateway Design Automation |
| 1990 | Cadence mua Gateway, phổ biến Verilog |
| 1995 | IEEE 1364-1995 — Verilog trở thành chuẩn quốc tế |
| 2001 | IEEE 1364-2001 — Verilog-2001 (phiên bản phổ biến nhất) |
| 2005 | IEEE 1800-2005 — SystemVerilog ra đời |

### 1.3 Verilog vs VHDL

| Tiêu chí | Verilog | VHDL |
|-----------|---------|------|
| Cú pháp | Giống C, ngắn gọn | Giống Ada, dài dòng |
| Phổ biến | Mỹ, Châu Á | Châu Âu, quân sự |
| Học | Dễ bắt đầu hơn | Kiểm tra kiểu chặt hơn |
| Mô phỏng | Mạnh | Mạnh |
| Tổng hợp | Tốt | Tốt |

### 1.4 Quy trình thiết kế FPGA với Verilog

```
Đặc tả yêu cầu (Specification)
        ↓
Thiết kế kiến trúc (Architecture Design)
        ↓
Viết code Verilog (RTL Coding)
        ↓
Mô phỏng chức năng (Functional Simulation)
        ↓
Tổng hợp (Synthesis)
        ↓
Place & Route
        ↓
Mô phỏng thời gian (Timing Simulation)
        ↓
Nạp lên FPGA (Programming)
```

---

## 2. Hệ thống số trong Verilog

### 2.1 Cách biểu diễn số

Verilog sử dụng cú pháp: **`<size>'<base><value>`**

| Thành phần | Ý nghĩa | Ví dụ |
|------------|----------|-------|
| `size` | Số bit | `8` = 8-bit |
| `base` | Hệ cơ số | `b`, `o`, `d`, `h` |
| `value` | Giá trị | Các chữ số tương ứng |

### 2.2 Ví dụ cụ thể

```verilog
// Nhị phân (Binary) - tiền tố 'b
4'b1010        // 4-bit, giá trị = 10 (thập phân)
8'b1111_0000   // 8-bit, dấu _ để dễ đọc, giá trị = 240

// Thập lục phân (Hexadecimal) - tiền tố 'h
8'hFF          // 8-bit, giá trị = 255
16'hABCD       // 16-bit, giá trị = 43981

// Thập phân (Decimal) - tiền tố 'd
8'd255         // 8-bit, giá trị = 255
32'd100        // 32-bit, giá trị = 100

// Bát phân (Octal) - tiền tố 'o
8'o77          // 8-bit, giá trị = 63

// Không chỉ định kích thước (mặc định 32-bit)
100            // 32-bit, thập phân = 100
'hFF           // 32-bit, hex = 255
```

### 2.3 Giá trị đặc biệt

```verilog
// Các giá trị logic trong Verilog (4-value logic)
// 0 : Logic 0 (thấp)
// 1 : Logic 1 (cao)
// x : Không xác định (unknown) — chưa được gán hoặc xung đột
// z : Trở kháng cao (high impedance) — không kết nối

4'b10xz        // bit 3=1, bit 2=0, bit 1=x, bit 0=z
8'bxxxx_xxxx   // 8-bit tất cả không xác định
8'bzzzz_zzzz   // 8-bit tất cả trở kháng cao
```

### 2.4 Số âm

```verilog
-8'd5          // Số âm: biểu diễn bù 2 của -5 = 8'b1111_1011
-8'sd5         // Số âm có dấu (signed)
```

---

## 3. Kiểu dữ liệu (Data Types)

### 3.1 Wire — Dây nối

`wire` đại diện cho **kết nối vật lý** giữa các phần tử mạch. Nó không lưu trữ giá trị, mà chỉ **truyền tín hiệu**.

```verilog
wire        a;           // 1-bit wire
wire [7:0]  data_bus;    // 8-bit bus (bit 7 là MSB, bit 0 là LSB)
wire [0:7]  data_bus2;   // 8-bit bus (bit 0 là MSB) — ít dùng
wire [31:0] address;     // 32-bit address bus
```

**Đặc điểm:**
- Phải được **điều khiển liên tục** (driven continuously)
- Dùng với lệnh `assign` hoặc kết nối cổng
- Giá trị mặc định: `z` (high impedance)

### 3.2 Reg — Thanh ghi

`reg` đại diện cho **phần tử lưu trữ** giá trị. Giữ giá trị cho đến khi được gán giá trị mới.

```verilog
reg         q;           // 1-bit register
reg [7:0]   counter;     // 8-bit register
reg [15:0]  data;        // 16-bit register
reg         flag = 1'b0; // Khởi tạo giá trị (chỉ cho mô phỏng)
```

**Đặc điểm:**
- Dùng trong khối `always`, `initial`
- Giá trị mặc định: `x` (unknown)
- **Lưu ý**: `reg` không phải lúc nào cũng tạo ra flip-flop! Tùy thuộc vào cách viết code

### 3.3 Integer, Real, Time

```verilog
integer  i;         // 32-bit có dấu, dùng cho vòng lặp
real     voltage;   // Số thực dấu phẩy động
time     sim_time;  // 64-bit, lưu thời gian mô phỏng

initial begin
    i = -5;                 // integer có thể âm
    voltage = 3.3;          // giá trị thực
    sim_time = $time;       // thời gian mô phỏng hiện tại
end
```

### 3.4 Mảng và Memory

```verilog
// Mảng 1 chiều
reg [7:0] mem [0:255];       // 256 ô nhớ, mỗi ô 8-bit (ROM/RAM)
reg [7:0] rom [0:1023];      // 1024 ô nhớ, mỗi ô 8-bit

// Truy cập mảng
mem[0]  = 8'hAB;             // Ghi giá trị vào ô nhớ 0
data    = mem[10];           // Đọc ô nhớ 10

// Mảng reg
reg [3:0] array [0:15];     // 16 phần tử, mỗi phần tử 4-bit

// Vector vs Array
wire [7:0] bus;              // Vector: 8-bit bus (1 phần tử)
reg  [7:0] memory [0:63];   // Array: 64 phần tử, mỗi cái 8-bit
```

### 3.5 Wire vs Reg — Khi nào dùng cái nào?

| Tiêu chí | `wire` | `reg` |
|-----------|--------|-------|
| Dùng trong | `assign`, kết nối module | `always`, `initial` |
| Lưu giá trị | Không | Có |
| Mô tả | Dây nối vật lý | Phần tử lưu trữ logic |
| Mặc định | `z` | `x` |
| Output port | Dùng được | Dùng được |
| Input port | Dùng được | ❌ Không dùng |

```verilog
// Ví dụ minh họa
module example(
    input  wire clk,         // input luôn là wire
    input  wire rst,
    output wire led,         // output dạng wire
    output reg  [7:0] count  // output dạng reg
);

    // wire dùng với assign
    assign led = (count == 8'd0);

    // reg dùng trong always
    always @(posedge clk) begin
        if (rst)
            count <= 8'd0;
        else
            count <= count + 1;
    end

endmodule
```

---

## 4. Toán tử (Operators)

### 4.1 Toán tử số học (Arithmetic)

```verilog
a + b       // Cộng
a - b       // Trừ
a * b       // Nhân
a / b       // Chia (lấy phần nguyên)
a % b       // Chia lấy dư (modulo)
a ** b      // Lũy thừa (Verilog-2001)
```

### 4.2 Toán tử logic (Logical)

```verilog
a && b      // AND logic — kết quả: 1-bit (0 hoặc 1)
a || b      // OR logic
!a          // NOT logic

// Ví dụ:
// 4'b1010 && 4'b0001 => 1'b1 (cả hai khác 0)
// !4'b0000            => 1'b1 (vì 0000 = false)
```

### 4.3 Toán tử bitwise (Theo bit)

```verilog
a & b       // AND từng bit
a | b       // OR từng bit
a ^ b       // XOR từng bit
~a          // NOT từng bit (đảo bit)
a ~^ b      // XNOR từng bit

// Ví dụ:
// 4'b1010 & 4'b1100 => 4'b1000
// 4'b1010 | 4'b1100 => 4'b1110
// 4'b1010 ^ 4'b1100 => 4'b0110
// ~4'b1010           => 4'b0101
```

### 4.4 Toán tử dịch bit (Shift)

```verilog
a << n      // Dịch trái n bit (chèn 0)
a >> n      // Dịch phải n bit (chèn 0)
a <<< n     // Dịch trái số học
a >>> n     // Dịch phải số học (giữ bit dấu)

// Ví dụ:
// 8'b1010_0011 << 2  => 8'b1000_1100
// 8'b1010_0011 >> 2  => 8'b0010_1000
```

### 4.5 Toán tử so sánh (Relational)

```verilog
a == b      // Bằng (có thể trả về x nếu có bit x/z)
a != b      // Khác
a === b     // Bằng chính xác (so sánh cả x, z)
a !== b     // Khác chính xác
a > b       // Lớn hơn
a < b       // Nhỏ hơn
a >= b      // Lớn hơn hoặc bằng
a <= b      // Nhỏ hơn hoặc bằng
```

> ⚠️ **Lưu ý**: `==` và `!=` có thể trả về `x` khi so sánh với tín hiệu chứa `x` hoặc `z`. Dùng `===` và `!==` khi cần so sánh chính xác (chỉ trong testbench, **không tổng hợp được**).

### 4.6 Toán tử nối và lặp (Concatenation & Replication)

```verilog
// Nối (Concatenation) — dùng dấu {}
{a, b}          // Nối a và b lại
{4'b1010, 4'b0011}  // => 8'b1010_0011

// Lặp (Replication) — dùng {n{...}}
{4{1'b1}}       // => 4'b1111 (lặp 1 bốn lần)
{2{4'b1010}}    // => 8'b1010_1010
{8{1'b0}}       // => 8'b0000_0000

// Ứng dụng: Mở rộng dấu (Sign Extension)
wire [7:0] a = 4'b1010;
wire [15:0] sign_ext = {{8{a[7]}}, a};  // Mở rộng bit dấu MSB
```

### 4.7 Toán tử rút gọn (Reduction)

```verilog
&a          // AND tất cả bit: a[n]&a[n-1]&...&a[0]
|a          // OR tất cả bit
^a          // XOR tất cả bit (kiểm tra chẵn lẻ - parity)
~&a         // NAND tất cả bit
~|a         // NOR tất cả bit
~^a         // XNOR tất cả bit

// Ví dụ:
// &4'b1111  => 1'b1 (tất cả là 1)
// &4'b1010  => 1'b0 (có bit 0)
// |4'b0001  => 1'b1 (có ít nhất 1 bit = 1)
// ^4'b1010  => 1'b0 (số bit 1 chẵn)
```

### 4.8 Toán tử điều kiện (Conditional / Ternary)

```verilog
// Cú pháp: condition ? value_if_true : value_if_false
assign y = (sel) ? a : b;      // MUX 2:1

// Có thể lồng nhau:
assign y = (sel[1]) ? (sel[0] ? d : c)
                    : (sel[0] ? b : a);  // MUX 4:1
```

### 4.9 Bảng ưu tiên toán tử (từ cao đến thấp)

| Ưu tiên | Toán tử | Mô tả |
|----------|---------|-------|
| 1 (cao nhất) | `!` `~` `+` `-` (unary) | Đơn ngôi |
| 2 | `**` | Lũy thừa |
| 3 | `*` `/` `%` | Nhân, chia |
| 4 | `+` `-` | Cộng, trừ |
| 5 | `<<` `>>` `<<<` `>>>` | Dịch bit |
| 6 | `<` `<=` `>` `>=` | So sánh |
| 7 | `==` `!=` `===` `!==` | Bằng / khác |
| 8 | `&` | Bitwise AND |
| 9 | `^` `~^` | Bitwise XOR |
| 10 | `\|` | Bitwise OR |
| 11 | `&&` | Logic AND |
| 12 | `\|\|` | Logic OR |
| 13 (thấp nhất) | `?:` | Điều kiện |

> 💡 **Khuyến nghị**: Luôn dùng **dấu ngoặc `()`** để code rõ ràng hơn, tránh lỗi ưu tiên.

---

## 5. Cấu trúc Module

### 5.1 Module là gì?

**Module** là đơn vị thiết kế cơ bản trong Verilog — tương tự như một con chip hoặc linh kiện. Mỗi module có:
- **Tên** (name)
- **Cổng vào/ra** (ports)
- **Nội dung** (logic bên trong)

### 5.2 Cú pháp cơ bản

```verilog
// ============================================
// Cú pháp Verilog-2001 (KHUYẾN NGHỊ)
// ============================================
module module_name (
    input  wire       clk,         // Xung nhịp
    input  wire       rst_n,       // Reset tích cực thấp
    input  wire [7:0] data_in,     // Dữ liệu vào 8-bit
    output wire       valid,       // Tín hiệu hợp lệ
    output reg  [7:0] data_out     // Dữ liệu ra 8-bit
);

    // Khai báo nội bộ
    wire [7:0] internal_signal;
    reg  [3:0] state;

    // Logic mạch
    assign valid = (state != 4'd0);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            data_out <= 8'd0;
        else
            data_out <= data_in;
    end

endmodule
```

```verilog
// ============================================
// Cú pháp Verilog-95 (cũ, tham khảo)
// ============================================
module module_name(clk, rst_n, data_in, data_out);
    input        clk;
    input        rst_n;
    input  [7:0] data_in;
    output [7:0] data_out;
    reg    [7:0] data_out;

    // ... logic ...
endmodule
```

### 5.3 Các loại Port

| Loại | Ý nghĩa | Kiểu mặc định |
|------|----------|---------------|
| `input` | Tín hiệu vào | `wire` |
| `output` | Tín hiệu ra | `wire` (có thể khai báo `reg`) |
| `inout` | Hai chiều (bidirectional) | `wire` |

```verilog
// Ví dụ port inout (bus hai chiều)
module bidirectional(
    input  wire       dir,       // 1 = output, 0 = input
    inout  wire [7:0] data_bus   // Bus hai chiều
);
    
    reg [7:0] data_out;
    
    // Điều khiển bus: khi dir=1 thì xuất data, ngược lại thả nổi (hi-z)
    assign data_bus = (dir) ? data_out : 8'bz;
    
    // Đọc dữ liệu từ bus
    wire [7:0] data_in = data_bus;

endmodule
```

### 5.4 Kết nối Module (Instantiation)

```verilog
module top_module(
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] a,
    input  wire [7:0] b,
    output wire [8:0] sum
);

    // === Cách 1: Kết nối theo tên (KHUYẾN NGHỊ) ===
    adder u_adder (
        .clk    (clk),
        .rst    (rst),
        .a      (a),
        .b      (b),
        .sum    (sum)
    );

    // === Cách 2: Kết nối theo vị trí (KHÔNG khuyến khích) ===
    // adder u_adder2 (clk, rst, a, b, sum);

endmodule

module adder(
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] a,
    input  wire [7:0] b,
    output reg  [8:0] sum
);
    always @(posedge clk) begin
        if (rst)
            sum <= 9'd0;
        else
            sum <= a + b;
    end
endmodule
```

---

## 6. Mức độ mô tả trong Verilog

Verilog cho phép mô tả mạch ở **nhiều mức trừu tượng** khác nhau:

### 6.1 Mức cổng (Gate Level)

Mô tả bằng các cổng logic cơ bản — gần với phần cứng nhất.

```verilog
module gate_level_and(
    input  wire a,
    input  wire b,
    output wire y
);
    // Sử dụng cổng AND có sẵn
    and u1 (y, a, b);
endmodule

// Các cổng có sẵn trong Verilog:
// and, or, not, nand, nor, xor, xnor
// buf, bufif0, bufif1, notif0, notif1
```

```verilog
// Ví dụ: Full Adder mức cổng
module full_adder_gate(
    input  wire a, b, cin,
    output wire sum, cout
);
    wire w1, w2, w3;
    
    xor  g1 (w1, a, b);
    xor  g2 (sum, w1, cin);
    and  g3 (w2, w1, cin);
    and  g4 (w3, a, b);
    or   g5 (cout, w2, w3);
endmodule
```

### 6.2 Mức luồng dữ liệu (Dataflow Level)

Mô tả mạch bằng biểu thức và phép gán liên tục.

```verilog
module full_adder_dataflow(
    input  wire a, b, cin,
    output wire sum, cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule
```

### 6.3 Mức hành vi (Behavioral Level)

Mô tả mạch bằng thuật toán — trừu tượng nhất, gần với phần mềm nhất.

```verilog
module full_adder_behavioral(
    input  wire a, b, cin,
    output reg  sum, cout
);
    always @(*) begin
        {cout, sum} = a + b + cin;
    end
endmodule
```

### 6.4 So sánh các mức mô tả

| Mức | Trừu tượng | Tốc độ viết | Kiểm soát | Dùng khi |
|-----|-----------|-------------|-----------|----------|
| Gate | Thấp | Chậm | Cao nhất | Mạch nhỏ, tối ưu |
| Dataflow | Trung bình | Vừa | Trung bình | Mạch tổ hợp |
| Behavioral | Cao | Nhanh | Ít nhất | Mạch phức tạp, FSM |

> 💡 **Thực tế**: Phần lớn code Verilog hiện đại sử dụng **Behavioral** kết hợp **Dataflow**.

---

## 7. Câu lệnh gán (Assignments)

### 7.1 Gán liên tục (Continuous Assignment) — `assign`

```verilog
// Dùng cho wire — mạch tổ hợp
// Giá trị bên phải thay đổi → bên trái cập nhật ngay

assign y = a & b;                    // AND gate
assign bus = enable ? data : 8'bz;   // Tri-state buffer
assign {cout, sum} = a + b + cin;    // Full adder
```

### 7.2 Gán chặn (Blocking Assignment) — `=`

```verilog
// Dùng trong always block
// Thực thi TUẦN TỰ — lệnh sau chờ lệnh trước hoàn thành
// Dùng cho MẠCH TỔ HỢP

always @(*) begin
    temp = a & b;        // Thực hiện trước
    y    = temp | c;     // Thực hiện sau, dùng kết quả temp mới
end
```

### 7.3 Gán không chặn (Non-blocking Assignment) — `<=`

```verilog
// Dùng trong always block
// Thực thi ĐỒNG THỜI — tất cả lệnh đánh giá cùng lúc
// Dùng cho MẠCH TUẦN TỰ (flip-flop, register)

always @(posedge clk) begin
    q1 <= d;        // Tất cả đánh giá tại cùng thời điểm
    q2 <= q1;       // q2 nhận giá trị CŨ của q1 (trước khi cập nhật)
    q3 <= q2;       // Tạo thanh ghi dịch (shift register)
end
```

### 7.4 ⚠️ Quy tắc vàng về Assignment

| Quy tắc | Giải thích |
|----------|-----------|
| `assign` + `wire` | Gán liên tục cho mạch tổ hợp |
| `=` trong `always @(*)` | Blocking cho mạch tổ hợp |
| `<=` trong `always @(posedge clk)` | Non-blocking cho mạch tuần tự |
| ❌ Không trộn `=` và `<=` | Trong cùng 1 always block |
| ❌ Không gán wire trong always | Wire chỉ dùng `assign` |
| ❌ Không gán reg bằng assign | Reg chỉ dùng trong `always` |

---

## 8. Cấu trúc điều khiển

### 8.1 if-else

```verilog
// Mạch tổ hợp — dùng blocking (=)
always @(*) begin
    if (sel == 2'b00)
        y = a;
    else if (sel == 2'b01)
        y = b;
    else if (sel == 2'b10)
        y = c;
    else
        y = d;
end

// Mạch tuần tự — dùng non-blocking (<=)
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        count <= 8'd0;          // Reset
    else if (enable)
        count <= count + 1;     // Đếm khi enable = 1
    else
        count <= count;         // Giữ nguyên (có thể bỏ)
end
```

> ⚠️ **Lưu ý**: Trong mạch tổ hợp, **PHẢI** có nhánh `else` cuối cùng, nếu không sẽ tạo ra **latch** (không mong muốn).

### 8.2 case

```verilog
// MUX 4:1 bằng case
always @(*) begin
    case (sel)
        2'b00:   y = a;
        2'b01:   y = b;
        2'b10:   y = c;
        2'b11:   y = d;
        default: y = 4'b0;    // BẮT BUỘC — tránh tạo latch
    endcase
end

// casez — dùng z (?) làm don't care
always @(*) begin
    casez (opcode)
        4'b1???:  alu_op = 3'd0;   // Nếu bit 3 = 1
        4'b01??:  alu_op = 3'd1;   // Nếu bit 3:2 = 01
        4'b001?:  alu_op = 3'd2;
        4'b0001:  alu_op = 3'd3;
        default:  alu_op = 3'd7;
    endcase
end

// casex — dùng x và z làm don't care (ít dùng trong synthesis)
```

### 8.3 Vòng lặp (Loops)

```verilog
// for — Dùng để generate hoặc trong testbench
integer i;
always @(*) begin
    result = 0;
    for (i = 0; i < 8; i = i + 1) begin
        result = result + data[i];
    end
end

// while — Chủ yếu dùng trong testbench
initial begin
    i = 0;
    while (i < 10) begin
        #10 data = i;
        i = i + 1;
    end
end

// repeat — Lặp n lần
initial begin
    repeat (5) begin
        #10 clk = ~clk;
    end
end

// forever — Lặp vô hạn (tạo clock)
initial begin
    clk = 0;
    forever #5 clk = ~clk;   // Clock chu kỳ 10 đơn vị
end
```

---

## 9. Tham số (Parameters)

### 9.1 Parameter — Hằng số module

```verilog
module counter #(
    parameter WIDTH = 8,           // Độ rộng bộ đếm, mặc định 8-bit
    parameter MAX_COUNT = 255      // Giá trị đếm tối đa
)(
    input  wire             clk,
    input  wire             rst,
    output reg [WIDTH-1:0]  count
);

    always @(posedge clk) begin
        if (rst)
            count <= {WIDTH{1'b0}};
        else if (count == MAX_COUNT)
            count <= {WIDTH{1'b0}};
        else
            count <= count + 1;
    end

endmodule

// Sử dụng với tham số khác nhau
counter #(.WIDTH(16), .MAX_COUNT(1000)) u_counter16 (
    .clk   (clk),
    .rst   (rst),
    .count (count_16bit)
);

counter #(.WIDTH(4), .MAX_COUNT(9)) u_bcd_counter (
    .clk   (clk),
    .rst   (rst),
    .count (bcd_count)
);
```

### 9.2 Localparam — Hằng số cục bộ

```verilog
module fsm(
    input wire clk, rst,
    // ...
);
    // localparam KHÔNG THỂ bị ghi đè từ bên ngoài
    localparam IDLE  = 3'd0;
    localparam START = 3'd1;
    localparam RUN   = 3'd2;
    localparam STOP  = 3'd3;
    localparam DONE  = 3'd4;

    reg [2:0] state;
    // ...
endmodule
```

### 9.3 Generate — Tạo mạch lặp

```verilog
module ripple_carry_adder #(
    parameter N = 8
)(
    input  wire [N-1:0] a, b,
    input  wire         cin,
    output wire [N-1:0] sum,
    output wire         cout
);

    wire [N:0] carry;
    assign carry[0] = cin;
    assign cout = carry[N];

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_adder
            full_adder fa (
                .a    (a[i]),
                .b    (b[i]),
                .cin  (carry[i]),
                .sum  (sum[i]),
                .cout (carry[i+1])
            );
        end
    endgenerate

endmodule
```

---

## 10. Các quy tắc đặt tên & Coding Style

### 10.1 Quy tắc đặt tên

```verilog
// ✅ Nên:
module uart_transmitter      // snake_case, mô tả rõ ràng
wire        clk              // Tín hiệu clock
wire        rst_n            // Reset tích cực thấp (hậu tố _n)
wire        data_valid       // Tín hiệu valid
reg  [7:0]  byte_counter     // Bộ đếm byte
wire        tx_busy          // Trạng thái bận
parameter   BAUD_RATE = 9600 // Hằng số viết HOA

// ❌ Không nên:
module m1                    // Tên vô nghĩa
wire a, b, c                 // Quá ngắn
reg xyz123                   // Không mô tả
```

### 10.2 Coding Style chuẩn

```verilog
// ✅ Best Practices:

// 1. Mỗi module = 1 file, tên file = tên module
//    uart_tx.v chứa module uart_tx

// 2. Reset đồng bộ hoặc bất đồng bộ — chọn 1 và nhất quán
always @(posedge clk or negedge rst_n) begin  // Bất đồng bộ
    if (!rst_n)
        // reset logic
    else
        // normal logic
end

// 3. Luôn dùng begin-end cho khối nhiều lệnh
always @(posedge clk) begin
    if (condition) begin
        a <= 1;
        b <= 0;
    end
end

// 4. Không dùng "magic number" — dùng parameter/localparam
localparam ADDR_WIDTH = 8;
reg [ADDR_WIDTH-1:0] address;

// 5. Comment đầy đủ
// Bộ đếm BCD 0-9, reset khi đạt 9
always @(posedge clk) begin
    if (rst)
        bcd <= 4'd0;
    else if (bcd == 4'd9)
        bcd <= 4'd0;
    else
        bcd <= bcd + 1;
end
```

### 10.3 Cấu trúc file Verilog điển hình

```verilog
//============================================================
// File       : module_name.v
// Author     : Your Name
// Date       : 2026-03-25
// Description: Mô tả ngắn về module
//============================================================

`timescale 1ns / 1ps    // Đơn vị thời gian / độ chính xác

module module_name #(
    // Parameters
    parameter DATA_WIDTH = 8
)(
    // Clock & Reset
    input  wire                   clk,
    input  wire                   rst_n,
    
    // Input ports
    input  wire [DATA_WIDTH-1:0]  data_in,
    input  wire                   valid_in,
    
    // Output ports
    output reg  [DATA_WIDTH-1:0]  data_out,
    output reg                    valid_out
);

    //========================================
    // Internal signals
    //========================================
    wire [DATA_WIDTH-1:0] processed_data;
    reg  [3:0]            state;
    
    //========================================
    // Combinational logic
    //========================================
    assign processed_data = data_in + 1;
    
    //========================================
    // Sequential logic
    //========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out  <= {DATA_WIDTH{1'b0}};
            valid_out <= 1'b0;
        end else begin
            data_out  <= processed_data;
            valid_out <= valid_in;
        end
    end

endmodule
```

---

## 📚 Tài liệu tham khảo

| Tài liệu | Tác giả | Ghi chú |
|-----------|---------|---------|
| *Verilog HDL: A Guide to Digital Design and Synthesis* | Samir Palnitkar | Sách kinh điển |
| *Digital Design and Computer Architecture* | Harris & Harris | Tốt cho người mới |
| *Advanced Digital Design with the Verilog HDL* | Michael D. Ciletti | Nâng cao |
| *IEEE Std 1364-2001* | IEEE | Chuẩn chính thức |
| [HDLBits](https://hdlbits.01xz.net/) | — | Luyện tập online |
| [ASIC World - Verilog](https://www.asic-world.com/verilog/) | — | Tutorial miễn phí |

---

> **Tiếp theo**: Xem [index.md](index.md) — Thiết kế mạch số với Verilog (Module thực tế, Mạch tổ hợp, Mạch tuần tự, FSM)
