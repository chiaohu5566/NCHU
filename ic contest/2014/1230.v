module STI_DAC(clk ,reset, load, pi_data, pi_length, pi_fill, pi_msb, pi_low, pi_end,
	       so_data, so_valid,
	       oem_finish, oem_dataout, oem_addr,
	       odd1_wr, odd2_wr, odd3_wr, odd4_wr, even1_wr, even2_wr, even3_wr, even4_wr ,count ,count_0 ,count_mem);

input		clk, reset;
input		load,pi_msb, pi_low, pi_end; 
input	[15:0]	pi_data;
input	[1:0]	pi_length;
input		pi_fill;
output reg	 so_data,so_valid;
output reg oem_finish, odd1_wr, odd2_wr, odd3_wr, odd4_wr, even1_wr, even2_wr, even3_wr, even4_wr;
output reg [4:0] oem_addr;
output reg [7:0] oem_dataout;
output reg  [4:0]  count;
output reg  [5:0]  count_0; 


reg  [7:0]  bit8;
reg  [15:0] bit16;
reg  [23:0] bit24;
reg  [31:0] bit32;
output reg  [7:0]  count_mem;


//=========================================================
//==========sign extenson==================================
always@(posedge load)begin
  case(pi_length)
    2'b00:begin   //8bit
      count <=5'b00111;
	  count_0<=5'b00000;
	  if(pi_low)
	    bit8 <=pi_data[15:8];
      else
	    bit8 <=pi_data[7:0];
	end
	2'b01:begin   //16bit
	  bit16 <=pi_data;	
	  count <=5'b01111;
	  count_0<=5'b00000;
	end
	2'b10:begin   //24bit
	  count <=5'b10111;
	  count_0<=5'b00000;
	  if(pi_fill)
	    bit24 <={pi_data,8'b0};
	  else 
	    bit24 <={8'b0,pi_data};
	end
	2'b11:begin   //32bit
	  count <=5'b11111;
	  count_0<=5'b00000;
	  if(pi_fill)
	    bit32 <={pi_data,16'b0};
      else
        bit32 <={16'b0,pi_data};		
	end	
  endcase
end  
//============counter========================================
always@(posedge clk)begin
  if(reset) 
    so_valid <= 0;
  else if(load)
    so_valid<=1;
  else begin 
    if(so_valid)begin
      if(pi_msb)begin
	    if(count != 0)
	      count = count-1;
	    else
          so_valid <=1'b0;	  
	  end
	  else begin
	    if(count_0 != (count+1))
          count_0 = (count_0 +1);
        else
          so_valid <=1'b0;
	  end	
    end
  end	
end

//============so_data output=================================
always@(posedge clk )begin
  case(pi_length)
    2'b00:begin
      if(so_valid)begin
        if(pi_msb)
          so_data <=bit8[count];
        else begin
          if(count_0 <= count)
            so_data <=bit8[(count_0-1)];
          else
            so_data <= 0; 
        end			
      end
      else 
        so_data <= 1'b0;
    end
    2'b01:begin
      if(so_valid)begin
        if(pi_msb)
          so_data <=bit16[count];
        else begin
          if(count_0 <= count)
            so_data <=bit16[(count_0-1)];
          else
            so_data <= 0; 
        end			
      end
      else 
        so_data <= 1'b0;
    end
    2'b10:begin
      if(so_valid)begin
        if(pi_msb)
          so_data <=bit24[count];
        else begin
          if(count_0 <= count)
            so_data <=bit24[(count_0-1)];
          else
            so_data <= 0;
        end			
      end
      else 
        so_data <= 1'b0;
    end
	2'b11:begin
      if(so_valid)begin
        if(pi_msb)
          so_data <=bit32[count];
        else begin
          if(count_0 <= count)
            so_data <=bit32[(count_0-1)];
          else
            so_data <= 0; 
        end			
      end
      else 
        so_data <= 1'b0;
    end
  endcase      
end    
//===============
always@(posedge clk)begin
  if(reset)
    count_mem<=0;
  else begin
    if(so_valid)
      count_mem <= count_mem+1;
    else
      count_mem <= count_mem;
  end	  
end
always@(posedge clk)begin
  if(so_valid)begin
    if((count_mem%2)==0)begin
	  odd1_wr <=1;
	  even1_wr<=0; 
	end  
	else begin
      even1_wr<=1;
      odd1_wr <=0;	  
    end
  end
  else begin
    even1_wr <=0;
    odd1_wr <=0;
  end	
end
 
endmodule
