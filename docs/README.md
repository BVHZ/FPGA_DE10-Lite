# Tài liệu Lập trình Verilog & FPGA

Tài liệu hướng dẫn toàn diện về lập trình Verilog và phát triển FPGA.

## Mục lục

### 1. Tài liệu Verilog

Các tài liệu được sắp xếp theo thứ tự từ cơ bản đến nâng cao:

1. **[Tổng quan & Cú pháp Cơ bản](01-verilog-overview.md)**
   - Giới thiệu về Verilog
   - Hệ thống số và kiểu dữ liệu
   - Toán tử và cấu trúc cơ bản
   - Mức độ mô tả (Behavioral, Dataflow, Structural)
   - Câu lệnh gán và cấu trúc điều khiển
   - Quy tắc đặt tên và coding style

2. **[Thiết kế Mạch số](02-digital-design.md)**
   - Thiết kế mạch tổ hợp (Combinational Logic)
   - Thiết kế mạch tuần tự (Sequential Logic)
   - Flip-flops và Registers
   - State Machines (FSM)
   - Counter, Timer, và các mạch thông dụng

3. **[Testbench & Mô phỏng](03-testbench-simulation.md)**
   - Viết testbench cơ bản và nâng cao
   - System tasks ($display, $monitor, $time, etc.)
   - Generate và khối khởi tạo
   - Kỹ thuật mô phỏng và debug
   - Timing và delay
   - File I/O trong testbench

4. **[Kỹ thuật Nâng cao](04-advanced-techniques.md)**
   - Module parameterization
   - Generate blocks
   - Hierarchical design
   - Timing constraints
   - Clock domain crossing
   - Best practices và optimization

### 2. Tài liệu Phần cứng

5. **[Hướng dẫn DE10-Lite Board](05-de10-lite-board.md)**
   - Thông số kỹ thuật board DE10-Lite
   - Intel MAX 10 FPGA (10M50DAF484C7G)
   - Pin assignment và cấu hình
   - Các peripheral trên board (LED, Switch, Button, 7-segment, etc.)
   - Quartus Prime workflow
   - Ví dụ thực hành

## Tài liệu tham khảo

- IEEE 1364-2001 (Verilog-2001 Standard)
- IEEE 1800-2012 (SystemVerilog Standard)
- "Digital Design and Computer Architecture" — David Harris & Sarah Harris
- "Verilog HDL" — Samir Palnitkar
- Intel Quartus Prime Documentation
- Terasic DE10-Lite User Manual

## Cách sử dụng

1. Nếu bạn mới bắt đầu, hãy đọc theo thứ tự từ 01 đến 04
2. Nếu đã có kiến thức cơ bản, có thể chọn phần cụ thể cần học
3. File 05 là tài liệu về board phần cứng, đọc khi cần triển khai thực tế

## Lưu ý

- Tất cả các ví dụ code đều tuân thủ Verilog-2001 standard
- Code examples được tối ưu cho synthesis trên FPGA
- Mỗi phần có ví dụ minh họa và giải thích chi tiết
- Không sử dụng icon/emoji trong tài liệu để đảm bảo tính chuyên nghiệp

## Cấu trúc Project

```
docs/
├── README.md                        (file này)
├── 01-verilog-overview.md          (Cơ bản)
├── 02-digital-design.md            (Thiết kế mạch)
├── 03-testbench-simulation.md      (Kiểm thử)
├── 04-advanced-techniques.md       (Nâng cao)
└── 05-de10-lite-board.md           (Phần cứng)
```

---

**Lần cập nhật cuối**: 2026-04-06
