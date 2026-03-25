# 📗 Tài liệu Lập trình Verilog — Phần 2: Thiết kế Mạch số

> **Phần trước**: [README.md](README.md) — Tổng quan & Cú pháp cơ bản
> **Phần sau**: [CLAUDE.md](CLAUDE.md) — Testbench, Mô phỏng & Kỹ thuật nâng cao

---

## 📑 Mục lục

- [1. Mạch tổ hợp (Combinational Circuits)](#1-mạch-tổ-hợp-combinational-circuits)
- [2. Mạch tuần tự (Sequential Circuits)](#2-mạch-tuần-tự-sequential-circuits)
- [3. Máy trạng thái hữu hạn (FSM)](#3-máy-trạng-thái-hữu-hạn-fsm)
- [4. Thiết kế bộ nhớ (Memory)](#4-thiết-kế-bộ-nhớ-memory)
- [5. Giao tiếp ngoại vi](#5-giao-tiếp-ngoại-vi)
- [6. Thiết kế phân cấp (Hierarchical Design)](#6-thiết-kế-phân-cấp-hierarchical-design)
- [7. Các lỗi phổ biến và cách tránh](#7-các-lỗi-phổ-biến-và-cách-tránh)

---

## 1. Mạch tổ hợp (Combinational Circuits)

> **Đặc điểm**: Output chỉ phụ thuộc vào input **hiện tại** — không có bộ nhớ.

### 1.1 Cổng logic cơ bản

```verilog
module basic_gates(
    input  wire a, b,
    output wire y_and,
    output wire y_or,
    output wire y_not,
    output wire y_nand,
    output wire y_nor,
    output wire y_xor,
    output wire y_xnor
);

    assign y_and  = a & b;     // AND
    assign y_or   = a | b;     // OR
    assign y_not  = ~a;        // NOT
    assign y_nand = ~(a & b);  // NAND
    assign y_nor  = ~(a | b);  // NOR
    assign y_xor  = a ^ b;     // XOR
    assign y_xnor = ~(a ^ b);  // XNOR

endmodule
```

### 1.2 Multiplexer (MUX)

```verilog
// =============================================
// MUX 2:1
// =============================================
module mux2to1(
    input  wire       a, b,
    input  wire       sel,
    output wire       y
);
    assign y = sel ? b : a;
    // sel=0 → y=a, sel=1 → y=b
endmodule

// =============================================
// MUX 4:1
// =============================================
module mux4to1(
    input  wire [7:0] d0, d1, d2, d3,
    input  wire [1:0] sel,
    output reg  [7:0] y
);
    always @(*) begin
        case (sel)
            2'b00:   y = d0;
            2'b01:   y = d1;
            2'b10:   y = d2;
            2'b11:   y = d3;
            default: y = 8'd0;
        endcase
    end
endmodule

// =============================================
// MUX 8:1 dùng toán tử điều kiện
// =============================================
module mux8to1 #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0] d [0:7],  // Mảng 8 đầu vào (SV style)
    input  wire [2:0]       sel,
    output wire [WIDTH-1:0] y
);
    assign y = d[sel];
endmodule
```

### 1.3 Decoder & Encoder

```verilog
// =============================================
// Decoder 3-to-8
// =============================================
module decoder3to8(
    input  wire [2:0] in,
    input  wire       enable,
    output reg  [7:0] out
);
    always @(*) begin
        out = 8'b0000_0000;         // Mặc định tất cả = 0
        if (enable) begin
            case (in)
                3'd0: out = 8'b0000_0001;
                3'd1: out = 8'b0000_0010;
                3'd2: out = 8'b0000_0100;
                3'd3: out = 8'b0000_1000;
                3'd4: out = 8'b0001_0000;
                3'd5: out = 8'b0010_0000;
                3'd6: out = 8'b0100_0000;
                3'd7: out = 8'b1000_0000;
                default: out = 8'b0000_0000;
            endcase
        end
    end
endmodule

// =============================================
// Priority Encoder 8-to-3
// =============================================
module priority_encoder(
    input  wire [7:0] in,
    output reg  [2:0] out,
    output reg        valid     // 1 nếu có ít nhất 1 bit = 1
);
    always @(*) begin
        valid = 1'b1;
        casez (in)
            8'b1???_????: out = 3'd7;   // Bit 7 ưu tiên cao nhất
            8'b01??_????: out = 3'd6;
            8'b001?_????: out = 3'd5;
            8'b0001_????: out = 3'd4;
            8'b0000_1???: out = 3'd3;
            8'b0000_01??: out = 3'd2;
            8'b0000_001?: out = 3'd1;
            8'b0000_0001: out = 3'd0;
            default: begin
                out   = 3'd0;
                valid = 1'b0;            // Không có bit nào = 1
            end
        endcase
    end
endmodule
```

### 1.4 Bộ cộng (Adder)

```verilog
// =============================================
// Half Adder
// =============================================
module half_adder(
    input  wire a, b,
    output wire sum, cout
);
    assign sum  = a ^ b;
    assign cout = a & b;
endmodule

// =============================================
// Full Adder
// =============================================
module full_adder(
    input  wire a, b, cin,
    output wire sum, cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule

// =============================================
// Ripple Carry Adder N-bit (dùng generate)
// =============================================
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
    assign cout     = carry[N];

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_fa
            full_adder fa_inst (
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

### 1.5 Bộ so sánh (Comparator)

```verilog
module comparator #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0] a, b,
    output wire             eq,      // a == b
    output wire             gt,      // a > b
    output wire             lt       // a < b
);
    assign eq = (a == b);
    assign gt = (a > b);
    assign lt = (a < b);
endmodule
```

### 1.6 ALU (Arithmetic Logic Unit)

```verilog
module alu #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0] a, b,
    input  wire [3:0]       alu_op,
    output reg  [WIDTH-1:0] result,
    output reg              zero,
    output reg              carry,
    output reg              overflow
);

    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SLL  = 4'b0101;   // Shift Left Logical
    localparam ALU_SRL  = 4'b0110;   // Shift Right Logical
    localparam ALU_SRA  = 4'b0111;   // Shift Right Arithmetic
    localparam ALU_SLT  = 4'b1000;   // Set Less Than
    localparam ALU_NOR  = 4'b1001;

    reg [WIDTH:0] temp;  // 1 bit thêm cho carry

    always @(*) begin
        temp     = 0;
        carry    = 0;
        overflow = 0;

        case (alu_op)
            ALU_ADD: begin
                temp   = {1'b0, a} + {1'b0, b};
                result = temp[WIDTH-1:0];
                carry  = temp[WIDTH];
                // Overflow: cùng dấu nhưng kết quả khác dấu
                overflow = (a[WIDTH-1] == b[WIDTH-1]) && 
                           (result[WIDTH-1] != a[WIDTH-1]);
            end
            ALU_SUB: begin
                temp   = {1'b0, a} - {1'b0, b};
                result = temp[WIDTH-1:0];
                carry  = temp[WIDTH];  // borrow
                overflow = (a[WIDTH-1] != b[WIDTH-1]) && 
                           (result[WIDTH-1] != a[WIDTH-1]);
            end
            ALU_AND: result = a & b;
            ALU_OR:  result = a | b;
            ALU_XOR: result = a ^ b;
            ALU_NOR: result = ~(a | b);
            ALU_SLL: result = a << b[2:0];
            ALU_SRL: result = a >> b[2:0];
            ALU_SRA: result = $signed(a) >>> b[2:0];
            ALU_SLT: result = ($signed(a) < $signed(b)) ? 1 : 0;
            default: result = {WIDTH{1'b0}};
        endcase

        zero = (result == {WIDTH{1'b0}});
    end

endmodule
```

### 1.7 Bộ hiển thị 7-Segment

```verilog
module seven_seg_decoder(
    input  wire [3:0] bcd,       // Đầu vào BCD (0-9)
    output reg  [6:0] seg        // 7 đoạn: seg[6]=a, ..., seg[0]=g
);
    //     aaa
    //    f   b
    //     ggg
    //    e   c
    //     ddd
    
    always @(*) begin
        case (bcd)
            //                   abcdefg
            4'd0: seg = 7'b1111110;  // 0
            4'd1: seg = 7'b0110000;  // 1
            4'd2: seg = 7'b1101101;  // 2
            4'd3: seg = 7'b1111001;  // 3
            4'd4: seg = 7'b0110011;  // 4
            4'd5: seg = 7'b1011011;  // 5
            4'd6: seg = 7'b1011111;  // 6
            4'd7: seg = 7'b1110000;  // 7
            4'd8: seg = 7'b1111111;  // 8
            4'd9: seg = 7'b1111011;  // 9
            default: seg = 7'b0000000;  // Tắt
        endcase
    end
endmodule
```

---

## 2. Mạch tuần tự (Sequential Circuits)

> **Đặc điểm**: Output phụ thuộc vào input **hiện tại** VÀ **trạng thái trước đó** — có bộ nhớ (flip-flop).

### 2.1 D Flip-Flop

```verilog
// =============================================
// D Flip-Flop cơ bản
// =============================================
module d_ff(
    input  wire clk,
    input  wire d,
    output reg  q
);
    always @(posedge clk) begin
        q <= d;
    end
endmodule

// =============================================
// D Flip-Flop với Reset bất đồng bộ
// =============================================
module d_ff_async_rst(
    input  wire clk,
    input  wire rst_n,    // Reset tích cực thấp
    input  wire d,
    output reg  q
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 1'b0;    // Reset
        else
            q <= d;        // Hoạt động bình thường
    end
endmodule

// =============================================
// D Flip-Flop với Reset đồng bộ + Enable
// =============================================
module d_ff_sync_rst_en(
    input  wire clk,
    input  wire rst,       // Reset đồng bộ, tích cực cao
    input  wire en,        // Enable
    input  wire d,
    output reg  q
);
    always @(posedge clk) begin
        if (rst)
            q <= 1'b0;
        else if (en)
            q <= d;
        // Nếu không có else → giữ nguyên giá trị (q <= q ngầm định)
    end
endmodule
```

### 2.2 Thanh ghi (Register)

```verilog
// =============================================
// Register N-bit với Load Enable
// =============================================
module register #(
    parameter WIDTH = 8
)(
    input  wire              clk,
    input  wire              rst_n,
    input  wire              load,        // Cho phép nạp
    input  wire [WIDTH-1:0]  d,
    output reg  [WIDTH-1:0]  q
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= {WIDTH{1'b0}};
        else if (load)
            q <= d;
    end
endmodule
```

### 2.3 Thanh ghi dịch (Shift Register)

```verilog
// =============================================
// Shift Register — Serial In, Parallel Out (SIPO)
// =============================================
module shift_reg_sipo #(
    parameter WIDTH = 8
)(
    input  wire              clk,
    input  wire              rst_n,
    input  wire              serial_in,
    input  wire              shift_en,
    output wire [WIDTH-1:0]  parallel_out
);
    reg [WIDTH-1:0] shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            shift_reg <= {WIDTH{1'b0}};
        else if (shift_en)
            shift_reg <= {shift_reg[WIDTH-2:0], serial_in};
            // Dịch trái, bit mới vào LSB
    end

    assign parallel_out = shift_reg;
endmodule

// =============================================
// Shift Register — Parallel In, Serial Out (PISO)
// =============================================
module shift_reg_piso #(
    parameter WIDTH = 8
)(
    input  wire              clk,
    input  wire              rst_n,
    input  wire              load,          // Nạp song song
    input  wire              shift_en,      // Cho phép dịch
    input  wire [WIDTH-1:0]  parallel_in,
    output wire              serial_out
);
    reg [WIDTH-1:0] shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            shift_reg <= {WIDTH{1'b0}};
        else if (load)
            shift_reg <= parallel_in;       // Nạp dữ liệu
        else if (shift_en)
            shift_reg <= {shift_reg[WIDTH-2:0], 1'b0};
            // Dịch trái, MSB ra ngoài
    end

    assign serial_out = shift_reg[WIDTH-1];  // Bit MSB là output
endmodule
```

### 2.4 Bộ đếm (Counter)

```verilog
// =============================================
// Bộ đếm lên (Up Counter)
// =============================================
module up_counter #(
    parameter WIDTH = 8
)(
    input  wire              clk,
    input  wire              rst_n,
    input  wire              enable,
    output reg  [WIDTH-1:0]  count,
    output wire              max_tick    // = 1 khi đếm đến giá trị max
);
    localparam MAX_VAL = {WIDTH{1'b1}};  // 2^WIDTH - 1

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= {WIDTH{1'b0}};
        else if (enable)
            count <= count + 1;
    end

    assign max_tick = (count == MAX_VAL) & enable;
endmodule

// =============================================
// Bộ đếm lên/xuống (Up/Down Counter)
// =============================================
module up_down_counter #(
    parameter WIDTH = 8
)(
    input  wire              clk,
    input  wire              rst_n,
    input  wire              enable,
    input  wire              direction,  // 1 = đếm lên, 0 = đếm xuống
    output reg  [WIDTH-1:0]  count
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= {WIDTH{1'b0}};
        else if (enable) begin
            if (direction)
                count <= count + 1;  // Đếm lên
            else
                count <= count - 1;  // Đếm xuống
        end
    end
endmodule

// =============================================
// Bộ đếm BCD (0-9)
// =============================================
module bcd_counter(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       enable,
    output reg  [3:0] bcd,
    output wire       carry        // = 1 khi chuyển từ 9 → 0
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            bcd <= 4'd0;
        else if (enable) begin
            if (bcd == 4'd9)
                bcd <= 4'd0;
            else
                bcd <= bcd + 1;
        end
    end

    assign carry = (bcd == 4'd9) & enable;
endmodule

// =============================================
// Bộ đếm Modulo-N (đếm từ 0 đến N-1)
// =============================================
module mod_n_counter #(
    parameter N     = 10,
    parameter WIDTH = $clog2(N)    // Tự tính số bit cần thiết
)(
    input  wire              clk,
    input  wire              rst_n,
    input  wire              enable,
    output reg  [WIDTH-1:0]  count,
    output wire              tick
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 0;
        else if (enable) begin
            if (count == N - 1)
                count <= 0;
            else
                count <= count + 1;
        end
    end

    assign tick = (count == N - 1) & enable;
endmodule
```

### 2.5 Bộ chia tần số (Clock Divider)

```verilog
module clock_divider #(
    parameter DIV = 2         // Chia tần số cho DIV (phải là số chẵn)
)(
    input  wire clk_in,
    input  wire rst_n,
    output reg  clk_out
);
    localparam HALF = DIV / 2;
    localparam WIDTH = $clog2(HALF);

    reg [WIDTH-1:0] counter;

    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            clk_out <= 1'b0;
        end else begin
            if (counter == HALF - 1) begin
                counter <= 0;
                clk_out <= ~clk_out;
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule
```

### 2.6 PWM Generator

```verilog
module pwm_generator #(
    parameter WIDTH = 8        // Độ phân giải PWM
)(
    input  wire              clk,
    input  wire              rst_n,
    input  wire [WIDTH-1:0]  duty_cycle,  // 0 = 0%, 255 = ~100%
    output reg               pwm_out
);
    reg [WIDTH-1:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            counter <= {WIDTH{1'b0}};
        else
            counter <= counter + 1;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pwm_out <= 1'b0;
        else
            pwm_out <= (counter < duty_cycle) ? 1'b1 : 1'b0;
    end
endmodule
```

---

## 3. Máy trạng thái hữu hạn (FSM)

### 3.1 FSM là gì?

FSM (Finite State Machine) là mô hình gồm:
- **Tập trạng thái** hữu hạn (states)
- **Trạng thái ban đầu** (initial state)
- **Điều kiện chuyển trạng thái** (transitions)
- **Output** phụ thuộc vào trạng thái

### 3.2 Hai loại FSM

| Loại | Output phụ thuộc vào | Đặc điểm |
|------|---------------------|-----------|
| **Moore** | Chỉ trạng thái hiện tại | Output ổn định, ít glitch |
| **Mealy** | Trạng thái + Input | Phản ứng nhanh hơn, ít trạng thái hơn |

### 3.3 Template FSM — 3 khối (Khuyến nghị)

```verilog
module fsm_template(
    input  wire clk,
    input  wire rst_n,
    input  wire start,
    input  wire done,
    output reg  busy,
    output reg  complete
);

    // ========================================
    // KHỐI 1: Khai báo trạng thái
    // ========================================
    localparam S_IDLE    = 3'd0;
    localparam S_START   = 3'd1;
    localparam S_PROCESS = 3'd2;
    localparam S_WAIT    = 3'd3;
    localparam S_DONE    = 3'd4;

    reg [2:0] state, next_state;

    // ========================================
    // KHỐI 2: Thanh ghi trạng thái (Sequential)
    // ========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // ========================================
    // KHỐI 3a: Logic chuyển trạng thái (Combinational)
    // ========================================
    always @(*) begin
        next_state = state;              // Mặc định: giữ nguyên
        case (state)
            S_IDLE: begin
                if (start)
                    next_state = S_START;
            end
            S_START: begin
                next_state = S_PROCESS;
            end
            S_PROCESS: begin
                next_state = S_WAIT;
            end
            S_WAIT: begin
                if (done)
                    next_state = S_DONE;
            end
            S_DONE: begin
                next_state = S_IDLE;
            end
            default: next_state = S_IDLE;
        endcase
    end

    // ========================================
    // KHỐI 3b: Logic output (Combinational — Moore)
    // ========================================
    always @(*) begin
        // Giá trị mặc định
        busy     = 1'b0;
        complete = 1'b0;

        case (state)
            S_IDLE:    ;  // Không làm gì
            S_START:   busy = 1'b1;
            S_PROCESS: busy = 1'b1;
            S_WAIT:    busy = 1'b1;
            S_DONE:    complete = 1'b1;
            default:   ;
        endcase
    end

endmodule
```

### 3.4 Ví dụ thực tế: Điều khiển đèn giao thông

```verilog
module traffic_light(
    input  wire clk,           // Clock 1Hz (1 giây/xung)
    input  wire rst_n,
    output reg  red,
    output reg  yellow,
    output reg  green
);

    // Trạng thái
    localparam S_RED    = 2'd0;
    localparam S_GREEN  = 2'd1;
    localparam S_YELLOW = 2'd2;

    // Thời gian mỗi pha (đơn vị: giây)
    localparam T_RED    = 30;
    localparam T_GREEN  = 25;
    localparam T_YELLOW = 5;

    reg [1:0] state, next_state;
    reg [4:0] timer;
    reg [4:0] timer_max;

    // Thanh ghi trạng thái
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_RED;
            timer <= 5'd0;
        end else begin
            if (timer == timer_max - 1) begin
                state <= next_state;
                timer <= 5'd0;
            end else begin
                timer <= timer + 1;
            end
        end
    end

    // Logic chuyển trạng thái + output
    always @(*) begin
        // Mặc định
        red    = 1'b0;
        yellow = 1'b0;
        green  = 1'b0;

        case (state)
            S_RED: begin
                red        = 1'b1;
                next_state = S_GREEN;
                timer_max  = T_RED;
            end
            S_GREEN: begin
                green      = 1'b1;
                next_state = S_YELLOW;
                timer_max  = T_GREEN;
            end
            S_YELLOW: begin
                yellow     = 1'b1;
                next_state = S_RED;
                timer_max  = T_YELLOW;
            end
            default: begin
                red        = 1'b1;
                next_state = S_RED;
                timer_max  = T_RED;
            end
        endcase
    end

endmodule
```

### 3.5 Ví dụ: UART Transmitter FSM

```verilog
module uart_tx #(
    parameter CLK_FREQ  = 50_000_000,   // 50 MHz
    parameter BAUD_RATE = 115200
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       tx_start,          // Bắt đầu truyền
    input  wire [7:0] tx_data,           // Dữ liệu cần truyền
    output reg        tx,                // Đường truyền serial
    output reg        tx_busy            // Đang bận truyền
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam CNT_WIDTH    = $clog2(CLKS_PER_BIT);

    // Trạng thái
    localparam S_IDLE  = 3'd0;
    localparam S_START = 3'd1;
    localparam S_DATA  = 3'd2;
    localparam S_STOP  = 3'd3;

    reg [2:0]            state;
    reg [CNT_WIDTH-1:0]  baud_cnt;
    reg [2:0]            bit_idx;
    reg [7:0]            tx_shift;
    wire                 baud_tick;

    assign baud_tick = (baud_cnt == CLKS_PER_BIT - 1);

    // Baud rate counter
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            baud_cnt <= 0;
        else if (state == S_IDLE)
            baud_cnt <= 0;
        else if (baud_tick)
            baud_cnt <= 0;
        else
            baud_cnt <= baud_cnt + 1;
    end

    // FSM
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= S_IDLE;
            tx       <= 1'b1;        // Idle = HIGH
            tx_busy  <= 1'b0;
            bit_idx  <= 3'd0;
            tx_shift <= 8'd0;
        end else begin
            case (state)
                S_IDLE: begin
                    tx      <= 1'b1;
                    tx_busy <= 1'b0;
                    if (tx_start) begin
                        state    <= S_START;
                        tx_shift <= tx_data;
                        tx_busy  <= 1'b1;
                    end
                end

                S_START: begin
                    tx <= 1'b0;          // Start bit = LOW
                    if (baud_tick)
                        state <= S_DATA;
                end

                S_DATA: begin
                    tx <= tx_shift[0];   // LSB first
                    if (baud_tick) begin
                        tx_shift <= {1'b0, tx_shift[7:1]};  // Dịch phải
                        if (bit_idx == 3'd7)
                            state <= S_STOP;
                        else
                            bit_idx <= bit_idx + 1;
                    end
                end

                S_STOP: begin
                    tx <= 1'b1;          // Stop bit = HIGH
                    if (baud_tick) begin
                        state   <= S_IDLE;
                        bit_idx <= 3'd0;
                    end
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
```

---

## 4. Thiết kế bộ nhớ (Memory)

### 4.1 ROM (Read-Only Memory)

```verilog
module rom #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input  wire [ADDR_WIDTH-1:0] addr,
    output reg  [DATA_WIDTH-1:0] data
);
    // ROM bằng case
    always @(*) begin
        case (addr)
            4'h0: data = 8'h00;
            4'h1: data = 8'h11;
            4'h2: data = 8'h22;
            4'h3: data = 8'h33;
            4'h4: data = 8'h44;
            4'h5: data = 8'h55;
            4'h6: data = 8'h66;
            4'h7: data = 8'h77;
            4'h8: data = 8'h88;
            4'h9: data = 8'h99;
            4'hA: data = 8'hAA;
            4'hB: data = 8'hBB;
            4'hC: data = 8'hCC;
            4'hD: data = 8'hDD;
            4'hE: data = 8'hEE;
            4'hF: data = 8'hFF;
            default: data = 8'h00;
        endcase
    end
endmodule
```

### 4.2 RAM đồng bộ (Synchronous RAM)

```verilog
// =============================================
// Single-Port RAM
// =============================================
module single_port_ram #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8
)(
    input  wire                   clk,
    input  wire                   we,        // Write Enable
    input  wire [ADDR_WIDTH-1:0]  addr,
    input  wire [DATA_WIDTH-1:0]  din,
    output reg  [DATA_WIDTH-1:0]  dout
);
    // Khai báo memory
    reg [DATA_WIDTH-1:0] mem [0:(2**ADDR_WIDTH)-1];

    always @(posedge clk) begin
        if (we)
            mem[addr] <= din;       // Ghi
        dout <= mem[addr];          // Đọc (read-after-write)
    end
endmodule

// =============================================
// Dual-Port RAM
// =============================================
module dual_port_ram #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8
)(
    input  wire                   clk,
    // Port A: Read/Write
    input  wire                   we_a,
    input  wire [ADDR_WIDTH-1:0]  addr_a,
    input  wire [DATA_WIDTH-1:0]  din_a,
    output reg  [DATA_WIDTH-1:0]  dout_a,
    // Port B: Read only
    input  wire [ADDR_WIDTH-1:0]  addr_b,
    output reg  [DATA_WIDTH-1:0]  dout_b
);
    reg [DATA_WIDTH-1:0] mem [0:(2**ADDR_WIDTH)-1];

    always @(posedge clk) begin
        if (we_a)
            mem[addr_a] <= din_a;
        dout_a <= mem[addr_a];
        dout_b <= mem[addr_b];
    end
endmodule
```

### 4.3 FIFO (First-In, First-Out)

```verilog
module sync_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16,
    parameter ADDR_WIDTH = $clog2(DEPTH)
)(
    input  wire                   clk,
    input  wire                   rst_n,
    // Write interface
    input  wire                   wr_en,
    input  wire [DATA_WIDTH-1:0]  wr_data,
    output wire                   full,
    // Read interface
    input  wire                   rd_en,
    output wire [DATA_WIDTH-1:0]  rd_data,
    output wire                   empty,
    // Status
    output wire [ADDR_WIDTH:0]    count
);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [ADDR_WIDTH:0]   wr_ptr, rd_ptr;  // 1 bit thêm để phân biệt full/empty

    assign full  = (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]) && 
                   (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]);
    assign empty = (wr_ptr == rd_ptr);
    assign count = wr_ptr - rd_ptr;
    assign rd_data = mem[rd_ptr[ADDR_WIDTH-1:0]];

    // Write
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            wr_ptr <= 0;
        else if (wr_en && !full) begin
            mem[wr_ptr[ADDR_WIDTH-1:0]] <= wr_data;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // Read
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            rd_ptr <= 0;
        else if (rd_en && !empty)
            rd_ptr <= rd_ptr + 1;
    end

endmodule
```

---

## 5. Giao tiếp ngoại vi

### 5.1 Debounce nút nhấn

```verilog
module debounce #(
    parameter CLK_FREQ = 50_000_000,   // 50 MHz
    parameter DELAY_MS = 20            // 20 ms debounce
)(
    input  wire clk,
    input  wire rst_n,
    input  wire btn_in,        // Nút nhấn (có nhiễu rung)
    output reg  btn_out,       // Tín hiệu đã lọc
    output reg  btn_posedge,   // Xung 1 clock khi nhấn
    output reg  btn_negedge    // Xung 1 clock khi thả
);

    localparam MAX_CNT = CLK_FREQ / 1000 * DELAY_MS;
    localparam CNT_WIDTH = $clog2(MAX_CNT);

    reg [CNT_WIDTH-1:0] counter;
    reg btn_sync_0, btn_sync_1;  // Đồng bộ hóa 2 tầng
    reg btn_prev;

    // Đồng bộ hóa input (chống metastability)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btn_sync_0 <= 1'b0;
            btn_sync_1 <= 1'b0;
        end else begin
            btn_sync_0 <= btn_in;
            btn_sync_1 <= btn_sync_0;
        end
    end

    // Debounce counter
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            btn_out <= 1'b0;
        end else begin
            if (btn_sync_1 != btn_out) begin
                if (counter == MAX_CNT - 1) begin
                    btn_out <= btn_sync_1;
                    counter <= 0;
                end else begin
                    counter <= counter + 1;
                end
            end else begin
                counter <= 0;
            end
        end
    end

    // Edge detection
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btn_prev    <= 1'b0;
            btn_posedge <= 1'b0;
            btn_negedge <= 1'b0;
        end else begin
            btn_prev    <= btn_out;
            btn_posedge <= btn_out & ~btn_prev;   // 0→1
            btn_negedge <= ~btn_out & btn_prev;    // 1→0
        end
    end

endmodule
```

### 5.2 LED Chạy (LED Runner)

```verilog
module led_runner #(
    parameter NUM_LEDS = 8,
    parameter CLK_FREQ = 50_000_000,
    parameter SPEED_MS = 200            // Thời gian mỗi bước (ms)
)(
    input  wire                clk,
    input  wire                rst_n,
    output reg  [NUM_LEDS-1:0] leds
);

    localparam MAX_CNT = CLK_FREQ / 1000 * SPEED_MS;
    localparam CNT_WIDTH = $clog2(MAX_CNT);

    reg [CNT_WIDTH-1:0] counter;
    wire tick;

    assign tick = (counter == MAX_CNT - 1);

    // Bộ chia tần
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            counter <= 0;
        else if (tick)
            counter <= 0;
        else
            counter <= counter + 1;
    end

    // LED chạy
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            leds <= {{(NUM_LEDS-1){1'b0}}, 1'b1};  // LED 0 sáng
        else if (tick)
            leds <= {leds[NUM_LEDS-2:0], leds[NUM_LEDS-1]};  // Dịch vòng
    end

endmodule
```

---

## 6. Thiết kế phân cấp (Hierarchical Design)

### 6.1 Nguyên tắc thiết kế Top-Down

```
                    top_module
                   /    |     \
              cpu_core  bus    peripherals
             /    \      |     /    |    \
           alu  reg_file  |  uart  spi  gpio
                          |
                      arbiter
```

### 6.2 Ví dụ: Hệ thống đếm hoàn chỉnh

```verilog
// =============================================
// Top module: Đếm BCD 4 chữ số + hiển thị 7-segment
// =============================================
module bcd_counter_4digit(
    input  wire        clk,         // 50 MHz
    input  wire        rst_n,
    input  wire        count_en,
    output wire [6:0]  seg,         // 7-segment data
    output wire [3:0]  an           // Anode select (4 digits)
);

    wire [3:0] ones, tens, hundreds, thousands;
    wire carry_ones, carry_tens, carry_hundreds;

    // Bộ đếm hàng đơn vị
    bcd_counter u_ones (
        .clk    (clk),
        .rst_n  (rst_n),
        .enable (count_en),
        .bcd    (ones),
        .carry  (carry_ones)
    );

    // Bộ đếm hàng chục
    bcd_counter u_tens (
        .clk    (clk),
        .rst_n  (rst_n),
        .enable (carry_ones),
        .bcd    (tens),
        .carry  (carry_tens)
    );

    // Bộ đếm hàng trăm
    bcd_counter u_hundreds (
        .clk    (clk),
        .rst_n  (rst_n),
        .enable (carry_tens),
        .bcd    (hundreds),
        .carry  (carry_hundreds)
    );

    // Bộ đếm hàng nghìn
    bcd_counter u_thousands (
        .clk    (clk),
        .rst_n  (rst_n),
        .enable (carry_hundreds),
        .bcd    (thousands),
        .carry  ()                  // Không dùng → bỏ trống
    );

    // Module quét hiển thị 7-segment
    seven_seg_mux u_display (
        .clk       (clk),
        .rst_n     (rst_n),
        .digit0    (ones),
        .digit1    (tens),
        .digit2    (hundreds),
        .digit3    (thousands),
        .seg       (seg),
        .an        (an)
    );

endmodule
```

---

## 7. Các lỗi phổ biến và cách tránh

### 7.1 Latch không mong muốn

```verilog
// ❌ SAI — tạo latch vì thiếu else
always @(*) begin
    if (sel)
        y = a;
    // Thiếu else → y giữ giá trị cũ → LATCH!
end

// ✅ ĐÚNG — có else hoặc giá trị mặc định
always @(*) begin
    y = 1'b0;           // Giá trị mặc định
    if (sel)
        y = a;
end
```

### 7.2 Thiếu tín hiệu trong sensitivity list

```verilog
// ❌ SAI — thiếu 'b' trong sensitivity list
always @(a) begin
    y = a & b;          // b thay đổi nhưng y không cập nhật!
end

// ✅ ĐÚNG — dùng @(*) cho mạch tổ hợp
always @(*) begin
    y = a & b;
end
```

### 7.3 Trộn blocking và non-blocking

```verilog
// ❌ SAI — trộn = và <= trong cùng always block
always @(posedge clk) begin
    a = b;              // Blocking
    c <= a;             // Non-blocking — LỖI LOGIC!
end

// ✅ ĐÚNG — chỉ dùng <= cho mạch tuần tự
always @(posedge clk) begin
    a <= b;
    c <= a;             // c nhận giá trị CŨ của a
end
```

### 7.4 Gán nhiều nơi cho cùng 1 tín hiệu

```verilog
// ❌ SAI — 'y' được gán ở 2 always block khác nhau
always @(posedge clk) begin
    y <= a;
end
always @(posedge clk) begin
    y <= b;             // Xung đột! → Kết quả không xác định
end

// ✅ ĐÚNG — chỉ gán ở 1 nơi
always @(posedge clk) begin
    if (sel)
        y <= a;
    else
        y <= b;
end
```

### 7.5 Bảng tóm tắt lỗi thường gặp

| Lỗi | Nguyên nhân | Cách tránh |
|------|------------|-----------|
| Latch | Thiếu `else` / `default` | Luôn có giá trị mặc định |
| Simulation ≠ Synthesis | Dùng `#delay`, `initial` trong RTL | Chỉ dùng trong testbench |
| Multi-driven net | Gán 1 tín hiệu ở nhiều always | 1 tín hiệu = 1 driver |
| Sensitivity list sai | Dùng Verilog-95 style | Luôn dùng `@(*)` |
| Race condition | Trộn `=` và `<=` | Tuân thủ quy tắc gán |
| Width mismatch | Không khớp độ rộng bit | Khai báo rõ ràng, dùng parameter |

---

> **Tiếp theo**: Xem [CLAUDE.md](CLAUDE.md) — Testbench, Mô phỏng, System Tasks & Kỹ thuật nâng cao
