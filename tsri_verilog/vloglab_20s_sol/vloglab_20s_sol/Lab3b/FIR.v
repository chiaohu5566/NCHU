module FIR(Dout, Din, clk, reset);

parameter b0=7;
parameter b1=17;
parameter b2=32;
parameter b3=46;
parameter b4=52;
parameter b5=46;
parameter b6=32;
parameter b7=17;
parameter b8=7;

output wire [17:0] Dout;
input [7:0] Din;
input clk, reset;

reg [7:0] SR1, SR2, SR3, SR4, SR5, SR6, SR7, SR8; 

assign Dout = Din*b0 + SR1*b1 + SR2*b2 + SR3*b3 + SR4*b4 + SR5*b5 + SR6*b6 + SR7*b7 + SR8*b8  ;


always@(posedge clk) begin
if (reset) begin
	SR1 <= 0; SR2 <= 0; SR3 <= 0; SR4 <= 0;
	SR5 <= 0; SR6 <= 0; SR7 <= 0; SR8 <= 0;
end
else begin
	SR1 <= Din;
	SR2 <=  SR1;
	SR3 <=  SR2;
	SR4 <=  SR3;
	SR5 <=  SR4;
	SR6 <=  SR5;
	SR7 <=  SR6;
	SR8 <=  SR7;
end
end


endmodule
