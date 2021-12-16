module STI_DAC(clk ,reset, load, pi_data, pi_length, pi_fill, pi_msb, pi_low, pi_end,
	             so_data, so_valid, 
	             oem_finish, oem_dataout, oem_addr,
	             odd1_wr, odd2_wr, odd3_wr, odd4_wr, even1_wr, even2_wr, even3_wr, even4_wr);

input		clk, reset;
input		load, pi_msb, pi_low, pi_end; 
input	[15:0]	pi_data;
input	[1:0]	pi_length;
input		pi_fill;
output reg	so_data, so_valid;

output reg oem_finish, odd1_wr, odd2_wr, odd3_wr, odd4_wr, even1_wr, even2_wr, even3_wr, even4_wr;
output reg [4:0] oem_addr;
output [7:0] oem_dataout;

/*==============================================================================

Zheng Xun,Yeh
Date : 2021/12/15

==============================================================================*/


reg [1:0] cs, ns;
parameter IDLE = 2'd0;
parameter LOAD = 2'd1;
parameter OUTPUT = 2'd2;
parameter DONE = 2'd3;

reg [31:0] data;


//==============================================================================
//FSM
always@(posedge clk or posedge reset)begin
    if(reset) cs <= IDLE;
    else cs <= ns;
end

always@(*)begin
    case(cs)
        IDLE:begin
            if(load) ns = LOAD;
	    	else ns = IDLE;
		end
		LOAD:begin
            ns = OUTPUT;
		end
		OUTPUT:begin
        	if(OUPUT_cnt == 4'd0 && pi_end == 1'd1) ns = DONE;
	    	else if(OUPUT_cnt == 4'd0) ns = IDLE;
	    	else ns = OUTPUT;
		end
		DONE:begin
            ns = DONE;
		end
		default: ns = IDLE;
    endcase
end
//==============================================================================
//OUTPUT state counter

reg [4:0]  OUPUT_cnt;

always@(posedge clk or posedge reset)
begin
	if(reset) OUPUT_cnt <= 5'd31;
	else if(ns == LOAD)
	begin
		case(pi_length)
		2'b00: OUPUT_cnt <= 5'd7;
		2'b01: OUPUT_cnt <= 5'd15; 
		2'b10: OUPUT_cnt <= 5'd23;
		2'b11: OUPUT_cnt <= 5'd31;
		endcase
	end
	else if(cs == OUTPUT) OUPUT_cnt <= OUPUT_cnt - 4'd1;
end
//==============================================================================
//Serial Transmitter Interface, STI

always@(*)begin
	case(pi_length)
	2'b00:begin //8bit
		if(pi_low)begin 
			data[31:24] = pi_data[15:8];
			data[23:0] = 24'd0; 
		end
		else begin
			data[31:24] = pi_data[7:0];
			data[23:0] = 24'd0; 
		end
	end
	2'b01:begin //16bit
		data[31:16] = pi_data[15:0];
		data[15:0] = 16'd0; 
	end
	2'b10:begin //24bit
		if(pi_fill)begin
			data[31:16] = pi_data[15:0];
			data[15:0] = 16'd0;
		end
		else begin
			data[31:24] = 8'd0;
			data[23:8] = pi_data[15:0];
			data[7:0] = 8'd0; 
		end
	end
	2'b11:begin //32bit
		if(pi_fill)begin
			data[31:16] = pi_data[15:0];
			data[15:0] = 16'd0;
		end
		else begin
			data[31:16] = 16'd0;
			data[15:0] = pi_data[15:0];
		end
	end
	default: data = 32'd0;
	endcase
end
//==============================================================================
//so_valid
always@(posedge clk or posedge reset)begin
	if(reset) so_valid <= 1'd0;
	else if(ns == OUTPUT) so_valid <= 1'd1;
	else so_valid <= 1'd0;
end
//==============================================================================
//data_index
reg [4:0] data_index;

always@(posedge clk or posedge reset)begin
	if(reset) data_index <= 5'd0;
	else if(ns == LOAD)
	begin
		if(pi_msb) data_index <= 5'd31;
		else
		begin
			case(pi_length)
			2'b00: data_index <= 5'd24;
			2'b01: data_index <= 5'd16; 
			2'b10: data_index <= 5'd8;
			2'b11: data_index <= 5'd0;
			endcase
		end
	end
	else if(ns == OUTPUT)begin
		if(pi_msb) data_index <= data_index - 5'd1;
		else data_index <= data_index + 5'd1;
	end
	
	
end
//==============================================================================
//so_data
always@(posedge clk or posedge reset)begin
	if(reset) so_data <= 1'd0;
	else so_data <= data[data_index];
end
//==============================================================================
//Data Arrange Controller, DAC
reg [7:0] DAC;  
reg [3:0] cnt;
reg [7:0] mem_cnt;
reg switch;

//==============================================================================
//memory switch row
always@(posedge clk or posedge reset)begin
	if(reset) switch <= 1'd0;
	else if(mem_cnt[3:0] == 4'd8) switch <= 1'd1;
	else if(mem_cnt[3:0] == 4'd0) switch <= 1'd0;
end

//==============================================================================
//oem_dataout


always@(posedge clk or posedge reset)begin
	if(reset) DAC <= 8'd0;
	else if(so_valid)begin
		DAC <= DAC << 8'd1;
		DAC[0] <= so_data; 
	end
	else if(pi_end)begin
		DAC <= 8'd0;
	end
end

assign oem_dataout = DAC;
//==============================================================================
//cnt
always@(posedge clk or posedge reset)begin
	if(reset) cnt <= 4'd0;
	else if(so_valid) cnt <= cnt + 4'd1;
	else if(pi_end && cs == DONE) cnt <= cnt + 4'd1;
end

//mem_cnt
always@(posedge clk or posedge reset)begin
	if(reset) mem_cnt <= 8'd0;
	else if(cnt == 4'd7 || cnt == 4'd15) mem_cnt <= mem_cnt + 8'd1;
end

//==============================================================================
//address
reg [4:0] buffer;

always@(posedge clk or posedge reset)begin
	if(reset) buffer <= 5'd0;
	else if(cnt == 4'd15) buffer <= buffer + 5'd1;
end

always@(posedge clk or posedge reset)begin
	if(reset) oem_addr <= 5'd0;
	else oem_addr <= buffer;
end

//finish
always@(posedge clk or posedge reset)begin
	if(reset) oem_finish <= 1'd0;
	else if(mem_cnt == 8'd0 && cnt == 4'd0 && pi_end == 1'd1) oem_finish <= 1'd1;
end

//memory write
always@(posedge clk or posedge reset)begin
	if(reset) odd1_wr <= 1'd0;
	else if(mem_cnt <= 8'd63 && cnt == 4'd7 && switch == 1'd0) odd1_wr <= 1'd1;
	else if(mem_cnt <= 8'd63 && cnt == 4'd15 && switch == 1'd1) odd1_wr <= 1'd1;
	else odd1_wr <= 1'd0;
end

always@(posedge clk or posedge reset)begin
	if(reset) even1_wr <= 1'd0;
	else if(mem_cnt <= 8'd63 && cnt == 4'd15 && switch == 1'd0) even1_wr <= 1'd1;
	else if(mem_cnt <= 8'd63 && cnt == 4'd7 && switch == 1'd1) even1_wr <= 1'd1;
	else even1_wr <= 1'd0;
end

always@(posedge clk or posedge reset)begin
	if(reset) odd2_wr <= 1'd0;
	else if(mem_cnt > 8'd63 && mem_cnt<=8'd127 && cnt == 4'd7 && switch == 1'd0) odd2_wr <= 1'd1;
	else if(mem_cnt > 8'd63 && mem_cnt<=8'd127 && cnt == 4'd15 && switch == 1'd1) odd2_wr <= 1'd1;
	else odd2_wr <= 1'd0;
end

always@(posedge clk or posedge reset)begin
	if(reset) even2_wr <= 1'd0;
	else if(mem_cnt > 8'd63 && mem_cnt<=8'd127 && cnt == 4'd15 && switch == 1'd0) even2_wr <= 1'd1;
	else if(mem_cnt > 8'd63 && mem_cnt<=8'd127 && cnt == 4'd7 && switch == 1'd1) even2_wr <= 1'd1;
	else even2_wr <= 1'd0;
end

always@(posedge clk or posedge reset)begin
	if(reset) odd3_wr <= 1'd0;
	else if(mem_cnt > 8'd127 && mem_cnt<=8'd191 && cnt == 4'd7 && switch == 1'd0) odd3_wr <= 1'd1;
	else if(mem_cnt > 8'd127 && mem_cnt<=8'd191 && cnt == 4'd15 && switch == 1'd1) odd3_wr <= 1'd1;
	else odd3_wr <= 1'd0;
end

always@(posedge clk or posedge reset)begin
	if(reset) even3_wr <= 1'd0;
	else if(mem_cnt > 8'd127 && mem_cnt<=8'd191 && cnt == 4'd15 && switch == 1'd0) even3_wr <= 1'd1;
	else if(mem_cnt > 8'd127 && mem_cnt<=8'd191 && cnt == 4'd7 && switch == 1'd1) even3_wr <= 1'd1;
	else even3_wr <= 1'd0;
end

always@(posedge clk or posedge reset)begin
	if(reset) odd4_wr <= 1'd0;
	else if(mem_cnt > 8'd191 && mem_cnt<=8'd255 && cnt == 4'd7 && switch == 1'd0) odd4_wr <= 1'd1;
	else if(mem_cnt > 8'd191 && mem_cnt<=8'd255 && cnt == 4'd15 && switch == 1'd1) odd4_wr <= 1'd1;
	else odd4_wr <= 1'd0;
end

always@(posedge clk or posedge reset)begin
	if(reset) even4_wr <= 1'd0;
	else if(mem_cnt > 8'd191 && mem_cnt<=8'd255 && cnt == 4'd15 && switch == 1'd0) even4_wr <= 1'd1;
	else if(mem_cnt > 8'd191 && mem_cnt<=8'd255 && cnt == 4'd7 && switch == 1'd1 ) even4_wr <= 1'd1;
	else even4_wr <= 1'd0;
end


endmodule
