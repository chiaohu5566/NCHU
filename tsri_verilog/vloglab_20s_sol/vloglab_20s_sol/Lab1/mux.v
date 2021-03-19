`define dly_and 1
`define dly_or 2
module mux (out,a,b,sel);

// Port declarations
  output out;
  input a,b,sel;

// The netlist
  not  u1(sel_, sel);
  and #`dly_and u2(a1, a, sel_); 
  and #`dly_and u3(b1, b, sel);
  or #`dly_or u4(out, a1, b1);




endmodule
