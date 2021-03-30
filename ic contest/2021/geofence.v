module geofence ( clk,reset,X,Y,R,valid,is_inside);
input clk;
input reset;
input [9:0] X;
input [9:0] Y;
input [10:0] R;
output valid;
output is_inside;

reg [1:0] c_state, n_state;
reg  [9:0] x [0:5];
reg  [9:0] y [0:5];
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
    if (valid) n_state = LOAD;
    else n_state = OPT;
  end
//  DONE : begin
//    n_state <= LOAD;
//  end	
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
wire  [9:0] v1_x = x[1] - x[0];
wire  [9:0] v1_y = y[1] - y[0];

wire  [9:0] v2_x = x[2] - x[0];
wire  [9:0] v2_y = y[2] - y[0];

wire  [9:0] v3_x = x[3] - x[0];
wire  [9:0] v3_y = y[3] - y[0];

wire  [9:0] v4_x = x[4] - x[0];
wire  [9:0] v4_y = y[4] - y[0];

wire  [9:0] v5_x = x[5] - x[0];
wire  [9:0] v5_y = y[5] - y[0];

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
wire [79:0] area; 
assign area [19:0] = ((x[5]*y[4])-(x[4]*y[5]) + (x[4]*y[3])-(x[3]*y[4]) + (x[3]*y[2])-(x[2]*y[3])+ 
                 (x[2]*y[1])-(x[1]*y[2]) + (x[1]*y[0])-(x[0]*y[1]) + (x[0]*y[5])-(x[5]*y[0]));
assign area [79:20] = 0;
wire [79:0] areaa = area >> 1 ;                  
//-----------------length--------------------
wire  [9:0] length_x_1 = x[0] - x[1];
wire  [9:0] length_y_1 = y[0] - y[1];

wire  [9:0] length_x_2 = x[1] - x[2];
wire  [9:0] length_y_2 = y[1] - y[2];

wire  [9:0] length_x_3 = x[2] - x[3];
wire  [9:0] length_y_3 = y[2] - y[3];

wire  [9:0] length_x_4 = x[3] - x[4];
wire  [9:0] length_y_4 = y[3] - y[4];

wire  [9:0] length_x_5 = x[4] - x[5];
wire  [9:0] length_y_5 = y[4] - y[5];

wire  [9:0] length_x_6 = x[5] - x[0];
wire  [9:0] length_y_6 = y[5] - y[0];
//---------------------------------------------------------------------------
//SS sum of square
wire  [19:0] SS_1 = (length_x_1*length_x_1) + (length_y_1*length_y_1);
wire  [19:0] SS_2 = (length_x_2*length_x_2) + (length_y_2*length_y_2);
wire  [19:0] SS_3 = (length_x_3*length_x_3) + (length_y_3*length_y_3);
wire  [19:0] SS_4 = (length_x_4*length_x_4) + (length_y_4*length_y_4);
wire  [19:0] SS_5 = (length_x_5*length_x_5) + (length_y_5*length_y_5);
wire  [19:0] SS_6 = (length_x_6*length_x_6) + (length_y_6*length_y_6);
//---------------------------------------------------------------------------
//calculate length
wire [19:0] length_1, length_2, length_3, length_4, length_5, length_6;
sqrt u1 (.clk(clk), .reset(reset), .din(SS_1), .dout(length_1));
sqrt u2 (.clk(clk), .reset(reset), .din(SS_2), .dout(length_2));
sqrt u3 (.clk(clk), .reset(reset), .din(SS_3), .dout(length_3));
sqrt u4 (.clk(clk), .reset(reset), .din(SS_4), .dout(length_4));
sqrt u5 (.clk(clk), .reset(reset), .din(SS_5), .dout(length_5));
sqrt u6 (.clk(clk), .reset(reset), .din(SS_6), .dout(length_6));
//---------------------------------------------------------------------------
//bit extension
wire  [19:0] r0, r1, r2, r3, r4, r5;
assign r0 [10:0] = r[0],r0 [19:11] = 0;
assign r1 [10:0] = r[1],r1 [19:11] = 0;
assign r2 [10:0] = r[2],r2 [19:11] = 0;
assign r3 [10:0] = r[3],r3 [19:11] = 0;
assign r4 [10:0] = r[4],r4 [19:11] = 0;
assign r5 [10:0] = r[5],r5 [19:11] = 0;
//---------------------------------------------------------------------------
//Heron's formula
wire [19:0] s11 = r0 + r1 + length_1; wire [19:0] s1 = s11 >> 1;
wire [19:0] s22 = r1 + r2 + length_2; wire [19:0] s2 = s22 >> 1;
wire [19:0] s33 = r2 + r3 + length_3; wire [19:0] s3 = s33 >> 1;
wire [19:0] s44 = r3 + r4 + length_4; wire [19:0] s4 = s44 >> 1;
wire [19:0] s55 = r4 + r5 + length_5; wire [19:0] s5 = s55 >> 1;
wire [19:0] s66 = r5 + r0 + length_6; wire [19:0] s6 = s66 >> 1;
//---------------------------------------------------------------------------
//s(s-a)(s-b)(s-c)
wire [39:0] psum1_f =  s1 * (s1-r0);
wire [39:0] psum1_a =  (s1-r1) * (s1-length_1);

wire [39:0] psum2_f =  s2 * (s2-r1);
wire [39:0] psum2_a =  (s2-r2) * (s2-length_2);

wire [39:0] psum3_f =  s3 * (s3-r2);
wire [39:0] psum3_a =  (s3-r3) * (s3-length_3);

wire [39:0] psum4_f =  s4 * (s4-r3);
wire [39:0] psum4_a =  (s4-r4) * (s4-length_4);

wire [39:0] psum5_f =  s5 * (s5-r4);
wire [39:0] psum5_a =  (s5-r5) * (s5-length_5);

wire [39:0] psum6_f =  s6 * (s6-r5);
wire [39:0] psum6_a =  (s6-r0) * (s6-length_6);
//---------------------------------------------------------------------------
wire [39:0] area1_f, area1_a,
            area2_f, area2_a,
            area3_f, area3_a,
            area4_f, area4_a,
            area5_f, area5_a,
            area6_f, area6_a;
sqrt40 u7 (.clk(clk), .reset(reset), .din(psum1_f), .dout(area1_f));
sqrt40 u8 (.clk(clk), .reset(reset), .din(psum1_a), .dout(area1_a));
wire [79:0] area_1 = area1_f * area1_a;

sqrt40 u9 (.clk(clk), .reset(reset), .din(psum2_f), .dout(area2_f));
sqrt40 u10 (.clk(clk), .reset(reset), .din(psum2_a), .dout(area2_a));
wire [79:0] area_2 = area2_f * area2_a;

sqrt40 u11 (.clk(clk), .reset(reset), .din(psum3_f), .dout(area3_f));
sqrt40 u12 (.clk(clk), .reset(reset), .din(psum3_a), .dout(area3_a));
wire [79:0] area_3 = area3_f * area3_a;

sqrt40 u13 (.clk(clk), .reset(reset), .din(psum4_f), .dout(area4_f));
sqrt40 u14 (.clk(clk), .reset(reset), .din(psum4_a), .dout(area4_a));
wire [79:0] area_4 = area4_f * area4_a;

sqrt40 u15 (.clk(clk), .reset(reset), .din(psum5_f), .dout(area5_f));
sqrt40 u16 (.clk(clk), .reset(reset), .din(psum5_a), .dout(area5_a));
wire [79:0] area_5 = area5_f * area5_a;

sqrt40 u17 (.clk(clk), .reset(reset), .din(psum6_f), .dout(area6_f));
sqrt40 u18 (.clk(clk), .reset(reset), .din(psum6_a), .dout(area6_a));
wire [79:0] area_6 = area6_f * area6_a;

wire [79:0] area_com = area_1 + area_2 + area_3 + area_4 + area_5 + area_6 ;
wire [79:0] com_result = area_com - areaa;
//---------------------------------------------------------------------------
always @(posedge clk) begin
  if (c_state == OPT)begin
    if (com_result > 0) begin
      is_inside <= 0;
      valid <= 1;
    end
    else begin
      is_inside <= 1;
      valid <= 1;
    end
  end
  else  begin
    is_inside <= 0;
    valid <= 0;
  end  
end

endmodule


//=================================================================================================================
//square root 20bit

module sqrt
    #(parameter DATA_IN_WIDTH = 20)
    (
    input   wire                                    clk,reset,
    input   wire      [ DATA_IN_WIDTH-1:  0 ] din,
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

//=================================================================================================================
//square root 40bit

module sqrt40
    #(parameter DATA_IN_WIDTH = 40)
    (
    input   wire                                    clk,reset,
    input   wire      [ DATA_IN_WIDTH-1:  0 ] din,
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