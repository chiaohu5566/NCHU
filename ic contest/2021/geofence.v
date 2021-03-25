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
reg l_done, sort_done;
reg [3:0] count;
reg [1:0] c;

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
    if (done) n_state = DONE;
    else n_state = OPT;
  end
  DONE : begin
  
  end	
//  default : 
  endcase
end 
//=======================LOAD==========================
always @(posedge clk)begin   //count
  if (c_state == LOAD)begin
    if (reset || l_done  )  
      count <= 2'b0;
    else  count <= count + 2'b1;
  end
  else count <= 2'b0;     
end
//-------------------------------------------
always @(posedge clk)begin
//  if (c_state == LOAD)begin
    if (count <=6)  l_done <= 0;
    else  l_done <= 1;
//  end
//  else l_done <= 0;  
end    
  
always @(posedge clk)begin     //load data
  if (c_state == LOAD)begin
    x[count] <= X;
    y[count] <= Y;
    r[count] <= R;
  end
end
//-----------------vector--------------------
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

//=======================SORT==========================
always @(posedge clk)begin
  if (c_state == SORT)begin
    case (c)
	    2'b00 : begin
	      if (c1) begin
          x[1] <= x[2]; y[1] <= y[2];
	        x[2] <= x[1]; y[2] <= y[1];
          r[1] <= r[2]; r[2] <= r[1];          
        end
        else  c <= 2'b01;
	    end
	    2'b01 : begin
        if (c2) begin
          x[2] <= x[3]; y[2] <= y[3];
	        x[3] <= x[2]; y[3] <= y[2];
          r[2] <= r[3]; r[3] <= r[2]; 	
        end
        else  c <= 2'b10;
    	end
    	2'b10 : begin
	      if (c3)begin
          x[3] <= x[4]; y[3] <= y[4];
	        x[4] <= x[3]; y[4] <= y[3];
          r[3] <= r[4]; r[4] <= r[3]; 
        end
        else  c <= 2'b11;  	
	    end
	    2'b11 : begin
        if (c4)begin
	        x[4] <= x[5]; y[4] <= y[5];
	        x[5] <= x[4]; y[5] <= y[4];	
          r[4] <= r[5]; r[5] <= r[4]; 
        end
        else if (c1==0 && c2==0 && c3==0 && c4==0) begin
          sort_done <= 1;
        end
        else  c <= 2'b00;  
    	end	
    endcase	
  end
  else begin
    c <= 0;
    sort_done <= 0;
  end
end

//=======================OPT===========================

//------------------area----------------------------------------------------------------------------
wire [19:0] area = ((x[5]*y[4])-(x[4]*y[5]) + (x[4]*y[3])-(x[3]*y[4]) + (x[3]*y[2])-(x[2]*y[3]) 
                  + (x[2]*y[1])-(x[1]*y[2]) + (x[1]*y[0])-(x[0]*y[1]) + (x[0]*y[5])-(x[5]*y[0]));

assign area = area >>> 1 ;                  
//-----------------length--------------------
wire signed [9:0] length_x_1 = x[0] - x[1];
wire signed [9:0] length_y_1 = y[0] - y[1];

wire signed [9:0] length_x_2 = x[1] - x[2];
wire signed [9:0] length_y_2 = y[1] - y[2];

wire signed [9:0] length_x_3 = x[2] - x[3];
wire signed [9:0] length_y_3 = y[2] - y[3];

wire signed [9:0] length_x_4 = x[3] - x[4];
wire signed [9:0] length_y_4 = y[3] - y[4];

wire signed [9:0] length_x_5 = x[4] - x[5];
wire signed [9:0] length_y_5 = y[4] - y[5];

wire signed [9:0] length_x_6 = x[5] - x[0];
wire signed [9:0] length_y_6 = y[5] - y[0];
//---------------------------------------------------------------------------
//SS sum of square
wire signed [19:0] SS_1 = (length_x_1*length_x_1) + (length_y_1*length_y_1);
wire signed [19:0] SS_2 = (length_x_2*length_x_2) + (length_y_2*length_y_2);
wire signed [19:0] SS_3 = (length_x_3*length_x_3) + (length_y_3*length_y_3);
wire signed [19:0] SS_4 = (length_x_4*length_x_4) + (length_y_4*length_y_4);
wire signed [19:0] SS_5 = (length_x_5*length_x_5) + (length_y_5*length_y_5);
wire signed [19:0] SS_6 = (length_x_6*length_x_6) + (length_y_6*length_y_6);
//---------------------------------------------------------------------------




		  
endmodule


//=================================================================================================================
//square root

module sqrt
    #(parameter DATA_IN_WIDTH = 20)
    (
    input   wire                                    clk,reset,
    input   wire    signed  [ DATA_IN_WIDTH-1:  0 ] din,
    output  reg             [ DATA_IN_WIDTH-1:  0 ] dout
    );

localparam DATA_WIDTH_SQUARING = (2*DATA_IN_WIDTH) - 1;

wire    [ DATA_WIDTH_SQUARING-1 :  0 ] din_2 = din;
wire     [ DATA_IN_WIDTH-1:  0 ] y;
localparam DATA_WIDTH_SUM = DATA_WIDTH_SQUARING+1;
wire    [ DATA_WIDTH_SUM-1 :  0 ] x = din_2;

assign y[DATA_IN_WIDTH-1] = x[(DATA_WIDTH_SUM-1)-:2] == 2'b00 ? 1'b0 : 1'b1;
genvar k;
generate
    for(k = DATA_IN_WIDTH-2; k >= 0; k = k - 1)
    begin: gen
        assign y[k] = x[(DATA_WIDTH_SUM-1)-:(2*(DATA_IN_WIDTH-k))] < 
        {y[DATA_IN_WIDTH-1:k+1],1'b1}*{y[DATA_IN_WIDTH-1:k+1],1'b1} ? 1'b0 : 1'b1;
    end
endgenerate

always@(posedge clk or posedge reset)begin
	if(reset)begin
		dout <= 0;
	end else begin
		dout <= y;
	end
end


endmodule