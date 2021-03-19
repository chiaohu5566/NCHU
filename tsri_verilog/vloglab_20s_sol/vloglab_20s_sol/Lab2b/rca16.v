module rca16(sum, c_out, a, b, c_in);
output	[15:0]	sum;
output		c_out;
input	[15:0]	a, b;
input		c_in;

wire 		c_in4, c_in8, c_in12;

rca4 u1(.sum(sum[3:0]), .c_out(c_in4), .a(a[3:0]), .b(b[3:0]), .c_in(c_in));
rca4 u2(.sum(sum[7:4]), .c_out(c_in8), .a(a[7:4]), .b(b[7:4]), .c_in(c_in4));
rca4 u3(.sum(sum[11:8]), .c_out(c_in12), .a(a[11:8]), .b(b[11:8]), .c_in(c_in8));
rca4 u4(.sum(sum[15:12]), .c_out(c_out), .a(a[15:12]), .b(b[15:12]), .c_in(c_in12));

endmodule



module rca4(sum, c_out, a, b, c_in);
output	[3:0]	sum;
output		c_out;
input	[3:0]	a, b;
input		c_in;

wire 		c_in2, c_in3, c_in4;

Add_full u1(.sum(sum[0]), .c_out(c_in2), .a(a[0]), .b(b[0]), .c_in(c_in));
Add_full u2(.sum(sum[1]), .c_out(c_in3), .a(a[1]), .b(b[1]), .c_in(c_in2));
Add_full u3(.sum(sum[2]), .c_out(c_in4), .a(a[2]), .b(b[2]), .c_in(c_in3));
Add_full u4(.sum(sum[3]), .c_out(c_out), .a(a[3]), .b(b[3]), .c_in(c_in4));

endmodule


module Add_full(sum, c_out, a, b, c_in);
output	sum, c_out;
input	a, b, c_in;

wire	m1, m2, m3;
Add_half u1(.sum(m1), .c_out(m2), .a(a), .b(b));
Add_half u2(.sum(sum), .c_out(m3), .a(c_in), .b(m1));
or u3(c_out, m2, m3);
endmodule

module Add_half(sum, c_out, a, b);
output	sum, c_out;
input	a, b;

xor(sum, a, b);
and(c_out, a, b); 

endmodule
