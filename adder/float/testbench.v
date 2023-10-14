`include "adder-float.v"
`timescale 1ns/1ps

module adder_tb;
    reg clk, rst;
    reg [31:0] x, y;
    wire [31:0] z;
    wire [1:0] overflow;

    adder float_add(
              .clk(clk),
              .rst(rst),
              .x(x),
              .y(y),
              .z(z),
              .overflow(overflow)
          );

    always #(10) clk<=~clk;

    initial begin
        clk = 0;
        rst = 1'b0;
        #20 rst = 1'b1;

        /* test cases from https://blog.csdn.net/Phoenix_ZengHao/article/details/118760774 */

        x = 32'b00111111010001111010111000010100; //0.78
        y = 32'b00111111000011001100110011001101; //0.55
        //ans = 1.33 | 32'b0011 1111 1010 1010 0011 1101 0111 0001 | 3faa3d70
        #1000
         $display("%b + %b = %b, overflow:%b", x, y, z, overflow);
        if (z != 32'b00111111101010100011110101110001 || overflow != 2'b00) begin
            $display("Wrong Answer!");
        end
        else begin
            $display("Correct!");
        end

        x = 32'h10A0201D; //6.3158350761658E-29
        y = 32'h1FFFFFF5; //1.0842014616272E-19
        //ans = 1.0842014616272E-19 | 1FFFFFF5
        #1000
         $display("%b + %b = %b, overflow:%b", x, y, z, overflow);
        if (z != 32'h1FFFFFF5 || overflow != 2'b00) begin
            $display("Wrong Answer!");
        end
        else begin
            $display("Correct!");
        end

        x = 32'h00000000; //0
        y = 32'h4248CCCC; //50.2
        //ans = 50.2 | 4248CCCC
        #1000
         $display("%b + %b = %b, overflow:%b", x, y, z, overflow);
        if (z != 32'h4248CCCC || overflow != 2'b00) begin
            $display("Wrong Answer!");
        end
        else begin
            $display("Correct!");
        end

        x = 32'hBF000000; //-0.5
        y = 32'h3F99999A; //1.2
        //ans = 0.7 | 3f333334
        #1000
         $display("%b + %b = %b, overflow:%b", x, y, z, overflow);
        if (z != 32'h3F333334 || overflow != 2'b00) begin
            $display("Wrong Answer!");
        end
        else begin
            $display("Correct!");
        end

        x=32'h7F800000;
        y=32'h1FFFFFF0;
        //ans = indefinite, overflow = 2'b11
        #1000
         $display("%b + %b = %b, overflow:%b", x, y, z, overflow);
        if (overflow != 2'b11) begin
            $display("Wrong Answer!");
        end
        else begin
            $display("Correct!");
        end

        x=32'h7F800003;
        y=32'h7F800004;
        //y = NaN, overflow = 2'b11
        #1000
         $display("%b + %b = %b, overflow:%b", x, y, z, overflow);
        if (overflow != 2'b11) begin
            $display("Wrong Answer!");
        end
        else begin
            $display("Correct!");
        end

        x=32'h00800010;
        y=32'h80800001;
        //underflow, ans = 0000001E, overflow = 2'b10
        //debug: the change of overflow (10/01) is much faster than z, we have to choose the delay carefully
        #100
         $display("%b + %b = %b, overflow:%b", x, y, z, overflow);
        if (z != 32'h0000001E || overflow != 2'b10) begin
            $display("Wrong Answer!");
        end
        else begin
            $display("Correct!");
        end

        x=32'h7F7FFFFF;
        y=32'h7F7FFFFF;
        //overflow, ans = 7FFFFFFF, overflow = 2'b01
        #120
         $display("%b + %b = %b, overflow:%b", x, y, z, overflow);
        if (z != 32'h7FFFFFFF || overflow != 2'b01) begin
            $display("Wrong Answer!");
        end
        else begin
            $display("Correct!");
        end

        /* test cases randomly generated by myself (See the source code at generator.cpp) */

        x = 32'h4c842de0;
        y = 32'h4e48c568;
        #1000
         $display("%b + %b = %b, overflow:%b", x, y, z, overflow);
        if (z != 32'h4e594b24 || overflow != 2'b00) begin
            $display("Wrong Answer!");
        end
        else begin
            $display("Correct!");
        end

        x = 32'h4e32a8b6;
        y = 32'hce9b8a1f;
        #1000
         $display("%b + %b = %b, overflow:%b", x, y, z, overflow);
        if (z != 32'hce046b88 || overflow != 2'b00) begin
            $display("Wrong Answer!");
        end
        else begin
            $display("Correct!");
        end

        x = 32'hce28495b;
        y = 32'hce904f23;
        #1000
         $display("%b + %b = %b, overflow:%b", x, y, z, overflow);
        if (z != 32'hcee473d0 || overflow != 2'b00) begin
            $display("Wrong Answer!");
        end
        else begin
            $display("Correct!");
        end

        x = 32'h4d905610;
        y = 32'h4c3c1864;
        #1000
         $display("%b + %b = %b, overflow:%b", x, y, z, overflow);
        if (z != 32'h4da7d91c || overflow != 2'b00) begin
            $display("Wrong Answer!");
        end
        else begin
            $display("Correct!");
        end

        x = 32'hcd6f9230;
        y = 32'h4e0e5d70;
        #1000
         $display("%b + %b = %b, overflow:%b", x, y, z, overflow);
        if (z != 32'h4da4f1c8 || overflow != 2'b00) begin
            $display("Wrong Answer!");
        end
        else begin
            $display("Correct!");
        end

        x = 32'hce55e840;
        y = 32'h4c65a940;
        #1000
         $display("%b + %b = %b, overflow:%b", x, y, z, overflow);
        if (z != 32'hce478dac || overflow != 2'b00) begin
            $display("Wrong Answer!");
        end
        else begin
            $display("Correct!");
        end

        x = 32'hcee1599c;
        y = 32'hce926b1c;
        #1000
         $display("%b + %b = %b, overflow:%b", x, y, z, overflow);
        if (z != 32'hcf39e25c || overflow != 2'b00) begin
            $display("Wrong Answer!");
        end
        else begin
            $display("Correct!");
        end

        x = 32'h4ea27aab;
        y = 32'hce9ff632;
        #1000
         $display("%b + %b = %b, overflow:%b", x, y, z, overflow);
        if (z != 32'h4ba11e40 || overflow != 2'b00) begin
            $display("Wrong Answer!");
        end
        else begin
            $display("Correct!");
        end

        $finish;
    end

endmodule
