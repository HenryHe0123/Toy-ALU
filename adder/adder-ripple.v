/* ACM Class System (I) Fall Assignment 1
 *
 *
 * Implement your naive adder here
 * 
 * GUIDE:
 *   1. Create a RTL project in Vivado
 *   2. Put this file into `Sources'
 *   3. Put `test_adder.v' into `Simulation Sources'
 *   4. Run Behavioral Simulation
 *   5. Make sure to run at least 100 steps during the simulation (usually 100ns)
 *   6. You can see the results in `Tcl console'
 *
 */

module adder(
        input       [15:0]          a,
        input       [15:0]          b,
        output      [15:0]          sum,
        output                      carry
    );
	wire [15:0] c;
	assign carry = c[15];
	full_adder fadd[15:0](
    	.a(a),
    	.b(b),
    	.cin({c[14:0], 1'b0}),
    	.s(sum),
    	.cout(c)
	);
    
endmodule //adder

module full_adder(
        input a, b, cin,
        output s, cout
    );
	assign s = a ^ b ^ cin;
	assign cout = (a & b) | (a & cin) | (b & cin);

endmodule //full_adder
