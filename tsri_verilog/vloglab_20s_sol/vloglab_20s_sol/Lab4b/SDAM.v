
module SDAM( reset_n, scl, sda, avalid, aout, dvalid, dout);
input       reset_n;
input       scl;  
input       sda;

output	avalid, dvalid;
output	[7:0]	aout;
output	[15:0]	dout;





// ===== Coding your RTL below here ================================= 



parameter IDLE=2'b00, START=2'b01, WRA=2'b10, WRD=2'b11;
reg [3:0] tws_state;
reg [7:0] tws_waddr;
reg [15:0]  tws_wdata;
reg [15:0]  tws_rdata;
reg	[2:0]  wra_cnt;
reg	[3:0]  wrd_cnt;
reg	out_flag;

wire    scl;
wire    SDAi = sda ;

reg	avalid, dvalid;
reg	[7:0]	aout;
reg	[15:0]	dout;


always@(posedge scl or negedge reset_n ) begin
#(0.8);
if ( !reset_n ) begin
    	tws_state <=    IDLE;
    	wra_cnt <=   0;
        wrd_cnt <=   0;
	out_flag <= 0;
	tws_waddr <= 0;
	tws_wdata <= 0;
end
else begin
    case (tws_state)
    IDLE : begin //0
        wra_cnt <=   0;
        wrd_cnt <=   0;
	tws_waddr <= 0;
	tws_wdata <= 0;
	out_flag <= 0;
        if(SDAi==0) begin 
            tws_state <=   START;  // 1
            end
        end
    START : begin // 1
   	 wra_cnt <=   0;
         wrd_cnt <=   0;
	 tws_waddr <= 0;
	 tws_wdata <= 0;
        if(SDAi == 1) begin 
            tws_state <=   WRA; // 2
            end
        end
      // ==== READ ===================================
    WRA : begin // 2
        wra_cnt <=   wra_cnt + 1;
	wrd_cnt <=   0;
	tws_waddr[wra_cnt] <= SDAi;
        if (wra_cnt == 3'hf) begin 
            tws_state <=   WRD;
            end
        end
    WRD : begin // 3
        wrd_cnt <=   wrd_cnt + 1;
	wra_cnt <=   0;
	tws_wdata[wrd_cnt] <= SDAi;
        if (wrd_cnt == 4'hf) begin
            tws_state <=   IDLE;
	    out_flag <= 1;
            end
        end
    default : begin
    	wra_cnt <=   0;
        wrd_cnt <=   0;
    	tws_state <=   IDLE;
    end
    endcase
end
end

always@(*) begin
if(out_flag) begin
	avalid = 1;
	aout = tws_waddr;
	dvalid = 1;
	dout = tws_wdata;
end
else begin
	avalid = 0;
	dvalid = 0;
end
end




endmodule
