module LBP ( clk, reset, gray_addr, gray_req, gray_data, lbp_addr, lbp_write, lbp_data, finish);
input   	clk;
input   	reset;
output  [5:0] 	gray_addr;
output         	gray_req;
input   [7:0] 	gray_data;
output  [5:0] 	lbp_addr;
output  	lbp_write;
output  [7:0] 	lbp_data;
output  	finish;

//===========================================================================



reg [7:0] lbp_data;
reg [7:0] x, y, k, m;
reg [5:0] x_addr, y_addr;
reg [5:0] gray_addr, lbp_addr, gray_addr_tmp;
reg gray_req;
reg lbp_valid;
reg finish;
reg [1:0] state;
parameter IDLE = 2'b00, LOAD = 2'b01, WRITE = 2'b11, COMP = 2'b10;

reg [7:0] LBP_bin_1, LBP_bin_2, LBP_bin_3, LBP_bin_4, LBP_bin_5, LBP_bin_6, LBP_bin_7, LBP_bin_8, LBP_bin_9;

reg [7:0] LBP_value;

wire	lbp_write = lbp_valid & clk;

always@(posedge clk or posedge reset) begin
if ( reset ) begin
	state <= IDLE; gray_req <= 0; finish <= 0; x <= 2; y <= 2; k <= 1; lbp_valid <= 0;
end
else begin
	case (state)
	IDLE : begin 
		state <=  LOAD;  
		gray_req <= 0; 
		x <= 2; y <= 2; k <= 1;
		lbp_valid <= 0;
		finish <= 0;
		end
	LOAD : begin
		lbp_valid <= 0;
		gray_req <= 1;
		k <= k + 1;
		if (k == 9) begin state <= COMP;   gray_req <= 1;end
		else state <= LOAD;
		end
	COMP : begin
		state <= WRITE;
		gray_req <= 0;
		end
	WRITE : begin
		lbp_valid <= 1;
		if ((x==7)&(y==7)) begin state <= IDLE; finish <= 1; gray_req <= 0; end
		else if (x == 7) begin y <= y + 1; x <= 2; k<= 1; state<= LOAD; gray_req <= 0;end
		else begin x <= x + 1; k<= 1; state<= LOAD; gray_req <= 0;end
		end
	endcase
end
end

always@(posedge clk)
	m <= k;

always@(*) begin
		case (k)
		1 : begin y_addr = y - 1; x_addr = x - 1; end
		2 : begin y_addr = y - 1; x_addr = x    ; end  
		3 : begin y_addr = y - 1; x_addr = x + 1; end
		4 : begin y_addr = y    ; x_addr = x - 1; end
		5 : begin y_addr = y    ; x_addr = x    ; end
		6 : begin y_addr = y    ; x_addr = x + 1; end
		7 : begin y_addr = y + 1; x_addr = x - 1; end
		8 : begin y_addr = y + 1; x_addr = x    ; end
		9 : begin y_addr = y + 1; x_addr = x + 1; end
		endcase
		gray_addr_tmp = ((y_addr-1)<<3 ) + (x_addr-1);
		
end

always@(posedge clk) begin
		gray_addr = gray_addr_tmp;
end

always@(posedge clk) begin
 case (m)
 	1: LBP_bin_1 <= gray_data;
	2: LBP_bin_2 <= gray_data;
	3: LBP_bin_3 <= gray_data;
	4: LBP_bin_4 <= gray_data;
	5: LBP_bin_5 <= gray_data;
	6: LBP_bin_6 <= gray_data;
	7: LBP_bin_7 <= gray_data;
	8: LBP_bin_8 <= gray_data;
	9: LBP_bin_9 <= gray_data;
 endcase
end

always@(*) begin 
 	LBP_value[0] = (LBP_bin_1 >= LBP_bin_5) ? 1 : 0;
	LBP_value[1] = (LBP_bin_2 >= LBP_bin_5) ? 1 : 0;
	LBP_value[2] = (LBP_bin_3 >= LBP_bin_5) ? 1 : 0;
	LBP_value[3] = (LBP_bin_4 >= LBP_bin_5) ? 1 : 0;
	LBP_value[4] = (LBP_bin_6 >= LBP_bin_5) ? 1 : 0;
	LBP_value[5] = (LBP_bin_7 >= LBP_bin_5) ? 1 : 0;
	LBP_value[6] = (LBP_bin_8 >= LBP_bin_5) ? 1 : 0;
	LBP_value[7] = (LBP_bin_9 >= LBP_bin_5) ? 1 : 0;
end

always@(posedge clk) 
	lbp_addr <= ((y-1)<<3) + (x-1);

always@(posedge clk) 
	lbp_data <= LBP_value;


endmodule
