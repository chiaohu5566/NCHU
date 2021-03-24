module geofence ( clk,reset,X,Y,R,valid,is_inside);
input clk;
input reset;
input [9:0] X;
input [9:0] Y;
input [10:0] R;
output valid;
output is_inside;

reg [1:0] c_state, n_state;
reg signed [9:0] x [0:5];
reg signed [9:0] y [0:5];
reg [10:0] r [0:5];
reg valid;
reg is_inside;
reg l_done;
reg vector;
reg [3:0] count;
reg [1:0] c ;
reg sort_done;

//==============FSM============== 
parameter  LOAD = 2'b00,
		  SORT = 2'b01,
		  OPT  = 2'b10,
		  DONE = 2'b11;
//==============FSM==============
always @(posedge clk or posedge reset)begin
  if (reset)  c_state <= LOAD;
  else  c_state <= n_state;
end

always @(*) begin
  case (c_state)
  LOAD : begin
    if (l_done)  n_state = SORT;
    else  n_state = LOAD;
  end
  SORT : begin
    if (sort_done) n_state = OPT;
    else n_state = SORT;
  end
  OPT  : begin

  end
  DONE : begin
  
  end	
//  default : 
  endcase
end 

always @(posedge clk)begin   //count
  if (c_state == LOAD)begin
    if (reset || l_done  )  
    count <= 2'b0;
    else  count <= count + 2'b1;
  end
  else count <= 2'b0;     
end
always @(posedge clk)begin
  if (c_state == LOAD)begin
    if (count <=6)  l_done <= 0;
    else  l_done <= 1;
  end
  else l_done <= 0;  
end    
always @(posedge clk)begin     //load data
  if (c_state == LOAD)begin
    x[count] <= X;
    y[count] <= Y;
    r[count] <= R;
    vector <= 1;
  end
  else if (c_state == OPT)begin
    vector <= 0;
  end
end
//==================vector===================
wire signed [9:0] v1_x = x[1] - x[0];
wire signed [9:0] v1_y = y[1] - y[0];

wire signed [9:0] v2_x = x[2] - x[0];
wire signed [9:0] v2_y = y[2] - y[0];

wire signed [9:0] v3_x = x[3] - x[0];
wire signed [9:0] v3_y = y[3] - y[0];

wire signed [9:0] v4_x = x[4] - x[0];
wire signed [9:0] v4_y = y[4] - y[0];

wire signed [9:0] v5_x = x[5] - x[0];
wire signed [9:0] v5_y = y[5] - y[0];

wire [19:0] c12 = (v1_x*v2_y) - (v2_x*v1_y);
wire [19:0] c23 = (v2_x*v3_y) - (v3_x*v2_y);
wire [19:0] c34 = (v3_x*v4_y) - (v4_x*v3_y);
wire [19:0] c45 = (v4_x*v5_y) - (v5_x*v4_y);
wire c1, c2, c3, c4;

assign c1 = (c12[19]) ? 0 : 1 ;
assign c2 = (c23[19]) ? 0 : 1 ;
assign c3 = (c34[19]) ? 0 : 1 ;
assign c4 = (c45[19]) ? 0 : 1 ;
//==================vector===================

always @(posedge clk)begin
  if (c_state == SORT)begin
    case (c)
	    2'b00 : begin
	      if (c1) begin
          x[1] <= x[2]; y[1] <= y[2];
	        x[2] <= x[1]; y[2] <= y[1];          
        end
        else
          c <= 2'b01;
	    end
	    2'b01 : begin
        if (c2) begin
          x[2] <= x[3]; y[2] <= y[3];
	        x[3] <= x[2]; y[3] <= y[2];	
        end
        else
          c <= 2'b10;
    	end
    	2'b10 : begin
	      if (c3)begin
          x[3] <= x[4]; y[3] <= y[4];
	        x[4] <= x[3]; y[4] <= y[3];
        end
        else 
          c <= 2'b11;  	
	    end
	    2'b11 : begin
        if (c4)begin
	        x[4] <= x[5]; y[4] <= y[5];
	        x[5] <= x[4]; y[5] <= y[4];	
        end
        else if (c1==0 && c2==0 && c3==0 && c4==0) begin
          sort_done <= 1;
        end
        else
          c <= 2'b00;  
    	end	
    endcase	
  end
  else begin
    c <= 0;
    sort_done <= 0;
  end
end



		  
endmodule

