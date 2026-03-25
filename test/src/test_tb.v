`timescale 1ns/1ps

module test_tb;

reg  a, b;
wire y;

// Instantiate DUT
test uut (
    .a (a),
    .b (b),
    .y (y)
);

initial begin
    a=0; b=0; #20;   // y = 0
    a=0; b=1; #20;   // y = 0
    a=1; b=0; #20;   // y = 0
    a=1; b=1; #20;   // y = 1  ← chỉ cái này sáng
    $stop;
end

initial begin
    $monitor("t=%0t | a=%b b=%b | y=%b", $time, a, b, y);
end

endmodule
