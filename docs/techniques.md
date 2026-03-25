# 📕 Kỹ thuật Lập trình Verilog Nâng cao

> **Các phần khác**: [README.md](README.md) — Cú pháp cơ bản | [index.md](index.md) — Mạch số | [CLAUDE.md](CLAUDE.md) — Testbench | [DE10-Lite](DE10_Lite.md) — Board thực hành

---

## 📑 Mục lục

- [1. Phong cách mô tả hành vi (Behavioral Modeling)](#1-phong-cách-mô-tả-hành-vi-behavioral-modeling)
- [2. Phong cách mô tả cấu trúc (Structural Modeling)](#2-phong-cách-mô-tả-cấu-trúc-structural-modeling)
- [3. Kỹ thuật FSM nâng cao](#3-kỹ-thuật-fsm-nâng-cao)
- [4. Kỹ thuật FIFO](#4-kỹ-thuật-fifo)
- [5. Pipeline (Đường ống)](#5-pipeline-đường-ống)
- [6. Handshake Protocol (Giao thức bắt tay)](#6-handshake-protocol-giao-thức-bắt-tay)
- [7. Clock Domain Crossing (CDC)](#7-clock-domain-crossing-cdc)
- [8. Parameterized Design (Thiết kế tham số hóa)](#8-parameterized-design-thiết-kế-tham-số-hóa)
- [9. Kỹ thuật Reset](#9-kỹ-thuật-reset)
- [10. Mẫu thiết kế thường dùng (Design Patterns)](#10-mẫu-thiết-kế-thường-dùng-design-patterns)
- [11. Tối ưu hiệu năng & Tài nguyên](#11-tối-ưu-hiệu-năng--tài-nguyên)
- [12. Coding Guidelines cho dự án thực tế](#12-coding-guidelines-cho-dự-án-thực-tế)

---

## 1. Phong cách mô tả hành vi (Behavioral Modeling)

### 1.1 Behavioral là gì?

**Behavioral modeling** mô tả **hành vi** (thuật toán) của mạch mà **không quan tâm đến cấu trúc phần cứng** cụ thể. Đây là mức trừu tượng cao nhất trong Verilog.

```
Behavioral (cao nhất)  →  "Mạch làm gì?"
    ↓
Dataflow (trung bình)  →  "Dữ liệu truyền như thế nào?"
    ↓
Structural (thấp nhất) →  "Mạch gồm những gì, nối ra sao?"
```

### 1.2 Khối `always` — Trái tim của Behavioral

```verilog
// =============================================
// Mạch TỔ HỢP — always @(*)
// =============================================
// Quy tắc:
//   - Dùng blocking assignment (=)
//   - Sensitivity list: @(*) hoặc @(a, b, sel)
//   - PHẢI gán giá trị mặc định → tránh latch
//   - Output tái tính khi BẤT KỲ input nào thay đổi

always @(*) begin
    // Giá trị mặc định — QUAN TRỌNG
    result = 8'd0;
    flags  = 4'd0;
    
    case (opcode)
        4'b0000: result = a + b;
        4'b0001: result = a - b;
        4'b0010: result = a & b;
        4'b0011: result = a | b;
        default: result = 8'd0;
    endcase
    
    flags[0] = (result == 0);        // Zero flag
    flags[1] = result[7];            // Negative flag
end

// =============================================
// Mạch TUẦN TỰ — always @(posedge clk)
// =============================================
// Quy tắc:
//   - Dùng non-blocking assignment (<=)
//   - Sensitivity: @(posedge clk) hoặc @(posedge clk or negedge rst_n)
//   - Tạo ra Flip-Flop
//   - Output cập nhật tại cạnh clock

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state   <= IDLE;
        counter <= 0;
    end else begin
        state   <= next_state;
        counter <= counter + 1;
    end
end
```

### 1.3 Behavioral nâng cao: Mô tả thuật toán phức tạp

```verilog
// =============================================
// Ví dụ: Tìm bit 1 đầu tiên (Find First Set)
// =============================================
module find_first_set #(
    parameter WIDTH = 16
)(
    input  wire [WIDTH-1:0]       data_in,
    output reg  [$clog2(WIDTH)-1:0] position,
    output reg                      found
);
    integer i;
    
    always @(*) begin
        found    = 1'b0;
        position = 0;
        
        // Tìm bit 1 từ LSB → MSB
        for (i = 0; i < WIDTH; i = i + 1) begin
            if (data_in[i] && !found) begin
                position = i;
                found    = 1'b1;
            end
        end
    end
endmodule

// =============================================
// Ví dụ: Đếm số bit 1 (Population Count)
// =============================================
module popcount #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0]       data_in,
    output reg  [$clog2(WIDTH):0] count
);
    integer i;
    
    always @(*) begin
        count = 0;
        for (i = 0; i < WIDTH; i = i + 1) begin
            count = count + data_in[i];
        end
    end
endmodule

// =============================================
// Ví dụ: Barrel Shifter (Dịch bit nhanh)
// =============================================
module barrel_shifter #(
    parameter WIDTH = 8,
    parameter SHIFT_WIDTH = $clog2(WIDTH)
)(
    input  wire [WIDTH-1:0]       data_in,
    input  wire [SHIFT_WIDTH-1:0] shift_amt,
    input  wire                   direction,   // 0=left, 1=right
    input  wire                   arithmetic,  // 1=giữ bit dấu khi dịch phải
    output reg  [WIDTH-1:0]       data_out
);
    always @(*) begin
        if (direction == 1'b0)
            data_out = data_in << shift_amt;
        else if (arithmetic)
            data_out = $signed(data_in) >>> shift_amt;
        else
            data_out = data_in >> shift_amt;
    end
endmodule
```

### 1.4 Initial block — Chỉ dùng trong Testbench

```verilog
// initial chỉ chạy 1 lần tại thời điểm t=0
// KHÔNG tổng hợp được — chỉ dùng trong mô phỏng

initial begin
    clk = 0;
    rst = 1;
    data = 8'h00;
    
    #100 rst = 0;           // Thả reset sau 100ns
    #50  data = 8'hFF;      // Gán data sau 150ns
    
    #1000 $finish;           // Kết thúc mô phỏng
end

// Ngoại lệ: initial trong MAX 10 FPGA có thể dùng
// để khởi tạo bộ nhớ (memory initialization)
// Nhưng KHÔNG nên dùng cho logic thông thường
```

---

## 2. Phong cách mô tả cấu trúc (Structural Modeling)

### 2.1 Structural là gì?

Mô tả mạch bằng cách **nối các module con** lại với nhau, giống như lắp mạch trên breadboard.

### 2.2 Kết nối Module — Chi tiết

```verilog
// =============================================
// Cách kết nối module con
// =============================================
module top_level(
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] a, b,
    output wire [7:0] result,
    output wire       overflow
);

    // Wire nội bộ để kết nối giữa các module
    wire [8:0]  add_result;
    wire        add_carry;
    wire [7:0]  reg_out;
    
    // ---- Cách 1: Kết nối theo TÊN (KHUYẾN NGHỊ) ----
    adder_8bit u_adder (
        .a      (a),              // Port .a của module ← tín hiệu a
        .b      (b),              // Port .b ← tín hiệu b
        .cin    (1'b0),           // Có thể gán hằng số
        .sum    (add_result[7:0]),// Có thể gán từng bit
        .cout   (add_carry)
    );
    
    // ---- Cách 2: Kết nối theo VỊ TRÍ (KHÔNG khuyến khích) ----
    // adder_8bit u_adder2 (a, b, 1'b0, add_result[7:0], add_carry);
    
    // ---- Cách 3: Bỏ qua port không dùng ----
    adder_8bit u_adder3 (
        .a      (a),
        .b      (b),
        .cin    (1'b0),
        .sum    (result),
        .cout   ()               // Để trống → không kết nối
    );
    
    // ---- Cách 4: Dùng parameter ----
    register #(
        .WIDTH  (8)              // Override parameter
    ) u_reg (
        .clk    (clk),
        .rst_n  (rst_n),
        .load   (1'b1),
        .d      (add_result[7:0]),
        .q      (reg_out)
    );
    
    assign result   = reg_out;
    assign overflow = add_carry;

endmodule
```

### 2.3 Generate — Tạo mạch lặp tự động

```verilog
// =============================================
// Generate for — Tạo chuỗi module
// =============================================
module parallel_adders #(
    parameter N_ADDERS = 4,
    parameter WIDTH    = 8
)(
    input  wire [WIDTH*N_ADDERS-1:0] a_bus,
    input  wire [WIDTH*N_ADDERS-1:0] b_bus,
    output wire [WIDTH*N_ADDERS-1:0] sum_bus
);
    genvar i;
    generate
        for (i = 0; i < N_ADDERS; i = i + 1) begin : gen_adders
            // Tên block (gen_adders) BẮT BUỘC trong generate
            adder_8bit u_add (
                .a    (a_bus[WIDTH*(i+1)-1 : WIDTH*i]),
                .b    (b_bus[WIDTH*(i+1)-1 : WIDTH*i]),
                .cin  (1'b0),
                .sum  (sum_bus[WIDTH*(i+1)-1 : WIDTH*i]),
                .cout ()
            );
        end
    endgenerate
endmodule

// =============================================
// Generate if — Chọn cấu trúc theo điều kiện
// =============================================
module configurable_adder #(
    parameter WIDTH  = 8,
    parameter USE_CLA = 1    // 1 = Carry Look-Ahead, 0 = Ripple Carry
)(
    input  wire [WIDTH-1:0] a, b,
    input  wire             cin,
    output wire [WIDTH-1:0] sum,
    output wire             cout
);
    generate
        if (USE_CLA) begin : gen_cla
            cla_adder #(.WIDTH(WIDTH)) u_adder (
                .a(a), .b(b), .cin(cin), .sum(sum), .cout(cout)
            );
        end else begin : gen_rca
            ripple_carry_adder #(.N(WIDTH)) u_adder (
                .a(a), .b(b), .cin(cin), .sum(sum), .cout(cout)
            );
        end
    endgenerate
endmodule

// =============================================
// Generate case — Chọn theo giá trị parameter
// =============================================
module multiplier #(
    parameter WIDTH = 8,
    parameter IMPL  = 0    // 0=behavioral, 1=booth, 2=wallace_tree
)(
    input  wire [WIDTH-1:0]   a, b,
    output wire [2*WIDTH-1:0] product
);
    generate
        case (IMPL)
            0: begin : gen_behavioral
                assign product = a * b;
            end
            1: begin : gen_booth
                booth_multiplier #(.WIDTH(WIDTH)) u_mult (
                    .a(a), .b(b), .product(product)
                );
            end
            2: begin : gen_wallace
                wallace_tree_multiplier #(.WIDTH(WIDTH)) u_mult (
                    .a(a), .b(b), .product(product)
                );
            end
        endcase
    endgenerate
endmodule
```

---

## 3. Kỹ thuật FSM nâng cao

### 3.1 Mã hóa trạng thái (State Encoding)

```verilog
// =============================================
// Binary Encoding — Ít flip-flop, nhiều logic giải mã
// =============================================
localparam S_IDLE    = 3'b000;
localparam S_START   = 3'b001;
localparam S_DATA    = 3'b010;
localparam S_PARITY  = 3'b011;
localparam S_STOP    = 3'b100;
reg [2:0] state;   // 3 bit cho 5 trạng thái

// =============================================
// One-Hot Encoding — Nhiều flip-flop, ít logic giải mã → NHANH hơn
// Khuyến nghị cho FPGA vì FPGA có nhiều flip-flop
// =============================================
localparam S_IDLE    = 5'b00001;
localparam S_START   = 5'b00010;
localparam S_DATA    = 5'b00100;
localparam S_PARITY  = 5'b01000;
localparam S_STOP    = 5'b10000;
reg [4:0] state;   // 5 bit, mỗi trạng thái 1 bit

// =============================================
// Gray Encoding — Chỉ 1 bit thay đổi giữa 2 trạng thái liên tiếp
// Giảm glitch, ít nhiễu
// =============================================
localparam S_IDLE    = 3'b000;
localparam S_START   = 3'b001;
localparam S_DATA    = 3'b011;
localparam S_PARITY  = 3'b010;
localparam S_STOP    = 3'b110;
```

| Encoding | Flip-Flops | Combo Logic | Tốc độ | Dùng khi |
|----------|-----------|-------------|--------|----------|
| Binary | Ít nhất ($clog2(N)$) | Nhiều | Trung bình | ASIC, ít trạng thái |
| One-Hot | Nhiều nhất (N) | Ít | Nhanh nhất | FPGA (khuyến nghị) |
| Gray | $clog2(N)$ | Trung bình | Tốt | CDC, ít glitch |

### 3.2 FSM Pattern: Moore 3-Block (Best Practice)

```verilog
module uart_fsm(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx,
    input  wire       baud_tick,
    output reg  [7:0] rx_data,
    output reg        rx_valid
);

    // ══════════ BLOCK 1: State Declaration ══════════
    localparam [2:0]
        S_IDLE    = 3'd0,
        S_START   = 3'd1,
        S_DATA    = 3'd2,
        S_PARITY  = 3'd3,
        S_STOP    = 3'd4;

    reg [2:0] state, next_state;
    reg [2:0] bit_cnt, next_bit_cnt;
    reg [7:0] shift_reg, next_shift_reg;

    // ══════════ BLOCK 2: State Register (Sequential) ══════════
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= S_IDLE;
            bit_cnt   <= 3'd0;
            shift_reg <= 8'd0;
        end else begin
            state     <= next_state;
            bit_cnt   <= next_bit_cnt;
            shift_reg <= next_shift_reg;
        end
    end

    // ══════════ BLOCK 3a: Next State Logic (Combinational) ══════════
    always @(*) begin
        // Mặc định: giữ nguyên
        next_state     = state;
        next_bit_cnt   = bit_cnt;
        next_shift_reg = shift_reg;

        case (state)
            S_IDLE: begin
                if (rx == 1'b0)              // Phát hiện start bit
                    next_state = S_START;
            end

            S_START: begin
                if (baud_tick) begin
                    if (rx == 1'b0)          // Xác nhận start bit
                        next_state = S_DATA;
                    else
                        next_state = S_IDLE;  // False start
                end
            end

            S_DATA: begin
                if (baud_tick) begin
                    next_shift_reg = {rx, shift_reg[7:1]};  // LSB first
                    if (bit_cnt == 3'd7)
                        next_state = S_STOP;
                    else
                        next_bit_cnt = bit_cnt + 1;
                end
            end

            S_STOP: begin
                if (baud_tick) begin
                    next_state   = S_IDLE;
                    next_bit_cnt = 3'd0;
                end
            end

            default: next_state = S_IDLE;
        endcase
    end

    // ══════════ BLOCK 3b: Output Logic (Combinational) ══════════
    always @(*) begin
        rx_data  = shift_reg;
        rx_valid = 1'b0;

        case (state)
            S_STOP: begin
                if (baud_tick && rx == 1'b1)
                    rx_valid = 1'b1;        // Valid data!
            end
            default: ;
        endcase
    end

endmodule
```

### 3.3 Mealy FSM — Output phụ thuộc input

```verilog
// =============================================
// Mealy FSM: Phát hiện chuỗi "101"
// =============================================
module sequence_detector_mealy(
    input  wire clk,
    input  wire rst_n,
    input  wire din,
    output reg  detected      // Output phụ thuộc state + input
);
    localparam S0 = 2'd0;    // Chưa khớp gì
    localparam S1 = 2'd1;    // Đã thấy "1"
    localparam S2 = 2'd2;    // Đã thấy "10"

    reg [1:0] state, next_state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= S0;
        else        state <= next_state;
    end

    always @(*) begin
        next_state = state;
        detected   = 1'b0;

        case (state)
            S0: begin
                if (din) next_state = S1;
                else     next_state = S0;
            end
            S1: begin
                if (!din) next_state = S2;
                else      next_state = S1;
            end
            S2: begin
                if (din) begin
                    next_state = S1;
                    detected   = 1'b1;    // Mealy: output ngay khi input match
                end else begin
                    next_state = S0;
                end
            end
            default: next_state = S0;
        endcase
    end
endmodule
```

### 3.4 FSM with Datapath (FSMD)

```verilog
// =============================================
// FSMD: FSM + Datapath — Bộ tính GCD (ước chung lớn nhất)
// Thuật toán: while (a != b) if (a > b) a = a - b; else b = b - a;
// =============================================
module gcd_fsmd #(
    parameter WIDTH = 8
)(
    input  wire              clk,
    input  wire              rst_n,
    input  wire              start,
    input  wire [WIDTH-1:0]  a_in, b_in,
    output reg  [WIDTH-1:0]  result,
    output reg               done
);

    // FSM states
    localparam S_IDLE    = 2'd0;
    localparam S_COMPUTE = 2'd1;
    localparam S_DONE    = 2'd2;

    reg [1:0]       state, next_state;
    reg [WIDTH-1:0] a_reg, b_reg;
    reg [WIDTH-1:0] a_next, b_next;

    // State register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
            a_reg <= 0;
            b_reg <= 0;
        end else begin
            state <= next_state;
            a_reg <= a_next;
            b_reg <= b_next;
        end
    end

    // Next state + datapath control
    always @(*) begin
        next_state = state;
        a_next     = a_reg;
        b_next     = b_reg;
        done       = 1'b0;
        result     = 0;

        case (state)
            S_IDLE: begin
                if (start) begin
                    a_next     = a_in;
                    b_next     = b_in;
                    next_state = S_COMPUTE;
                end
            end

            S_COMPUTE: begin
                if (a_reg == b_reg)
                    next_state = S_DONE;
                else if (a_reg > b_reg)
                    a_next = a_reg - b_reg;
                else
                    b_next = b_reg - a_reg;
            end

            S_DONE: begin
                result     = a_reg;
                done       = 1'b1;
                next_state = S_IDLE;
            end

            default: next_state = S_IDLE;
        endcase
    end
endmodule
```

---

## 4. Kỹ thuật FIFO

### 4.1 FIFO đồng bộ (Synchronous FIFO)

Cùng clock domain cho đọc và ghi:

```verilog
module sync_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16
)(
    input  wire                   clk,
    input  wire                   rst_n,
    // Write interface
    input  wire                   wr_en,
    input  wire [DATA_WIDTH-1:0]  wr_data,
    // Read interface
    input  wire                   rd_en,
    output reg  [DATA_WIDTH-1:0]  rd_data,
    // Status flags
    output wire                   full,
    output wire                   empty,
    output wire                   almost_full,   // Gần đầy
    output wire                   almost_empty,  // Gần rỗng
    output wire [$clog2(DEPTH):0] count
);

    localparam ADDR_W = $clog2(DEPTH);

    // Memory
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    
    // Pointers — dùng thêm 1 bit MSB để phân biệt full/empty
    reg [ADDR_W:0] wr_ptr, rd_ptr;

    // Status
    assign count        = wr_ptr - rd_ptr;
    assign full         = (count == DEPTH);
    assign empty        = (count == 0);
    assign almost_full  = (count >= DEPTH - 2);
    assign almost_empty = (count <= 2);

    // Write logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
        end else if (wr_en && !full) begin
            mem[wr_ptr[ADDR_W-1:0]] <= wr_data;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // Read logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr  <= 0;
            rd_data <= 0;
        end else if (rd_en && !empty) begin
            rd_data <= mem[rd_ptr[ADDR_W-1:0]];
            rd_ptr  <= rd_ptr + 1;
        end
    end

endmodule
```

### 4.2 FIFO bất đồng bộ (Asynchronous FIFO)

Hai clock domain khác nhau — sử dụng mã **Gray code** cho con trỏ:

```verilog
module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16
)(
    // Write domain
    input  wire                   wr_clk,
    input  wire                   wr_rst_n,
    input  wire                   wr_en,
    input  wire [DATA_WIDTH-1:0]  wr_data,
    output wire                   full,
    
    // Read domain
    input  wire                   rd_clk,
    input  wire                   rd_rst_n,
    input  wire                   rd_en,
    output wire [DATA_WIDTH-1:0]  rd_data,
    output wire                   empty
);

    localparam ADDR_W = $clog2(DEPTH);

    // Memory (dual-port RAM)
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Write pointer (binary + gray)
    reg [ADDR_W:0] wr_ptr_bin, wr_ptr_gray;
    
    // Read pointer (binary + gray)
    reg [ADDR_W:0] rd_ptr_bin, rd_ptr_gray;

    // Synchronized pointers (cross clock domain)
    reg [ADDR_W:0] wr_gray_sync1, wr_gray_sync2;  // wr→rd domain
    reg [ADDR_W:0] rd_gray_sync1, rd_gray_sync2;  // rd→wr domain

    // ═══════ Binary to Gray conversion ═══════
    function [ADDR_W:0] bin2gray;
        input [ADDR_W:0] bin;
        begin
            bin2gray = bin ^ (bin >> 1);
        end
    endfunction

    // ═══════ Write Logic (wr_clk domain) ═══════
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            wr_ptr_bin  <= 0;
            wr_ptr_gray <= 0;
        end else if (wr_en && !full) begin
            mem[wr_ptr_bin[ADDR_W-1:0]] <= wr_data;
            wr_ptr_bin  <= wr_ptr_bin + 1;
            wr_ptr_gray <= bin2gray(wr_ptr_bin + 1);
        end
    end

    // ═══════ Read Logic (rd_clk domain) ═══════
    assign rd_data = mem[rd_ptr_bin[ADDR_W-1:0]];

    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            rd_ptr_bin  <= 0;
            rd_ptr_gray <= 0;
        end else if (rd_en && !empty) begin
            rd_ptr_bin  <= rd_ptr_bin + 1;
            rd_ptr_gray <= bin2gray(rd_ptr_bin + 1);
        end
    end

    // ═══════ Synchronizers (2-FF synchronizer) ═══════
    // Sync write pointer → read domain
    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            wr_gray_sync1 <= 0;
            wr_gray_sync2 <= 0;
        end else begin
            wr_gray_sync1 <= wr_ptr_gray;
            wr_gray_sync2 <= wr_gray_sync1;
        end
    end

    // Sync read pointer → write domain
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            rd_gray_sync1 <= 0;
            rd_gray_sync2 <= 0;
        end else begin
            rd_gray_sync1 <= rd_ptr_gray;
            rd_gray_sync2 <= rd_gray_sync1;
        end
    end

    // ═══════ Full/Empty flags ═══════
    // Full: MSB khác, còn lại giống → wr đi hết 1 vòng
    assign full = (wr_ptr_gray[ADDR_W]     != rd_gray_sync2[ADDR_W]) &&
                  (wr_ptr_gray[ADDR_W-1]   != rd_gray_sync2[ADDR_W-1]) &&
                  (wr_ptr_gray[ADDR_W-2:0] == rd_gray_sync2[ADDR_W-2:0]);

    // Empty: 2 gray pointer bằng nhau
    assign empty = (rd_ptr_gray == wr_gray_sync2);

endmodule
```

### 4.3 Khi nào dùng FIFO?

| Tình huống | Loại FIFO |
|-----------|-----------|
| Buffer dữ liệu trong cùng clock | Sync FIFO |
| Kết nối 2 clock domain khác nhau | Async FIFO |
| UART RX buffer | Sync FIFO |
| PCIe / DDR interface | Async FIFO |
| Producer-Consumer pattern | Sync hoặc Async FIFO |

---

## 5. Pipeline (Đường ống)

### 5.1 Tại sao cần Pipeline?

```
Không pipeline:
  ┌────────────────────────────────────────┐
  │    Stage A + B + C (30ns delay)         │  → Fmax = 33 MHz
  └────────────────────────────────────────┘

Có pipeline:
  ┌──────────┐  ┌──────────┐  ┌──────────┐
  │ Stage A  │─→│ Stage B  │─→│ Stage C  │  → Fmax = 100 MHz
  │  (10ns)  │  │  (10ns)  │  │  (10ns)  │     (throughput tăng 3x)
  └──────────┘  └──────────┘  └──────────┘
       FF           FF           FF
```

### 5.2 Ví dụ: Pipeline cho phép tính phức tạp

```verilog
// =============================================
// Pipeline 3 tầng: result = (a * b) + c
// Không pipeline: delay = mult_delay + add_delay
// Có pipeline: Fmax tăng gấp đôi, latency thêm 2 clock
// =============================================
module pipelined_mac #(
    parameter WIDTH = 8
)(
    input  wire                clk,
    input  wire                rst_n,
    input  wire [WIDTH-1:0]    a, b, c,
    input  wire                valid_in,
    output reg  [2*WIDTH:0]    result,
    output reg                 valid_out
);

    // ── Pipeline stage 1: Register inputs ──
    reg [WIDTH-1:0]   a_s1, b_s1, c_s1;
    reg               valid_s1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_s1     <= 0;
            b_s1     <= 0;
            c_s1     <= 0;
            valid_s1 <= 0;
        end else begin
            a_s1     <= a;
            b_s1     <= b;
            c_s1     <= c;
            valid_s1 <= valid_in;
        end
    end

    // ── Pipeline stage 2: Multiply ──
    reg [2*WIDTH-1:0] mult_s2;
    reg [WIDTH-1:0]   c_s2;
    reg               valid_s2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mult_s2  <= 0;
            c_s2     <= 0;
            valid_s2 <= 0;
        end else begin
            mult_s2  <= a_s1 * b_s1;   // Multiply
            c_s2     <= c_s1;            // Forward c to next stage
            valid_s2 <= valid_s1;
        end
    end

    // ── Pipeline stage 3: Add ──
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result    <= 0;
            valid_out <= 0;
        end else begin
            result    <= mult_s2 + c_s2; // Add
            valid_out <= valid_s2;
        end
    end

endmodule
```

---

## 6. Handshake Protocol (Giao thức bắt tay)

### 6.1 Valid-Ready Handshake

```verilog
// =============================================
// Valid-Ready: Chuẩn giao tiếp giữa các module
// Dữ liệu được truyền khi CẢ valid VÀ ready đều HIGH
// =============================================

// Producer (nguồn phát)
module data_producer(
    input  wire       clk,
    input  wire       rst_n,
    output reg  [7:0] data,
    output reg        valid,
    input  wire       ready     // Từ consumer
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data  <= 0;
            valid <= 0;
        end else begin
            if (valid && ready) begin
                // Handshake thành công → gửi data tiếp theo
                data  <= data + 1;
                valid <= 1'b1;
            end else if (!valid) begin
                // Chưa gửi → bắt đầu gửi
                valid <= 1'b1;
            end
            // Nếu valid=1 nhưng ready=0 → giữ nguyên (đợi consumer)
        end
    end
endmodule

// Consumer (bên nhận)
module data_consumer(
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] data,
    input  wire       valid,    // Từ producer
    output reg        ready
);
    reg [7:0] stored_data;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ready       <= 1'b1;    // Sẵn sàng nhận
            stored_data <= 0;
        end else begin
            if (valid && ready) begin
                // Nhận dữ liệu
                stored_data <= data;
                ready       <= 1'b0;   // Bận xử lý
            end else if (!ready) begin
                // Xử lý xong → sẵn sàng nhận tiếp
                ready <= 1'b1;
            end
        end
    end
endmodule
```

### 6.2 Sơ đồ thời gian Handshake

```
         ___     ___     ___     ___     ___     ___
clk   __|   |___|   |___|   |___|   |___|   |___|   |__

              _______________
valid _______|               |______________________________
         ___________________
ready ___|                   |______________________________
                                     
data  ----<   DATA VALID     >------------------------------
              ↑
              Handshake xảy ra tại posedge clk
              khi valid=1 AND ready=1
```

---

## 7. Clock Domain Crossing (CDC)

### 7.1 Vấn đề Metastability

Khi tín hiệu đi từ clock domain này sang clock domain khác, có thể xảy ra **metastability** — flip-flop ở trạng thái không ổn định.

### 7.2 Đồng bộ hóa 2 tầng (2-FF Synchronizer)

```verilog
// =============================================
// 2-FF Synchronizer cho tín hiệu 1-bit
// =============================================
module sync_2ff(
    input  wire clk_dst,     // Clock domain đích
    input  wire rst_n,
    input  wire async_in,    // Tín hiệu từ domain khác
    output wire sync_out     // Tín hiệu đã đồng bộ
);
    reg sync_ff1, sync_ff2;

    always @(posedge clk_dst or negedge rst_n) begin
        if (!rst_n) begin
            sync_ff1 <= 1'b0;
            sync_ff2 <= 1'b0;
        end else begin
            sync_ff1 <= async_in;     // Tầng 1: có thể metastable
            sync_ff2 <= sync_ff1;     // Tầng 2: ổn định
        end
    end

    assign sync_out = sync_ff2;
endmodule

// =============================================
// Pulse Synchronizer (truyền xung qua clock domain)
// =============================================
module pulse_sync(
    // Source domain
    input  wire src_clk,
    input  wire src_rst_n,
    input  wire src_pulse,
    // Destination domain
    input  wire dst_clk,
    input  wire dst_rst_n,
    output wire dst_pulse
);
    // Toggle in source domain
    reg toggle_src;
    always @(posedge src_clk or negedge src_rst_n) begin
        if (!src_rst_n)
            toggle_src <= 1'b0;
        else if (src_pulse)
            toggle_src <= ~toggle_src;
    end

    // Synchronize toggle to destination domain
    reg sync1, sync2, sync3;
    always @(posedge dst_clk or negedge dst_rst_n) begin
        if (!dst_rst_n) begin
            sync1 <= 1'b0;
            sync2 <= 1'b0;
            sync3 <= 1'b0;
        end else begin
            sync1 <= toggle_src;
            sync2 <= sync1;
            sync3 <= sync2;
        end
    end

    // Edge detect → generate pulse
    assign dst_pulse = sync2 ^ sync3;
endmodule
```

---

## 8. Parameterized Design (Thiết kế tham số hóa)

### 8.1 Tạo module tái sử dụng

```verilog
// =============================================
// Universal Shift Register — tham số hóa đầy đủ
// =============================================
module universal_shift_reg #(
    parameter WIDTH     = 8,           // Độ rộng
    parameter RESET_VAL = {WIDTH{1'b0}} // Giá trị reset
)(
    input  wire              clk,
    input  wire              rst_n,
    input  wire [1:0]        mode,      // 00=giữ, 01=dịch phải, 10=dịch trái, 11=nạp
    input  wire              serial_in,
    input  wire [WIDTH-1:0]  parallel_in,
    output wire [WIDTH-1:0]  parallel_out,
    output wire              serial_out_msb,
    output wire              serial_out_lsb
);
    reg [WIDTH-1:0] shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            shift_reg <= RESET_VAL;
        else begin
            case (mode)
                2'b00: shift_reg <= shift_reg;                              // Hold
                2'b01: shift_reg <= {serial_in, shift_reg[WIDTH-1:1]};     // Shift Right
                2'b10: shift_reg <= {shift_reg[WIDTH-2:0], serial_in};     // Shift Left
                2'b11: shift_reg <= parallel_in;                            // Load
            endcase
        end
    end

    assign parallel_out   = shift_reg;
    assign serial_out_msb = shift_reg[WIDTH-1];
    assign serial_out_lsb = shift_reg[0];
endmodule
```

### 8.2 Sử dụng `$clog2` và expression trong parameter

```verilog
module configurable_timer #(
    parameter CLK_FREQ   = 50_000_000,
    parameter TARGET_MS  = 1000,           // 1 second
    parameter MAX_COUNT  = CLK_FREQ / 1000 * TARGET_MS,
    parameter CNT_WIDTH  = $clog2(MAX_COUNT + 1)
)(
    input  wire              clk,
    input  wire              rst_n,
    output reg               tick,
    output reg [CNT_WIDTH-1:0] counter
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            tick    <= 0;
        end else if (counter == MAX_COUNT - 1) begin
            counter <= 0;
            tick    <= 1'b1;
        end else begin
            counter <= counter + 1;
            tick    <= 1'b0;
        end
    end
endmodule
```

---

## 9. Kỹ thuật Reset

### 9.1 Reset đồng bộ vs bất đồng bộ

```verilog
// =============================================
// Reset ĐỒNG BỘ — reset chỉ có hiệu lực tại cạnh clock
// =============================================
// Ưu điểm: không gây glitch, dễ timing
// Nhược điểm: cần clock hoạt động để reset
always @(posedge clk) begin
    if (rst)           // rst nằm TRONG always, KHÔNG ở sensitivity list
        q <= 1'b0;
    else
        q <= d;
end

// =============================================
// Reset BẤT ĐỒNG BỘ — reset có hiệu lực ngay lập tức
// =============================================
// Ưu điểm: reset ngay cả khi không có clock
// Nhược điểm: có thể gây metastability khi thả reset
always @(posedge clk or negedge rst_n) begin  // rst_n trong sensitivity list
    if (!rst_n)
        q <= 1'b0;
    else
        q <= d;
end

// =============================================
// Reset ĐỒNG BỘ HÓA (Async Assert, Sync De-assert) — BEST PRACTICE
// =============================================
// Kết hợp ưu điểm của cả hai:
// - Assert (kích hoạt) bất đồng bộ → reset ngay
// - De-assert (thả) đồng bộ → tránh metastability
module reset_synchronizer(
    input  wire clk,
    input  wire async_rst_n,     // Nút nhấn reset (async)
    output wire sync_rst_n       // Reset đã đồng bộ
);
    reg rst_ff1, rst_ff2;

    always @(posedge clk or negedge async_rst_n) begin
        if (!async_rst_n) begin
            rst_ff1 <= 1'b0;     // Assert ngay (async)
            rst_ff2 <= 1'b0;
        end else begin
            rst_ff1 <= 1'b1;     // De-assert đồng bộ
            rst_ff2 <= rst_ff1;
        end
    end

    assign sync_rst_n = rst_ff2;
endmodule
```

### 9.2 Active High vs Active Low Reset

| Quy ước | Tên tín hiệu | Reset khi | Phổ biến |
|---------|-------------|-----------|--------|
| Active Low | `rst_n`, `reset_n` | `= 0` | ✅ Phổ biến hơn |
| Active High | `rst`, `reset` | `= 1` | FPGA development |

---

## 10. Mẫu thiết kế thường dùng (Design Patterns)

### 10.1 Edge Detector

```verilog
module edge_detector(
    input  wire clk,
    input  wire rst_n,
    input  wire signal_in,
    output wire rising_edge,
    output wire falling_edge,
    output wire any_edge
);
    reg signal_d;    // Delayed signal

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            signal_d <= 1'b0;
        else
            signal_d <= signal_in;
    end

    assign rising_edge  = signal_in & ~signal_d;     // 0→1
    assign falling_edge = ~signal_in & signal_d;     // 1→0
    assign any_edge     = signal_in ^ signal_d;      // Bất kỳ thay đổi
endmodule
```

### 10.2 Timeout Watchdog

```verilog
module watchdog #(
    parameter CLK_FREQ   = 50_000_000,
    parameter TIMEOUT_MS = 1000
)(
    input  wire clk,
    input  wire rst_n,
    input  wire kick,           // "Đá" watchdog để reset timer
    output reg  timeout         // = 1 khi hết thời gian chờ
);
    localparam MAX_CNT = CLK_FREQ / 1000 * TIMEOUT_MS;
    localparam CNT_W   = $clog2(MAX_CNT + 1);

    reg [CNT_W-1:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            timeout <= 1'b0;
        end else if (kick) begin
            counter <= 0;
            timeout <= 1'b0;
        end else if (counter == MAX_CNT - 1) begin
            timeout <= 1'b1;
        end else begin
            counter <= counter + 1;
        end
    end
endmodule
```

### 10.3 Circular Buffer (Ring Buffer)

```verilog
module ring_buffer #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 64
)(
    input  wire                   clk,
    input  wire                   rst_n,
    input  wire                   write,
    input  wire [DATA_WIDTH-1:0]  wr_data,
    input  wire [$clog2(DEPTH)-1:0] rd_addr,  // Đọc bất kỳ vị trí nào
    output wire [DATA_WIDTH-1:0]  rd_data,
    output reg  [$clog2(DEPTH)-1:0] head     // Vị trí ghi hiện tại
);
    localparam ADDR_W = $clog2(DEPTH);
    
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            head <= 0;
        else if (write) begin
            mem[head] <= wr_data;
            head <= (head == DEPTH - 1) ? 0 : head + 1;
        end
    end

    assign rd_data = mem[rd_addr];
endmodule
```

---

## 11. Tối ưu hiệu năng & Tài nguyên

### 11.1 Bảng so sánh kỹ thuật tối ưu

| Kỹ thuật | Mục đích | Đánh đổi |
|----------|---------|----------|
| **Pipeline** | Tăng Fmax | Tăng latency, tăng FF |
| **Resource sharing** | Giảm LUT | Giảm throughput |
| **Retiming** | Cân bằng delay | Công cụ tự động |
| **Clock enable** | Giảm power | Thêm logic |
| **Gated clock** | Giảm power | Khó timing ⚠️ |
| **Memory inference** | Dùng BRAM thay FF | Thêm latency 1 cycle |

### 11.2 Dùng BRAM thay vì Register

```verilog
// ❌ Tốn register (distributed RAM):
reg [7:0] small_mem [0:15];   // 16 x 8 = 128 FF

// ✅ Dùng Block RAM (BRAM) — hiệu quả cho memory lớn:
// Cần đọc ĐỒNG BỘ để tool infer BRAM
reg [7:0] bram_mem [0:1023];  // 1024 x 8 = 8Kbit

always @(posedge clk) begin
    if (we)
        bram_mem[addr] <= din;
    dout <= bram_mem[addr];    // Đọc ĐỒNG BỘ → BRAM
end
```

---

## 12. Coding Guidelines cho dự án thực tế

### 12.1 Cấu trúc dự án

```
project/
├── src/                      # Source files (RTL)
│   ├── top_module.v          # Top-level module
│   ├── sub_module_a.v
│   ├── sub_module_b.v
│   └── includes/
│       └── defines.vh        # Macro definitions
├── tb/                       # Testbench files
│   ├── top_module_tb.v
│   ├── sub_module_a_tb.v
│   └── sub_module_b_tb.v
├── sim/                      # Simulation outputs
│   ├── waveform.vcd
│   └── sim.log
├── constraints/              # FPGA constraints
│   └── pins.xdc (Xilinx) / pins.qsf (Intel)
├── docs/                     # Documentation
│   └── architecture.md
├── scripts/                  # Build scripts
│   ├── compile.sh
│   └── simulate.sh
└── Makefile                  # Build automation
```

### 12.2 Checklist thiết kế

```
□ Tất cả output được gán giá trị mặc định (tránh latch)
□ Sensitivity list dùng @(*) cho combinational
□ Blocking (=) cho combinational, non-blocking (<=) cho sequential
□ Không trộn = và <= trong cùng always block
□ Mỗi tín hiệu chỉ gán ở 1 always block
□ Parameter thay vì magic number
□ Reset được đồng bộ hóa
□ Input bất đồng bộ qua 2-FF synchronizer
□ case có default
□ Testbench tự kiểm tra (self-checking)
□ Waveform dump cho debug
□ Comment đầy đủ
```

### 12.3 Naming Convention chuẩn

```verilog
// Tín hiệu
clk                 // Clock
rst_n               // Reset tích cực thấp
data_valid          // Tín hiệu hợp lệ
data_in, data_out   // Dữ liệu vào/ra
wr_en, rd_en        // Write/Read enable

// Hậu tố
_n                  // Active low (tích cực thấp)
_d, _q              // Input/output của FF
_reg                // Registered version
_next               // Next-state value
_sync               // Synchronized signal
_i, _o              // Input/output port (thay thế)

// Module instance
u_<name>            // Unit instance (u_alu, u_fifo)
gen_<name>          // Generate block

// Parameter
UPPER_CASE          // Hằng số, parameter
```

---

> **Xem tiếp**: [DE10_Lite.md](DE10_Lite.md) — Hướng dẫn sử dụng board DE10-Lite, nạp FPGA bằng Quartus, ví dụ thực hành Blink LED, 7-Segment
