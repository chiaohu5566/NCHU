
`timescale 1ns/10ps

module  CONV(clk, reset, busy, ready, iaddr, idata, cwr, caddr_wr, cdata_wr, crd, caddr_rd, cdata_rd, csel, x_h, x_w, ifmap_0, ifmap_1, ifmap_2, ifmap_3, ifmap_4, ifmap_5, ifmap_6, 
             ifmap_7, ifmap_8, corner_count, kernel0_y, kernel1_y, current_state, next_state, psum_0, psum_1, side_count, pixel_first, mid_count, row_change, cur_layer, next_layer,
			 pool_cnt, pool_max_0, pool_max_1, flat_cnt, flatten);
input                   clk;
input			        reset;
input			        ready;	
input   signed	[19:0]	idata;	
input   signed	[19:0] 	cdata_rd;

output  reg 	        [11:0]	iaddr;	
output	reg	 	                cwr;
output  reg	            [11:0] 	caddr_wr;
output	reg     signed  [19:0] 	cdata_wr;
output	reg 		            crd;
output  reg	            [11:0] 	caddr_rd;
output	reg		                busy;
output	reg 	        [2:0]	csel;
output  reg 	        [5:0]   x_h; // input feature height
output  reg             [5:0]   x_w; // input feature width
output  reg     signed  [19:0]  ifmap_0;// ifmap data 
output  reg     signed  [19:0]  ifmap_1;// ifmap data
output  reg     signed  [19:0]  ifmap_2;// ifmap data
output  reg     signed  [19:0]  ifmap_3;// ifmap data
output  reg     signed  [19:0]  ifmap_4;// ifmap data
output  reg     signed  [19:0]  ifmap_5;// ifmap data
output  reg     signed  [19:0]  ifmap_6;// ifmap data
output  reg     signed  [19:0]  ifmap_7;// ifmap data
output  reg     signed  [19:0]  ifmap_8;// ifmap data
output  reg     [3:0]   corner_count;//corner_state load data
output  reg     [3:0]   side_count;//side_state load data
output  reg     [3:0]   mid_count;//mid_state load data
output  reg     [5:0]   pixel_first;//define 1st pixel in side_state
output  reg     [5:0]   row_change;//for mid_state 
output  reg     signed  [19:0]  kernel0_y;// kernel0 output
output  reg     signed  [19:0]  kernel1_y;// kernel1 output  
output  reg     signed  [39:0]  psum_0;
output  reg     signed  [39:0]  psum_1;
output  reg     [3:0]   pool_cnt;
output  reg     [19:0]  pool_max_0;
output  reg     [19:0]  pool_max_1;
output  reg     [1:0]   flat_cnt;
output  reg     [19:0]  flatten;
output  reg     [3:0]   current_state;
output  reg     [3:0]   next_state;
output  reg     [1:0]   cur_layer;
output  reg     [1:0]   next_layer;
/*--------------------kernel0----------------------------*/
parameter signed [19:0] kernel0_w0 = 20'h0A89E;
parameter signed [19:0] kernel0_w1 = 20'h092D5;
parameter signed [19:0] kernel0_w2 = 20'h06D43;
parameter signed [19:0] kernel0_w3 = 20'h01004;
parameter signed [19:0] kernel0_w4 = 20'hF8F71;
parameter signed [19:0] kernel0_w5 = 20'hF6E54;
parameter signed [19:0] kernel0_w6 = 20'hFA6D7;
parameter signed [19:0] kernel0_w7 = 20'hFC834;
parameter signed [19:0] kernel0_w8 = 20'hFAC19;
parameter signed [19:0] kernel1_w0 = 20'hFDB55;
parameter signed [19:0] kernel1_w1 = 20'h02992;
parameter signed [19:0] kernel1_w2 = 20'hFC994;
parameter signed [19:0] kernel1_w3 = 20'h050FD;
parameter signed [19:0] kernel1_w4 = 20'h02F20;
parameter signed [19:0] kernel1_w5 = 20'h0202D;
parameter signed [19:0] kernel1_w6 = 20'h03BD7;
parameter signed [19:0] kernel1_w7 = 20'hFD369;
parameter signed [19:0] kernel1_w8 = 20'h05E68;
/*--------------------bias--------------------------------*/
parameter signed [19:0] bias_0 = 20'h01310;
parameter signed [19:0] bias_1 = 20'hF7295;
/*------------------convolution state---------------------*/
parameter S_idle      = 4'b0000;
parameter S_left_up   = 4'b0001;
parameter S_up        = 4'b0010;
parameter S_right_up  = 4'b0011;
parameter S_left      = 4'b0100;
parameter S_mid       = 4'b0101;
parameter S_right     = 4'b0110;
parameter S_left_bot  = 4'b0111;
parameter S_bot       = 4'b1000;
parameter S_right_bot = 4'b1001;
parameter S_pooling   = 4'b1010;
/*------------------layer state-----------------------------*/
parameter L_idle = 2'b00;
parameter L0     = 2'b01;
parameter L1     = 2'b10;
parameter L2     = 2'b11;
/*----------------busy setting----------------------------*/
always@(posedge clk)
	begin
		if(ready && ~reset) busy <= 1;
		else if(ready)	    busy <= 0;
		else if(pixel_first == 6'd31 && flat_cnt == 2'd3 && row_change == 6'd31) busy <= 0;//check point  
		else 		        busy <= busy;
	end
/*-------------read address setting---------------------*/
/*----------------address setting-------------------------*/
always@(*)
    begin
		case(current_state)	
		S_left_up : begin
					  case(corner_count)
				      4'd0 : iaddr = x_w + (x_h << 6); 
			          4'd1 : iaddr = x_w + (x_h << 6);  
			          4'd2 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h  
			          4'd3 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h
			          default : iaddr = 12'd0; 
			          endcase 
				    end
		S_up : begin
			     case(side_count)
				 4'd0 : iaddr = x_w + (x_h << 6);
				 4'd1 : iaddr = x_w + (x_h << 6);
				 4'd2 : iaddr = x_w + (x_h << 6);
				 4'd3 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h
				 4'd4 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h
				 4'd5 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h
				 default : iaddr = 12'd0;
				 endcase
			   end
		S_right_up : begin
					   case(corner_count)
					   4'd0 : iaddr = x_w + (x_h << 6); 
			           4'd1 : iaddr = x_w + (x_h << 6);  
			           4'd2 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h  
			           4'd3 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h
			           default : iaddr = 12'd0; 
			           endcase 
					 end
		S_left : begin
			       case(side_count)
				   4'd0 : iaddr = x_w + (x_h << 6);
				   4'd1 : iaddr = x_w + (x_h << 6);
				   4'd2 : iaddr = x_w + (x_h << 6);
				   4'd3 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h
				   4'd4 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h
				   4'd5 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h
				   default : iaddr = 12'd0;
				   endcase
			     end
		S_mid : begin
                  case(mid_count)
				  4'd0 : iaddr = x_w + (x_h << 6);
				  4'd1 : iaddr = x_w + (x_h << 6);
				  4'd2 : iaddr = x_w + (x_h << 6);
				  4'd3 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h
				  4'd4 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h
				  4'd5 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h
				  4'd6 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h
				  4'd7 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h
				  4'd8 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h
				  default : iaddr = 12'd0;
				  endcase
				end
		S_right : begin
                    case(side_count)
					4'd0 : iaddr = x_w + (x_h << 6);
				    4'd1 : iaddr = x_w + (x_h << 6);
				    4'd2 : iaddr = x_w + (x_h << 6);
				    4'd3 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h
				    4'd4 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h
				    4'd5 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h
				    default : iaddr = 12'd0;
					endcase
				  end
		S_left_bot : begin
                       case(corner_count)
					   4'd0 : iaddr = x_w + (x_h << 6); 
			           4'd1 : iaddr = x_w + (x_h << 6);  
			           4'd2 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h  
			           4'd3 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h
					   default : iaddr = 12'd0;
					   endcase
					 end
		S_bot : begin
			      case(side_count)
				  4'd0 : iaddr = x_w + (x_h << 6);
				  4'd1 : iaddr = x_w + (x_h << 6);
				  4'd2 : iaddr = x_w + (x_h << 6);
				  4'd3 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h
				  4'd4 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h
				  4'd5 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h
				  default : iaddr = 12'd0;
				  endcase
			    end
		S_right_bot : begin
                        case(corner_count)
						4'd0 : iaddr = x_w + (x_h << 6); 
			            4'd1 : iaddr = x_w + (x_h << 6);  
			            4'd2 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h  
			            4'd3 : iaddr = x_w + (x_h << 6);//iaddr = x_w + 64 * x_h
						default : iaddr = 12'd0;
                        endcase					  
					  end		
		default : iaddr = 12'd0;		 
	    endcase
	end	
/*-----------height and width setting---------------------*/
always@(*)
    begin
        case(current_state)
		S_left_up : begin
			          case(corner_count)
			          4'd0 : begin x_w = pixel_first ; x_h = row_change ; end		
			          4'd1 : begin x_w = pixel_first + 6'd1 ; x_h = row_change ; end 
			          4'd2 : begin x_w = pixel_first ; x_h = row_change + 6'd1 ; end 
			          4'd3 : begin x_w = pixel_first + 6'd1 ; x_h = row_change + 6'd1 ; end
			          default : begin x_w = 6'd0 ; x_h = 6'd0 ; end
			          endcase
			        end
        S_up : begin
                 case(side_count)
                 4'd0 : begin x_w = pixel_first ; x_h = row_change ; end
				 4'd1 : begin x_w = pixel_first + 6'd1 ; x_h = row_change ; end
			     4'd2 : begin x_w = pixel_first + 6'd2 ; x_h = row_change ; end
			     4'd3 : begin x_w = pixel_first ; x_h = row_change + 6'd1 ; end
			     4'd4 : begin x_w = pixel_first + 6'd1 ; x_h = row_change + 6'd1 ; end
				 4'd5 : begin x_w = pixel_first + 6'd2 ; x_h = row_change + 6'd1 ; end
			     default : begin x_w = 6'd0 ; x_h = 6'd0 ; end
                 endcase
               end
		S_right_up : begin
                       case(corner_count)
			           4'd0 : begin x_w = pixel_first ; x_h = row_change ; end		
			           4'd1 : begin x_w = pixel_first + 6'd1 ; x_h = row_change ; end 
			           4'd2 : begin x_w = pixel_first ; x_h = row_change + 6'd1 ; end 
			           4'd3 : begin x_w = pixel_first + 6'd1 ; x_h = row_change + 6'd1 ; end
			           default : begin x_w = 6'd0 ; x_h = 6'd0 ; end
			           endcase
					 end
		S_left : begin
                   case(side_count)
                   4'd0 : begin x_w = pixel_first ; x_h = row_change - 6'd1 ; end
				   4'd1 : begin x_w = pixel_first + 6'd1 ; x_h = row_change - 6'd1 ; end 
			       4'd2 : begin x_w = pixel_first ; x_h = row_change ; end
			       4'd3 : begin x_w = pixel_first + 6'd1 ; x_h = row_change ; end
			       4'd4 : begin x_w = pixel_first ; x_h = row_change + 6'd1 ; end
				   4'd5 : begin x_w = pixel_first + 6'd1 ; x_h = row_change + 6'd1 ; end
			       default : begin x_w = 6'd0 ; x_h = 6'd0 ; end
                   endcase
				 end	
		S_mid : begin
                  case(mid_count)
				  4'd0 : begin x_w = pixel_first ; x_h = row_change - 6'd1; end
				  4'd1 : begin x_w = pixel_first + 6'd1 ; x_h = row_change - 6'd1; end
				  4'd2 : begin x_w = pixel_first + 6'd2 ; x_h = row_change - 6'd1; end
				  4'd3 : begin x_w = pixel_first ; x_h = row_change ; end
				  4'd4 : begin x_w = pixel_first + 6'd1 ; x_h = row_change ; end
				  4'd5 : begin x_w = pixel_first + 6'd2 ; x_h = row_change ; end
				  4'd6 : begin x_w = pixel_first ; x_h = row_change + 6'd1 ; end
				  4'd7 : begin x_w = pixel_first + 6'd1 ; x_h = row_change + 6'd1 ; end
				  4'd8 : begin x_w = pixel_first + 6'd2 ; x_h = row_change + 6'd1; end
				  default : begin x_w = 6'd0 ; x_h = 6'd0 ; end
				  endcase
				end	
		S_right : begin
                    case(side_count)
					4'd0 : begin x_w = pixel_first ; x_h = row_change - 6'd1 ; end
				    4'd1 : begin x_w = pixel_first + 6'd1; x_h = row_change - 6'd1 ; end 
			        4'd2 : begin x_w = pixel_first ; x_h = row_change ; end
			        4'd3 : begin x_w = pixel_first + 6'd1 ; x_h = row_change ; end
			        4'd4 : begin x_w = pixel_first ; x_h = row_change + 6'd1 ; end
				    4'd5 : begin x_w = pixel_first + 6'd1 ; x_h = row_change + 6'd1 ; end
					default : begin x_w = 6'd0 ; x_h = 6'd0 ; end
					endcase
				  end
		S_left_bot : begin
                       case(corner_count)
					   4'd0 : begin x_w = pixel_first ; x_h = row_change - 6'd1 ; end		
			           4'd1 : begin x_w = pixel_first + 6'd1 ; x_h = row_change - 6'd1 ; end 
			           4'd2 : begin x_w = pixel_first ; x_h = row_change ; end 
			           4'd3 : begin x_w = pixel_first + 6'd1 ; x_h = row_change ; end
					   default : begin x_w = 6'd0 ; x_h = 6'd0 ; end
					   endcase
					 end
		S_bot : begin
                  case(side_count)
                  4'd0 : begin x_w = pixel_first ; x_h = row_change - 6'd1 ; end
				  4'd1 : begin x_w = pixel_first + 6'd1 ; x_h = row_change - 6'd1 ; end
			      4'd2 : begin x_w = pixel_first + 6'd2 ; x_h = row_change - 6'd1 ; end
			      4'd3 : begin x_w = pixel_first ; x_h = row_change ; end
			      4'd4 : begin x_w = pixel_first + 6'd1 ; x_h = row_change ; end
				  4'd5 : begin x_w = pixel_first + 6'd2 ; x_h = row_change ; end
			      default : begin x_w = 6'd0 ; x_h = 6'd0 ; end
                  endcase
				end		
        S_right_bot : begin
		                case(corner_count)
						4'd0 : begin x_w = pixel_first ; x_h = row_change - 6'd1 ; end		
			            4'd1 : begin x_w = pixel_first + 6'd1 ; x_h = row_change - 6'd1 ; end 
			            4'd2 : begin x_w = pixel_first ; x_h = row_change ; end 
			            4'd3 : begin x_w = pixel_first + 6'd1 ; x_h = row_change ; end
						default : begin x_w = 6'd0 ; x_h = 6'd0 ; end
						endcase
					  end
		default : begin x_w = 6'd0 ; x_h = 6'd0 ; end
		endcase
	end
/*---------------row change setting-------------------------*/
always@(posedge clk)
	begin
	  case(cur_layer)
	  L0 : begin
	         case(current_state)
	         S_idle : row_change <= 6'd0;
	         S_right_up : begin
		                    if(corner_count == 4'd7) row_change <= row_change + 6'd1;
					        //else row_change <= row_change;
		                  end
	         S_right : begin
		                 if(side_count == 4'd9) row_change <= row_change + 6'd1;
				         //else row_change <= row_change;
		               end			   
	         S_right_bot : begin
	                         if(corner_count == 4'd7) row_change <= 6'd0;
					         //else row_change <= row_change;
					       end  
	         default : row_change <= row_change;
             endcase
		   end
      L1 : begin
             if(pixel_first == 6'd62 && pool_cnt == 4'd9) row_change <= row_change + 6'd2;
			 //else row_change <= row_change;
		   end
	  L2 : begin
	         if(pixel_first == 6'd31 && flat_cnt == 2'd3) row_change <= row_change + 6'd1;
			 //else row_change <= row_change;
		   end
	  default : row_change <= 6'd0;
      endcase	  
	end
/*---------------first pixel setting------------------------*/
always@(posedge clk)
	begin
	  case(cur_layer)
	  L0 : begin 	   
	         case(current_state)
	         S_up : begin
		              if(side_count == 4'd9) pixel_first <= pixel_first + 6'd1;
			          //else pixel_first <= pixel_first;
			        end  
	         S_right_up : begin
				            if(corner_count == 4'd7) pixel_first <= 6'd0;
					        else pixel_first <= 6'd62;
				          end
	         S_left : begin
				        if(side_count == 4'd9) pixel_first <= 6'd0;
				        //else pixel_first <= pixel_first
			          end  
	         S_mid : begin               
                       if(pixel_first != 7'd62 && mid_count == 4'd12) pixel_first <= pixel_first + 6'd1;
				       //else pixel_first <= pixel_first;
			         end
	         S_right : begin
                         if(side_count == 4'd9) pixel_first <= 6'd0;
                         else pixel_first <= 6'd62;				  
				       end	
	         S_bot : begin
		               if(side_count == 4'd9) pixel_first <= pixel_first + 6'd1;
			           //else pixel_first <= pixel_first;
			         end 		   
	         S_right_bot : begin
			                 if(corner_count == 4'd7) pixel_first <= 6'd0;
							 else pixel_first <= 6'd62;
						   end
	         default : pixel_first <= 6'd0;
	         endcase
		   end	 
	  L1 : begin
	         if(pool_cnt == 4'd9) pixel_first <= pixel_first + 6'd2 ;
			 //else pixel_first <= pixel_first;
		   end
	  L2 : begin
             if(flat_cnt == 2'd3 && pixel_first < 6'd31) pixel_first <= pixel_first + 6'd1;
		     else if(flat_cnt == 2'd3 && pixel_first == 6'd31) pixel_first <= 6'd0;
			 //else pixel_first <= pixel_first;
		   end	  
	  default : pixel_first <= 6'd0;
	  endcase
	end
/*---------------mid_counter-------------------------------*/
always@(posedge clk)
	begin
	  if(current_state == S_mid)
	    begin
	      if(mid_count < 4'd12) mid_count <= mid_count + 4'd1;
	      else mid_count <= 4'd0;
	    end
	  else mid_count <= 4'd0;
	end
/*---------------corner_counter-----------------------------*/
always@(posedge clk)
	begin
	  case(cur_layer)
	  L0 : begin
	         case(current_state)
	         S_left_up : corner_count <= corner_count + 4'd1;
	         S_right_up : corner_count <= corner_count + 4'd1;
	         S_left_bot : corner_count <= corner_count + 4'd1;
	         S_right_bot : corner_count <= corner_count + 4'd1;
	         default : corner_count <= 4'd0;
	         endcase
		   end
	  L1 : corner_count <= 4'd0;
	  default : corner_count <= 4'd0;
	  endcase
	end
/*---------------side_counter------------------------------*/
always@(posedge clk)
	begin
	  case(current_state)
	  S_up : begin
	           if(side_count < 4'd9) side_count <= side_count + 4'd1;
			   else side_count <= 4'd0;
			 end			
	  S_left : begin
	             if(side_count < 4'd9) side_count <= side_count + 4'd1;
				 else side_count <= 4'd0;
			   end
	  S_right : begin
                  if(side_count < 4'd9) side_count <= side_count + 4'd1;
				  else side_count <= 4'd0;
				end	  
	  S_bot : begin
                if(side_count < 4'd9) side_count <= side_count + 4'd1;
				else side_count <= 4'd0;
		      end	 
	  default : side_count <= 4'd0;
	  endcase			
	end
/*------------max pooling counter--------------------------*/
always@(posedge clk)
	begin
	  if(cur_layer == L1 && pool_cnt < 4'd9) pool_cnt <= pool_cnt + 4'd1;
	  else pool_cnt <= 4'd0;
	end
/*------------flatten counter------------------------------*/
always@(posedge clk)
	begin
	  if(cur_layer == L2 && flat_cnt < 2'd3) flat_cnt <= flat_cnt + 2'd1;
	  else flat_cnt <= 2'd0;
	end
/*------------ifmap data setting---------------------------*/
always@(*)
	begin
		case(current_state)
		S_left_up : begin
		              case(corner_count)
		              4'd0 : begin ifmap_4 = idata ; ifmap_0 = 20'd0 ; ifmap_1 = 20'd0 ; ifmap_2 = 20'd0 ; ifmap_3 = 20'd0 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
		              4'd1 : begin ifmap_5 = idata ; ifmap_0 = 20'd0 ; ifmap_1 = 20'd0 ; ifmap_2 = 20'd0 ; ifmap_3 = 20'd0 ; ifmap_4 = ifmap_4 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
		              4'd2 : begin ifmap_7 = idata ; ifmap_0 = 20'd0 ; ifmap_1 = 20'd0 ; ifmap_2 = 20'd0 ; ifmap_3 = 20'd0 ; ifmap_4 = ifmap_4 ; ifmap_5 = ifmap_5 ; ifmap_6 = 20'd0 ; ifmap_8 = 20'd0 ; end
		              4'd3 : begin ifmap_8 = idata ; ifmap_0 = 20'd0 ; ifmap_1 = 20'd0 ; ifmap_2 = 20'd0 ; ifmap_3 = 20'd0 ; ifmap_4 = ifmap_4 ; ifmap_5 = ifmap_5 ; ifmap_6 = 20'd0 ; ifmap_7 = ifmap_7 ; end
		              default : begin ifmap_0 = 20'd0 ; ifmap_1 = 20'd0 ; ifmap_2 = 20'd0 ; ifmap_3 = 20'd0 ; ifmap_4 = ifmap_4 ; ifmap_5 = ifmap_5 ; ifmap_6 = 20'd0 ; ifmap_7 = ifmap_7 ; ifmap_8 = ifmap_8 ; end
		              endcase
		            end
        S_up : begin
                 case(side_count)
                 4'd0 : begin ifmap_3 = idata ; ifmap_0 = 20'd0 ; ifmap_1 = 20'd0 ; ifmap_2 = 20'd0 ; ifmap_4 = 20'd0 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
                 4'd1 : begin ifmap_4 = idata ; ifmap_0 = 20'd0 ; ifmap_1 = 20'd0 ; ifmap_2 = 20'd0 ; ifmap_3 = ifmap_3 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
                 4'd2 : begin ifmap_5 = idata ; ifmap_0 = 20'd0 ; ifmap_1 = 20'd0 ; ifmap_2 = 20'd0 ; ifmap_3 = ifmap_3 ; ifmap_4 = ifmap_4 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
                 4'd3 : begin ifmap_6 = idata ; ifmap_0 = 20'd0 ; ifmap_1 = 20'd0 ; ifmap_2 = 20'd0 ; ifmap_3 = ifmap_3 ; ifmap_4 = ifmap_4 ; ifmap_5 = ifmap_5 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
                 4'd4 : begin ifmap_7 = idata ; ifmap_0 = 20'd0 ; ifmap_1 = 20'd0 ; ifmap_2 = 20'd0 ; ifmap_3 = ifmap_3 ; ifmap_4 = ifmap_4 ; ifmap_5 = ifmap_5 ; ifmap_6 = ifmap_6 ; ifmap_8 = 20'd0 ; end
                 4'd5 : begin ifmap_8 = idata ; ifmap_0 = 20'd0 ; ifmap_1 = 20'd0 ; ifmap_2 = 20'd0 ; ifmap_3 = ifmap_3 ; ifmap_4 = ifmap_4 ; ifmap_5 = ifmap_5 ; ifmap_6 = ifmap_6 ; ifmap_7 = ifmap_7 ; end
                 default : begin ifmap_0 = 20'd0 ; ifmap_1 = 20'd0 ; ifmap_2 = 20'd0 ; ifmap_3 = ifmap_3 ;ifmap_4 = ifmap_4 ; ifmap_5 = ifmap_5 ; ifmap_6 = ifmap_6 ; ifmap_7 = ifmap_7 ; ifmap_8 = ifmap_8 ; end
                 endcase
               end
        S_right_up : begin
		               case(corner_count)
		               4'd0 : begin ifmap_3 = idata ; ifmap_0 = 20'd0 ; ifmap_1 = 20'd0 ; ifmap_2 = 20'd0 ; ifmap_4 = 20'd0 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
		               4'd1 : begin ifmap_4 = idata ; ifmap_0 = 20'd0 ; ifmap_1 = 20'd0 ; ifmap_2 = 20'd0 ; ifmap_3 = ifmap_3 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
		               4'd2 : begin ifmap_6 = idata ; ifmap_0 = 20'd0 ; ifmap_1 = 20'd0 ; ifmap_2 = 20'd0 ; ifmap_3 = ifmap_3 ; ifmap_4 = ifmap_4 ; ifmap_5 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
		               4'd3 : begin ifmap_7 = idata ; ifmap_0 = 20'd0 ; ifmap_1 = 20'd0 ; ifmap_2 = 20'd0 ; ifmap_3 = ifmap_3 ; ifmap_4 = ifmap_4 ; ifmap_5 = 20'd0 ; ifmap_6 = ifmap_6 ; ifmap_8 = 20'd0 ; end
		               default : begin ifmap_0 = 20'd0 ; ifmap_1 = 20'd0 ; ifmap_2 = 20'd0 ; ifmap_3 = ifmap_3 ;ifmap_4 = ifmap_4 ; ifmap_5 = 20'd0 ; ifmap_6 = ifmap_6 ; ifmap_7 = ifmap_7 ; ifmap_8 = 20'd0 ; end
		               endcase
		             end
		S_left : begin
		           case(side_count)
                   4'd0 : begin ifmap_1 = idata ; ifmap_0 = 20'd0 ; ifmap_2 = 20'd0 ; ifmap_3 = 20'd0 ; ifmap_4 = 20'd0 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
                   4'd1 : begin ifmap_2 = idata ; ifmap_0 = 20'd0 ; ifmap_1 = ifmap_1 ; ifmap_3 = 20'd0 ; ifmap_4 = 20'd0 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
                   4'd2 : begin ifmap_4 = idata ; ifmap_0 = 20'd0 ; ifmap_1 = ifmap_1 ; ifmap_2 = ifmap_2 ; ifmap_3 = 20'd0 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
                   4'd3 : begin ifmap_5 = idata ; ifmap_0 = 20'd0 ; ifmap_1 = ifmap_1 ; ifmap_2 = ifmap_2 ; ifmap_3 = 20'd0 ; ifmap_4 = ifmap_4 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
                   4'd4 : begin ifmap_7 = idata ; ifmap_0 = 20'd0 ; ifmap_1 = ifmap_1 ; ifmap_2 = ifmap_2 ; ifmap_3 = 20'd0 ; ifmap_4 = ifmap_4 ; ifmap_5 = ifmap_5 ; ifmap_6 = 20'd0 ; ifmap_8 = 20'd0 ; end
                   4'd5 : begin ifmap_8 = idata ; ifmap_0 = 20'd0 ; ifmap_1 = ifmap_1 ; ifmap_2 = ifmap_2 ; ifmap_3 = 20'd0 ; ifmap_4 = ifmap_4 ; ifmap_5 = ifmap_5 ; ifmap_6 = 20'd0 ; ifmap_7 = ifmap_7 ; end
                   default : begin ifmap_0 = 20'd0 ; ifmap_1 = ifmap_1 ; ifmap_2 = ifmap_2 ; ifmap_3 = 20'd0 ;ifmap_4 = ifmap_4 ; ifmap_5 = ifmap_5 ; ifmap_6 = 20'd0 ; ifmap_7 = ifmap_7 ; ifmap_8 = ifmap_8 ; end
                   endcase
				 end		 
		S_mid : begin
		          case(mid_count)
				  4'd0 : begin ifmap_0 = idata ; ifmap_1 = 20'd0 ; ifmap_2 = 20'd0 ; ifmap_3 = 20'd0 ; ifmap_4 = 20'd0 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
				  4'd1 : begin ifmap_1 = idata ; ifmap_0 = ifmap_0 ; ifmap_2 = 20'd0 ; ifmap_3 = 20'd0 ; ifmap_4 = 20'd0 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
				  4'd2 : begin ifmap_2 = idata ; ifmap_0 = ifmap_0 ; ifmap_1 = ifmap_1 ; ifmap_3 = 20'd0 ; ifmap_4 = 20'd0 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
				  4'd3 : begin ifmap_3 = idata ; ifmap_0 = ifmap_0 ; ifmap_1 = ifmap_1 ; ifmap_2 = ifmap_2 ; ifmap_4 = 20'd0 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
				  4'd4 : begin ifmap_4 = idata ; ifmap_0 = ifmap_0 ; ifmap_1 = ifmap_1 ; ifmap_2 = ifmap_2 ; ifmap_3 = ifmap_3 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
				  4'd5 : begin ifmap_5 = idata ; ifmap_0 = ifmap_0 ; ifmap_1 = ifmap_1 ; ifmap_2 = ifmap_2 ; ifmap_3 = ifmap_3 ; ifmap_4 = ifmap_4 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
				  4'd6 : begin ifmap_6 = idata ; ifmap_0 = ifmap_0 ; ifmap_1 = ifmap_1 ; ifmap_2 = ifmap_2 ; ifmap_3 = ifmap_3 ; ifmap_4 = ifmap_4 ; ifmap_5 = ifmap_5 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
				  4'd7 : begin ifmap_7 = idata ; ifmap_0 = ifmap_0 ; ifmap_1 = ifmap_1 ; ifmap_2 = ifmap_2 ; ifmap_3 = ifmap_3 ; ifmap_4 = ifmap_4 ; ifmap_5 = ifmap_5 ; ifmap_6 = ifmap_6 ; ifmap_8 = 20'd0 ; end
				  4'd8 : begin ifmap_8 = idata ; ifmap_0 = ifmap_0 ; ifmap_1 = ifmap_1 ; ifmap_2 = ifmap_2 ; ifmap_3 = ifmap_3 ; ifmap_4 = ifmap_4 ; ifmap_5 = ifmap_5 ; ifmap_6 = ifmap_6 ; ifmap_7 = ifmap_7 ; end			  
				  default : begin ifmap_0 = ifmap_0 ; ifmap_1 = ifmap_1 ; ifmap_2 = ifmap_2 ; ifmap_3 = ifmap_3 ;ifmap_4 = ifmap_4 ; ifmap_5 = ifmap_5 ; ifmap_6 = ifmap_6 ; ifmap_7 = ifmap_7 ; ifmap_8 = ifmap_8 ; end
				  endcase
				end
		S_right : begin
		            case(side_count)
                    4'd0 : begin ifmap_0 = idata ; ifmap_1 = 20'd0 ; ifmap_2 = 20'd0 ; ifmap_3 = 20'd0 ; ifmap_4 = 20'd0 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
                    4'd1 : begin ifmap_1 = idata ; ifmap_0 = ifmap_0 ; ifmap_2 = 20'd0 ; ifmap_3 = 20'd0 ; ifmap_4 = 20'd0 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
                    4'd2 : begin ifmap_3 = idata ; ifmap_0 = ifmap_0 ; ifmap_1 = ifmap_1 ; ifmap_2 = 20'd0 ; ifmap_4 = 20'd0 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
                    4'd3 : begin ifmap_4 = idata ; ifmap_0 = ifmap_0 ; ifmap_1 = ifmap_1 ; ifmap_2 = 20'd0 ; ifmap_3 = ifmap_3 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
                    4'd4 : begin ifmap_6 = idata ; ifmap_0 = ifmap_0 ; ifmap_1 = ifmap_1 ; ifmap_2 = 20'd0 ; ifmap_3 = ifmap_3 ; ifmap_4 = ifmap_4 ; ifmap_5 = 20'd0 ; ifmap_7= 20'd0 ; ifmap_8 = 20'd0 ; end
                    4'd5 : begin ifmap_7 = idata ; ifmap_0 = ifmap_0 ; ifmap_1 = ifmap_1 ; ifmap_2 = 20'd0 ; ifmap_3 = ifmap_3 ; ifmap_4 = ifmap_4 ; ifmap_5 = 20'd0 ; ifmap_6 = ifmap_6 ; ifmap_8 = 20'd0 ; end
                    default : begin ifmap_0 = ifmap_0 ; ifmap_1 = ifmap_1 ; ifmap_2 = 20'd0 ; ifmap_3 = ifmap_3 ;ifmap_4 = ifmap_4 ; ifmap_5 = 20'd0 ; ifmap_6 = ifmap_6 ; ifmap_7 = ifmap_7 ; ifmap_8 = 20'd0 ; end
                    endcase
				  end			
		S_left_bot : begin
		               case(corner_count)
		               4'd0 : begin ifmap_1 = idata ; ifmap_0 = 20'd0 ; ifmap_2 = 20'd0 ; ifmap_3 = 20'd0 ; ifmap_4 = 20'd0 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
		               4'd1 : begin ifmap_2 = idata ; ifmap_0 = 20'd0 ; ifmap_1 = ifmap_1 ; ifmap_3 = 20'd0 ; ifmap_4 = 20'd0 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
		               4'd2 : begin ifmap_4 = idata ; ifmap_0 = 20'd0 ; ifmap_1 = ifmap_1 ; ifmap_2 = ifmap_2 ; ifmap_3 = 20'd0 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
		               4'd3 : begin ifmap_5 = idata ; ifmap_0 = 20'd0 ; ifmap_1 = ifmap_1 ; ifmap_2 = ifmap_2 ; ifmap_3 = 20'd0 ; ifmap_4 = ifmap_4 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
		               default : begin ifmap_0 = 20'd0 ; ifmap_1 = ifmap_1 ; ifmap_2 = ifmap_2 ; ifmap_3 = 20'd0 ; ifmap_4 = ifmap_4 ; ifmap_5 = ifmap_5 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
		               endcase
					 end
		S_bot : begin
                  case(side_count)
				  4'd0 : begin ifmap_0 = idata ; ifmap_1 = 20'd0 ; ifmap_2 = 20'd0 ; ifmap_3 = 20'd0 ; ifmap_4 = 20'd0 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
                  4'd1 : begin ifmap_1 = idata ; ifmap_0 = ifmap_0 ; ifmap_2 = 20'd0 ; ifmap_3 = 20'd0 ; ifmap_4 = 20'd0 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
                  4'd2 : begin ifmap_2 = idata ; ifmap_0 = ifmap_0 ; ifmap_1 = ifmap_1 ; ifmap_3 = 20'd0 ; ifmap_4 = 20'd0 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
                  4'd3 : begin ifmap_3 = idata ; ifmap_0 = ifmap_0 ; ifmap_1 = ifmap_1 ; ifmap_2 = ifmap_2 ; ifmap_4 = 20'd0 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
                  4'd4 : begin ifmap_4 = idata ; ifmap_0 = ifmap_0 ; ifmap_1 = ifmap_1 ; ifmap_2 = ifmap_2 ; ifmap_3 = ifmap_3 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
                  4'd5 : begin ifmap_5 = idata ; ifmap_0 = ifmap_0 ; ifmap_1 = ifmap_1 ; ifmap_2 = ifmap_2 ; ifmap_3 = ifmap_3 ; ifmap_4 = ifmap_4 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
                  default : begin ifmap_0 = ifmap_0 ; ifmap_1 = ifmap_1 ; ifmap_2 = ifmap_2 ; ifmap_3 = ifmap_3 ;ifmap_4 = ifmap_4 ; ifmap_5 = ifmap_5 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
				  endcase
				end		
		S_right_bot : begin
		                case(corner_count)
						4'd0 : begin ifmap_0 = idata ; ifmap_1 = 20'd0 ; ifmap_2 = 20'd0 ; ifmap_3 = 20'd0 ; ifmap_4 = 20'd0 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
		                4'd1 : begin ifmap_1 = idata ; ifmap_0 = ifmap_0 ; ifmap_2 = 20'd0 ; ifmap_3 = 20'd0 ; ifmap_4 = 20'd0 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
		                4'd2 : begin ifmap_3 = idata ; ifmap_0 = ifmap_0 ; ifmap_1 = ifmap_1 ; ifmap_2 = 20'd0 ; ifmap_4 = 20'd0 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
		                4'd3 : begin ifmap_4 = idata ; ifmap_0 = ifmap_0 ; ifmap_1 = ifmap_1 ; ifmap_2 = 20'd0 ; ifmap_3 = ifmap_3 ; ifmap_5 = 20'd0; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
						default : begin ifmap_0 = ifmap_0 ; ifmap_1 = ifmap_1 ; ifmap_2 = 20'd0 ; ifmap_3 = ifmap_3 ; ifmap_4 = ifmap_4 ; ifmap_5 = 20'd0 ; ifmap_6 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
						endcase
					  end
		default : begin ifmap_0 = 20'd0 ; ifmap_1 = 20'd0 ; ifmap_2 = 20'd0 ; ifmap_3 = 20'd0 ;ifmap_4 = 20'd0 ; ifmap_5 = 20'd0 ; ifmap_7 = 20'd0 ; ifmap_8 = 20'd0 ; end
		endcase
	end 
/*----------------convolution FSM----------------------------------------*/
always@(posedge clk)
	begin
		if(reset) current_state <= S_idle;
		else     current_state <= next_state;
	end

always@(*)
    begin
        case(current_state)
        S_idle : begin
				   if(corner_count == 4'd0) next_state = S_left_up;
				   else next_state = S_idle;
				 end
		S_left_up : begin
                      if(corner_count == 4'd7) next_state = S_up;
                      else next_state = S_left_up;
                    end  
        S_up : begin
			     if(pixel_first == 6'd61 && side_count == 4'd9) next_state = S_right_up;
			     else next_state = S_up;
			   end
		S_right_up : begin
					   if(corner_count == 4'd7) next_state = S_left;
					   else next_state = S_right_up;
					 end
		S_left : begin
				   if(side_count == 4'd9) next_state = S_mid;
				   else next_state = S_left;
				 end
		S_mid : begin
			      if(pixel_first == 6'd61 && mid_count == 4'd12) next_state = S_right;
			      else next_state = S_mid;
			    end		 
		S_right : begin
					if(row_change != 6'd62 && side_count == 4'd9) next_state = S_left;
				    else if(row_change == 6'd62 && side_count == 4'd9) next_state = S_left_bot;
					else next_state = S_right;
				  end
		S_left_bot : begin
                       if(corner_count == 4'd7) next_state = S_bot;
					   else next_state = S_left_bot;
					 end
		S_bot : begin
                  if(pixel_first == 6'd61 && side_count == 4'd9) next_state = S_right_bot;
				  else next_state = S_bot;
				end
		S_right_bot : next_state = S_right_bot;			  
		default : next_state = S_idle;
		endcase
    end    

always@(*)
    begin
		case(current_state)
		S_left_up : begin
				      case(corner_count)
				      4'd4 : begin
							   psum_0 = (ifmap_4 * kernel0_w4 + ifmap_5 * kernel0_w5 ) + (ifmap_7 * kernel0_w7 + ifmap_8 * kernel0_w8);						
				               psum_1 = (ifmap_4 * kernel1_w4 + ifmap_5 * kernel1_w5 ) + (ifmap_7 * kernel1_w7 + ifmap_8 * kernel1_w8);
				             end
				      4'd5 : begin//rounding
				               case(psum_0[15])
						       1'b0 : begin
									    case(psum_1[15])
                                        1'b0 : begin kernel0_y = psum_0[35:16] + bias_0 ; kernel1_y = psum_1[35:16] + bias_1 ; end//MSB 4 bits and LSB 16 bits overflow									
                                        1'b1 : begin kernel0_y = psum_0[35:16] + bias_0 ; kernel1_y = psum_1[35:16] + 20'h0000_1 + bias_1 ; end								  
								        default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
									    endcase
								      end
                               1'b1 : begin
									    case(psum_1[15])
                                        1'b0 : begin kernel0_y = psum_0[35:16] + 20'h0000_1 + bias_0 ; kernel1_y = psum_1[35:16] + bias_1 ; end									
                                        1'b1 : begin kernel0_y = psum_0[35:16] + 20'h0000_1 + bias_0 ; kernel1_y = psum_1[35:16] + 20'h0000_1 + bias_1 ; end								  
								        default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
								        endcase
								      end
						       default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
                               endcase						   
				             end
				      4'd6 : begin//relu function
		                       case(kernel0_y[19])
		                       1'b0 : begin
		                                case(kernel1_y[19])
		                                1'b0 : begin kernel0_y = kernel0_y ; kernel1_y = kernel1_y ; end
		                                1'b1 : begin kernel0_y = kernel0_y ; kernel1_y = 20'd0 ; end
		                                default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
									    endcase
		                              end
		                       1'b1 : begin
		                                case(kernel1_y[19])
		                                1'b0 : begin kernel0_y = 20'd0 ; kernel1_y = kernel1_y ; end
		                                1'b1 : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
		                                default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
									    endcase
		                              end 
		                       default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
						       endcase        
		                     end
				      default : begin kernel0_y = kernel0_y ; kernel1_y = kernel1_y ; end 
				      endcase
			        end
		S_up : begin
				 case(side_count)
				 4'd6 : begin
						  psum_0 = (ifmap_3 * kernel0_w3 + ifmap_4 * kernel0_w4) + (ifmap_5 * kernel0_w5 + ifmap_6 * kernel0_w6) + (ifmap_7 * kernel0_w7 + ifmap_8 * kernel0_w8);							
				          psum_1 = (ifmap_3 * kernel1_w3 + ifmap_4 * kernel1_w4) + (ifmap_5 * kernel1_w5 + ifmap_6 * kernel1_w6) + (ifmap_7 * kernel1_w7 + ifmap_8 * kernel1_w8);
				        end
				 4'd7 : begin//rounding
				          case(psum_0[15])
						  1'b0 : begin
								   case(psum_1[15])
                                   1'b0 : begin kernel0_y = psum_0[35:16] + bias_0 ; kernel1_y = psum_1[35:16] + bias_1 ; end//MSB 4 bits and LSB 16 bits overflow									
                                   1'b1 : begin kernel0_y = psum_0[35:16] + bias_0 ; kernel1_y = psum_1[35:16] + 20'h0000_1 + bias_1 ; end								  
								   default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
								   endcase
								 end
                          1'b1 : begin
								   case(psum_1[15])
                                   1'b0 : begin kernel0_y = psum_0[35:16] + 20'h0000_1 + bias_0 ; kernel1_y = psum_1[35:16] + bias_1 ; end									
                                   1'b1 : begin kernel0_y = psum_0[35:16] + 20'h0000_1 + bias_0 ; kernel1_y = psum_1[35:16] + 20'h0000_1 + bias_1 ; end								  
								   default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
								   endcase
								 end
						  default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
                          endcase						   
				        end
				 4'd8 : begin//relu function
		                  case(kernel0_y[19]) 
		                  1'b0 : begin
		                           case(kernel1_y[19])
		                           1'b0 : begin kernel0_y = kernel0_y ; kernel1_y = kernel1_y ; end
		                           1'b1 : begin kernel0_y = kernel0_y ; kernel1_y = 20'd0 ; end
		                           default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
								   endcase
		                         end
		                  1'b1 : begin
		                           case(kernel1_y[19])
		                           1'b0 : begin kernel0_y = 20'd0 ; kernel1_y = kernel1_y ; end
		                           1'b1 : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
		                           default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
								   endcase
		                         end 
		                  default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
						  endcase        
		                end
				 default : begin kernel0_y = kernel0_y ; kernel1_y = kernel1_y ; end 
				 endcase
			   end
        S_right_up : begin
				      case(corner_count)
				      4'd4 : begin
							   psum_0 = (ifmap_3 * kernel0_w3 + ifmap_4 * kernel0_w4) + (ifmap_6 * kernel0_w6 + ifmap_7 * kernel0_w7);						
				               psum_1 = (ifmap_3 * kernel1_w3 + ifmap_4 * kernel1_w4) + (ifmap_6 * kernel1_w6 + ifmap_7 * kernel1_w7);
				             end
				      4'd5 : begin//rounding
				               case(psum_0[15])
						       1'b0 : begin
									    case(psum_1[15])
                                        1'b0 : begin kernel0_y = psum_0[35:16] + bias_0 ; kernel1_y = psum_1[35:16] + bias_1 ; end//MSB 4 bits and LSB 16 bits overflow									
                                        1'b1 : begin kernel0_y = psum_0[35:16] + bias_0 ; kernel1_y = psum_1[35:16] + 20'h0000_1 + bias_1 ; end								  
								        default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
									    endcase
								      end
                               1'b1 : begin
									    case(psum_1[15])
                                        1'b0 : begin kernel0_y = psum_0[35:16] + 20'h0000_1 + bias_0 ; kernel1_y = psum_1[35:16] + bias_1 ; end									
                                        1'b1 : begin kernel0_y = psum_0[35:16] + 20'h0000_1 + bias_0 ; kernel1_y = psum_1[35:16] + 20'h0000_1 + bias_1 ; end								  
								        default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
								        endcase
								      end
						       default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
                               endcase						   
				             end
				      4'd6 : begin//relu function
		                       case(kernel0_y[19])
		                       1'b0 : begin
		                                case(kernel1_y[19])
		                                1'b0 : begin kernel0_y = kernel0_y ; kernel1_y = kernel1_y ; end
		                                1'b1 : begin kernel0_y = kernel0_y ; kernel1_y = 20'd0 ; end
		                                default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
									    endcase
		                              end
		                       1'b1 : begin
		                                case(kernel1_y[19])
		                                1'b0 : begin kernel0_y = 20'd0 ; kernel1_y = kernel1_y ; end
		                                1'b1 : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
		                                default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
									    endcase
		                              end 
		                       default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
						       endcase        
		                     end
				      default : begin kernel0_y = kernel0_y ; kernel1_y = kernel1_y ; end 
				      endcase
			        end
		S_left : begin
				   case(side_count)
				   4'd6 : begin
						    psum_0 = (ifmap_1 * kernel0_w1 + ifmap_2 * kernel0_w2) + (ifmap_4 * kernel0_w4 + ifmap_5 * kernel0_w5) + (ifmap_7 * kernel0_w7 + ifmap_8 * kernel0_w8);							
				            psum_1 = (ifmap_1 * kernel1_w1 + ifmap_2 * kernel1_w2) + (ifmap_4 * kernel1_w4 + ifmap_5 * kernel1_w5) + (ifmap_7 * kernel1_w7 + ifmap_8 * kernel1_w8);
				          end
				   4'd7 : begin//rounding
				            case(psum_0[15])
						    1'b0 : begin
							  	     case(psum_1[15])
                                     1'b0 : begin kernel0_y = psum_0[35:16] + bias_0 ; kernel1_y = psum_1[35:16] + bias_1 ; end//MSB 4 bits and LSB 16 bits overflow									
                                     1'b1 : begin kernel0_y = psum_0[35:16] + bias_0 ; kernel1_y = psum_1[35:16] + 20'h0000_1 + bias_1 ; end								  
								     default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
								     endcase
								   end
                            1'b1 : begin
								     case(psum_1[15])
                                     1'b0 : begin kernel0_y = psum_0[35:16] + 20'h0000_1 + bias_0 ; kernel1_y = psum_1[35:16] + bias_1 ; end									
                                     1'b1 : begin kernel0_y = psum_0[35:16] + 20'h0000_1 + bias_0 ; kernel1_y = psum_1[35:16] + 20'h0000_1 + bias_1 ; end								  
								     default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
								     endcase
								   end
						    default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
                            endcase						   
				          end
				   4'd8 : begin//relu function
		                    case(kernel0_y[19]) 
		                    1'b0 : begin
		                             case(kernel1_y[19])
		                             1'b0 : begin kernel0_y = kernel0_y ; kernel1_y = kernel1_y ; end
		                             1'b1 : begin kernel0_y = kernel0_y ; kernel1_y = 20'd0 ; end
		                             default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
								     endcase
		                           end
		                    1'b1 : begin
		                             case(kernel1_y[19])
		                             1'b0 : begin kernel0_y = 20'd0 ; kernel1_y = kernel1_y ; end
		                             1'b1 : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
		                             default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
								     endcase
		                           end 
		                    default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
						    endcase        
		                  end
				   default : begin kernel0_y = kernel0_y ; kernel1_y = kernel1_y ; end 
				   endcase
			   end
		S_mid : begin
				  case(mid_count)
				  4'd9 : begin
						   psum_0 = (ifmap_0 * kernel0_w0 + ifmap_1 * kernel0_w1) + (ifmap_2 * kernel0_w2 + ifmap_3 * kernel0_w3) + (ifmap_4 * kernel0_w4 + ifmap_5 * kernel0_w5) + (ifmap_6 * kernel0_w6 + ifmap_7 * kernel0_w7) + ifmap_8 * kernel0_w8;							
				           psum_1 = (ifmap_0 * kernel1_w0 + ifmap_1 * kernel1_w1) + (ifmap_2 * kernel1_w2 + ifmap_3 * kernel1_w3) + (ifmap_4 * kernel1_w4 + ifmap_5 * kernel1_w5) + (ifmap_6 * kernel1_w6 + ifmap_7 * kernel1_w7) + ifmap_8 * kernel1_w8;
				         end
				  4'd10 : begin//rounding
				            case(psum_0[15])
						    1'b0 : begin
							  	     case(psum_1[15])
                                     1'b0 : begin kernel0_y = psum_0[35:16] + bias_0 ; kernel1_y = psum_1[35:16] + bias_1 ; end//MSB 4 bits and LSB 16 bits overflow									
                                     1'b1 : begin kernel0_y = psum_0[35:16] + bias_0 ; kernel1_y = psum_1[35:16] + 20'h0000_1 + bias_1 ; end								  
								     default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
								     endcase
								   end
                            1'b1 : begin
								     case(psum_1[15])
                                     1'b0 : begin kernel0_y = psum_0[35:16] + 20'h0000_1 + bias_0 ; kernel1_y = psum_1[35:16] + bias_1 ; end									
                                     1'b1 : begin kernel0_y = psum_0[35:16] + 20'h0000_1 + bias_0 ; kernel1_y = psum_1[35:16] + 20'h0000_1 + bias_1 ; end								  
								     default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
								     endcase
								   end
						    default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
                            endcase						   
				          end
				  4'd11 : begin//relu function
		                    case(kernel0_y[19]) 
		                    1'b0 : begin
		                             case(kernel1_y[19])
		                             1'b0 : begin kernel0_y = kernel0_y ; kernel1_y = kernel1_y ; end
		                             1'b1 : begin kernel0_y = kernel0_y ; kernel1_y = 20'd0 ; end
		                             default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
								     endcase
		                           end
		                    1'b1 : begin
		                             case(kernel1_y[19])
		                             1'b0 : begin kernel0_y = 20'd0 ; kernel1_y = kernel1_y ; end
		                             1'b1 : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
		                             default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
								     endcase
		                           end 
		                    default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
						    endcase        
		                  end
				  default : begin kernel0_y = kernel0_y ; kernel1_y = kernel1_y ; end 
				  endcase
			    end
        S_right : begin
				    case(side_count)
				    4'd6 : begin
						     psum_0 = (ifmap_0 * kernel0_w0 + ifmap_1 * kernel0_w1) + (ifmap_3 * kernel0_w3 + ifmap_4 * kernel0_w4) + (ifmap_6 * kernel0_w6 + ifmap_7 * kernel0_w7);							
				             psum_1 = (ifmap_0 * kernel1_w0 + ifmap_1 * kernel1_w1) + (ifmap_3 * kernel1_w3 + ifmap_4 * kernel1_w4) + (ifmap_6 * kernel1_w6 + ifmap_7 * kernel1_w7);
				           end
				    4'd7 : begin//rounding
				             case(psum_0[15])
						     1'b0 : begin
							  	      case(psum_1[15])
                                      1'b0 : begin kernel0_y = psum_0[35:16] + bias_0 ; kernel1_y = psum_1[35:16] + bias_1 ; end//MSB 4 bits and LSB 16 bits overflow									
                                      1'b1 : begin kernel0_y = psum_0[35:16] + bias_0 ; kernel1_y = psum_1[35:16] + 20'h0000_1 + bias_1 ; end								  
								      default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
								      endcase
								    end
                             1'b1 : begin
								      case(psum_1[15])
                                      1'b0 : begin kernel0_y = psum_0[35:16] + 20'h0000_1 + bias_0 ; kernel1_y = psum_1[35:16] + bias_1 ; end									
                                      1'b1 : begin kernel0_y = psum_0[35:16] + 20'h0000_1 + bias_0 ; kernel1_y = psum_1[35:16] + 20'h0000_1 + bias_1 ; end								  
								      default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
								      endcase
								    end
						     default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
                             endcase						   
				           end
				    4'd8 : begin//relu function
		                     case(kernel0_y[19]) 
		                     1'b0 : begin
		                              case(kernel1_y[19])
		                              1'b0 : begin kernel0_y = kernel0_y ; kernel1_y = kernel1_y ; end
		                              1'b1 : begin kernel0_y = kernel0_y ; kernel1_y = 20'd0 ; end
		                              default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
								      endcase
		                            end
		                     1'b1 : begin
		                              case(kernel1_y[19])
		                              1'b0 : begin kernel0_y = 20'd0 ; kernel1_y = kernel1_y ; end
		                              1'b1 : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
		                              default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
								      endcase
		                            end 
		                     default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
						     endcase        
		                   end
				    default : begin kernel0_y = kernel0_y ; kernel1_y = kernel1_y ; end 
				    endcase
			     end
		S_left_bot : begin
				       case(corner_count)
				       4'd4 : begin
							    psum_0 = (ifmap_1 * kernel0_w1 + ifmap_2 * kernel0_w2) + (ifmap_4 * kernel0_w4 + ifmap_5 * kernel0_w5);						
				                psum_1 = (ifmap_1 * kernel1_w1 + ifmap_2 * kernel1_w2) + (ifmap_4 * kernel1_w4 + ifmap_5 * kernel1_w5);
				              end
				       4'd5 : begin//rounding
				                case(psum_0[15])
						        1'b0 : begin
									     case(psum_1[15])
                                         1'b0 : begin kernel0_y = psum_0[35:16] + bias_0 ; kernel1_y = psum_1[35:16] + bias_1 ; end//MSB 4 bits and LSB 16 bits overflow									
                                         1'b1 : begin kernel0_y = psum_0[35:16] + bias_0 ; kernel1_y = psum_1[35:16] + 20'h0000_1 + bias_1 ; end								  
								         default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
									     endcase
								       end
                                1'b1 : begin
									     case(psum_1[15])
                                         1'b0 : begin kernel0_y = psum_0[35:16] + 20'h0000_1 + bias_0 ; kernel1_y = psum_1[35:16] + bias_1 ; end									
                                         1'b1 : begin kernel0_y = psum_0[35:16] + 20'h0000_1 + bias_0 ; kernel1_y = psum_1[35:16] + 20'h0000_1 + bias_1 ; end								  
								         default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
								         endcase
								       end
						        default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
                                endcase						   
				              end
				       4'd6 : begin//relu function
		                        case(kernel0_y[19])
		                        1'b0 : begin
		                                 case(kernel1_y[19])
		                                 1'b0 : begin kernel0_y = kernel0_y ; kernel1_y = kernel1_y ; end
		                                 1'b1 : begin kernel0_y = kernel0_y ; kernel1_y = 20'd0 ; end
		                                 default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
									     endcase
		                               end
		                        1'b1 : begin
		                                 case(kernel1_y[19])
		                                 1'b0 : begin kernel0_y = 20'd0 ; kernel1_y = kernel1_y ; end
		                                 1'b1 : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
		                                 default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
									     endcase
		                               end 
		                        default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
						        endcase        
		                      end
				       default : begin kernel0_y = kernel0_y ; kernel1_y = kernel1_y ; end 
				       endcase
			         end
		S_bot : begin
				  case(side_count)
				  4'd6 : begin
						   psum_0 = (ifmap_0 * kernel0_w0 + ifmap_1 * kernel0_w1) + (ifmap_2 * kernel0_w2 + ifmap_3 * kernel0_w3) + (ifmap_4 * kernel0_w4 + ifmap_5 * kernel0_w5);							
				           psum_1 = (ifmap_0 * kernel1_w0 + ifmap_1 * kernel1_w1) + (ifmap_2 * kernel1_w2 + ifmap_3 * kernel1_w3) + (ifmap_4 * kernel1_w4 + ifmap_5 * kernel1_w5);
				         end
				  4'd7 : begin//rounding
				           case(psum_0[15])
						   1'b0 : begin
								    case(psum_1[15])
                                    1'b0 : begin kernel0_y = psum_0[35:16] + bias_0 ; kernel1_y = psum_1[35:16] + bias_1 ; end//MSB 4 bits and LSB 16 bits overflow									
                                    1'b1 : begin kernel0_y = psum_0[35:16] + bias_0 ; kernel1_y = psum_1[35:16] + 20'h0000_1 + bias_1 ; end								  
								    default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
								    endcase
								  end
                           1'b1 : begin
								    case(psum_1[15])
                                    1'b0 : begin kernel0_y = psum_0[35:16] + 20'h0000_1 + bias_0 ; kernel1_y = psum_1[35:16] + bias_1 ; end									
                                    1'b1 : begin kernel0_y = psum_0[35:16] + 20'h0000_1 + bias_0 ; kernel1_y = psum_1[35:16] + 20'h0000_1 + bias_1 ; end								  
								    default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
								    endcase
								  end
						   default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
                           endcase						   
				         end
				  4'd8 : begin//relu function
		                   case(kernel0_y[19]) 
		                   1'b0 : begin
		                            case(kernel1_y[19])
		                            1'b0 : begin kernel0_y = kernel0_y ; kernel1_y = kernel1_y ; end
		                            1'b1 : begin kernel0_y = kernel0_y ; kernel1_y = 20'd0 ; end
		                            default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
								    endcase
		                          end
		                   1'b1 : begin
		                            case(kernel1_y[19])
		                            1'b0 : begin kernel0_y = 20'd0 ; kernel1_y = kernel1_y ; end
		                            1'b1 : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
		                            default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
								    endcase
		                          end 
		                   default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
						   endcase        
		                 end
				  default : begin kernel0_y = kernel0_y ; kernel1_y = kernel1_y ; end 
				  endcase
			    end			 
		S_right_bot : begin
				        case(corner_count)
				        4'd4 : begin
							     psum_0 = (ifmap_0 * kernel0_w0 + ifmap_1 * kernel0_w1) + (ifmap_3 * kernel0_w3 + ifmap_4 * kernel0_w4);						
				                 psum_1 = (ifmap_0 * kernel1_w0 + ifmap_1 * kernel1_w1) + (ifmap_3 * kernel1_w3 + ifmap_4 * kernel1_w4);
				               end
				        4'd5 : begin//rounding
				                 case(psum_0[15])
						         1'b0 : begin
									      case(psum_1[15])
                                          1'b0 : begin kernel0_y = psum_0[35:16] + bias_0 ; kernel1_y = psum_1[35:16] + bias_1 ; end//MSB 4 bits and LSB 16 bits overflow									
                                          1'b1 : begin kernel0_y = psum_0[35:16] + bias_0 ; kernel1_y = psum_1[35:16] + 20'h0000_1 + bias_1 ; end								  
								          default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
									      endcase
								        end
                                 1'b1 : begin
									      case(psum_1[15])
                                          1'b0 : begin kernel0_y = psum_0[35:16] + 20'h0000_1 + bias_0 ; kernel1_y = psum_1[35:16] + bias_1 ; end									
                                          1'b1 : begin kernel0_y = psum_0[35:16] + 20'h0000_1 + bias_0 ; kernel1_y = psum_1[35:16] + 20'h0000_1 + bias_1 ; end								  
								          default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
								          endcase
								        end
						         default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
                                 endcase						   
				               end
				        4'd6 : begin//relu function
		                         case(kernel0_y[19])
		                         1'b0 : begin
		                                  case(kernel1_y[19])
		                                  1'b0 : begin kernel0_y = kernel0_y ; kernel1_y = kernel1_y ; end
		                                  1'b1 : begin kernel0_y = kernel0_y ; kernel1_y = 20'd0 ; end
		                                  default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
									      endcase
		                                end
		                         1'b1 : begin
		                                  case(kernel1_y[19])
		                                  1'b0 : begin kernel0_y = 20'd0 ; kernel1_y = kernel1_y ; end
		                                  1'b1 : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
		                                  default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
									      endcase
		                                end 
		                         default : begin kernel0_y = 20'd0 ; kernel1_y = 20'd0 ; end
						         endcase        
		                       end
				        default : begin kernel0_y = kernel0_y ; kernel1_y = kernel1_y ; end 
				        endcase
			          end
		endcase
	end
/*----------------layer FSM-----------------------------------------*/
always@(posedge clk)
	begin
	  if(reset) cur_layer <= L_idle;
	  else cur_layer <= next_layer;
	end
	
always@(*)
	begin
	  case(cur_layer)
	  L_idle : begin
	             if(row_change == 6'd0) next_layer = L0;
				 else next_layer = L_idle;
			   end
	  L0 : begin
             if(current_state == S_right_bot && corner_count == 4'd7) next_layer = L1;
			 else next_layer = L0;
		   end
	  L1 : begin
	         if(row_change == 6'd62 && pixel_first == 6'd62 && pool_cnt == 4'd9) next_layer = L2;
			 else next_layer = L1;
		   end
	  L2 : next_layer = L2;   
	  default : next_layer = L_idle;
	  endcase
	end
/*-----------------cwr setting-----------------------------*/
always@(*)
	begin
	  case(cur_layer)
      L0 : begin	  
		     case(current_state)
		     S_left_up : begin
					       case(corner_count)
					       4'd6 : cwr = 1;
					       4'd7 : cwr = 1;
					       default : cwr = 0;
					       endcase	
				         end
		     S_up : begin
			          case(side_count)
			          4'd8 : cwr = 1;
				      4'd9 : cwr = 1;
				      default : cwr = 0;
				      endcase	
			        end
		     S_right_up : begin
					        case(corner_count)
					        4'd6 : cwr = 1;
					        4'd7 : cwr = 1;
					        default : cwr = 0;
					        endcase	
				          end
		     S_left : begin
			            case(side_count)
			            4'd8 : cwr = 1;
				        4'd9 : cwr = 1;
				        default : cwr = 0;
				        endcase	
			          end
		     S_mid : begin
			           case(mid_count)
			           4'd11 : cwr = 1;
				       4'd12 : cwr = 1;
				       default : cwr = 0;
				       endcase	
			         end
		     S_right : begin
			             case(side_count)
			             4'd8 : cwr = 1;
				         4'd9 : cwr = 1;
				         default : cwr = 0;
				         endcase	
			           end
		     S_left_bot : begin
					        case(corner_count)
					        4'd6 : cwr = 1;
					        4'd7 : cwr = 1;
					        default : cwr = 0;
					        endcase	
				          end
		     S_bot : begin
			           case(side_count)
			           4'd8 : cwr = 1;
				       4'd9 : cwr = 1;
				       default : cwr = 0;
				       endcase	
			         end	
		     S_right_bot : begin
					         case(corner_count)
					         4'd6 : cwr = 1;
					         4'd7 : cwr = 1;
					         default : cwr = 0;
					         endcase	
				           end		
		     default : cwr = 0;
		     endcase		 
	       end
	  L1 : begin
             case(pool_cnt)
			 4'd4 : cwr = 1;
			 4'd9 : cwr = 1;
			 default : cwr = 0;
			 endcase
		   end
	  L2 : begin
             case(flat_cnt)
			 2'd0 : cwr = 0;
			 2'd1 : cwr = 1;
		     2'd2 : cwr = 0;
			 2'd3 : cwr = 1;
			 default : cwr = 0;
			 endcase
		   end	  
      default : cwr = 0;
      endcase
    end	  
/*-----------------crd setting------------------------------*/
always@(*)
	begin
	  case(cur_layer)
	  L1 : begin
	         case(pool_cnt)
			 4'd0 : crd = 1;
			 4'd1 : crd = 1;
			 4'd2 : crd = 1;
			 4'd3 : crd = 1;
			 4'd4 : crd = 0;
			 4'd5 : crd = 1;
			 4'd6 : crd = 1;
			 4'd7 : crd = 1;
			 4'd8 : crd = 1;
			 default : crd = 0;
			 endcase
		   end
	  L2 : begin
	         case(flat_cnt)
			 2'd0 : crd = 1;
			 2'd1 : crd = 0;
			 2'd2 : crd = 1;
			 2'd3 : crd = 0;
			 default : crd = 0;
			 endcase
		   end
	  default : crd = 0;
      endcase	  
	end
/*-----------------max_pooling------------------------------*/
always@(*)
	begin
	  case(cur_layer)
	  L1 : begin
             case(csel)
			 3'b001 : begin
			            case(pool_cnt)
						4'd0 : begin pool_max_0 = cdata_rd ; pool_max_1 = 20'd0 ; end
						4'd1 : begin						
						         if(pool_max_0 < cdata_rd) begin pool_max_0 = cdata_rd ; pool_max_1 = 20'd0 ; end
						         else  begin pool_max_0 = pool_max_0 ; pool_max_1 = 20'd0 ; end
						       end
						4'd2 : begin						
						         if(pool_max_0 < cdata_rd) begin pool_max_0 = cdata_rd ; pool_max_1 = 20'd0 ; end
						         else  begin pool_max_0 = pool_max_0 ; pool_max_1 = 20'd0 ; end
						       end
						4'd3 : begin						
						         if(pool_max_0 < cdata_rd) begin pool_max_0 = cdata_rd ; pool_max_1 = 20'd0 ; end
						         else  begin pool_max_0 = pool_max_0 ; pool_max_1 = 20'd0 ; end 
						       end
						4'd4 : begin pool_max_0 = pool_max_0 ; pool_max_1 = 20'd0 ; end
						default : begin pool_max_0 = 20'd0 ; pool_max_1 = 20'd0 ; end
                        endcase						
					  end
			 3'b010 : begin
			            case(pool_cnt)
						4'd5 : begin pool_max_1 = cdata_rd ; pool_max_0 = 20'd0 ; end
						4'd6 : begin						
						         if(pool_max_1 < cdata_rd) begin pool_max_1 = cdata_rd ; pool_max_0 = 20'd0 ; end
						         else  begin pool_max_1 = pool_max_1 ; pool_max_0 = 20'd0 ; end
						       end
						4'd7 : begin						
						         if(pool_max_1 < cdata_rd) begin pool_max_1 = cdata_rd ; pool_max_0 = 20'd0 ; end
						         else  begin pool_max_1 = pool_max_1 ; pool_max_0 = 20'd0 ; end
						       end
						4'd8 : begin						
						         if(pool_max_1 < cdata_rd) begin pool_max_1 = cdata_rd ; pool_max_0 = 20'd0 ; end
						         else  begin pool_max_1 = pool_max_1 ; pool_max_0 = 20'd0 ; end
						       end
                        4'd9 : begin pool_max_1 = pool_max_1 ; pool_max_0 = 20'd0 ; end
						default : begin pool_max_1 = 20'd0 ; pool_max_0 = 20'd0 ; end
                        endcase						
					  end
			 default : begin pool_max_0 = pool_max_0 ; pool_max_1 = pool_max_1 ; end	  
			 endcase
	       end
	  default : begin pool_max_0 = 20'd0 ; pool_max_1 = 20'd0 ; end
	  endcase
	end
/*-----------------convolution data write-------------------*/
always@(*)
	begin
	  case(cur_layer)
      L0 : begin	  
		     case(current_state)
		     S_left_up : begin
					       case(corner_count) 
		                   4'd6 : cdata_wr = kernel0_y;
		                   4'd7 : cdata_wr = kernel1_y;
		                   default : cdata_wr = 20'd0;
		                   endcase
				         end
		     S_up : begin
			          case(side_count) 
		              4'd8 : cdata_wr = kernel0_y;
		              4'd9 : cdata_wr = kernel1_y;
		              default : cdata_wr = 20'd0;
		              endcase
			        end
		     S_right_up : begin
					        case(corner_count) 
		                    4'd6 : cdata_wr = kernel0_y;
		                    4'd7 : cdata_wr = kernel1_y;
		                    default : cdata_wr = 20'd0;
		                    endcase
				          end
		     S_left : begin
			            case(side_count) 
		                4'd8 : cdata_wr = kernel0_y;
		                4'd9 : cdata_wr = kernel1_y;
		                default : cdata_wr = 20'd0;
		                endcase
			          end
		     S_mid : begin
			           case(mid_count) 
		               4'd11 : cdata_wr = kernel0_y;
		               4'd12 : cdata_wr = kernel1_y;
		               default : cdata_wr = 20'd0;
		               endcase
			         end	
		     S_right : begin
			             case(side_count) 
		                 4'd8 : cdata_wr = kernel0_y;
		                 4'd9 : cdata_wr = kernel1_y;
		                 default : cdata_wr = 20'd0;
		                 endcase
			           end
		     S_left_bot : begin
					        case(corner_count) 
		                    4'd6 : cdata_wr = kernel0_y;
		                    4'd7 : cdata_wr = kernel1_y;
		                    default : cdata_wr = 20'd0;
		                    endcase
				          end
		     S_bot : begin
			           case(side_count) 
		               4'd8 : cdata_wr = kernel0_y;
		               4'd9 : cdata_wr = kernel1_y;
		               default : cdata_wr = 20'd0;
		               endcase
			         end		
		     S_right_bot : begin
					         case(corner_count) 
		                     4'd6 : cdata_wr = kernel0_y;
		                     4'd7 : cdata_wr = kernel1_y;
		                     default : cdata_wr = 20'd0;
		                     endcase
				           end		
		     default : cdata_wr = 20'd0;
		     endcase
		   end
	  L1 : begin
             case(pool_cnt)
			 4'd4 : cdata_wr = pool_max_0;
			 4'd9 : cdata_wr = pool_max_1;
			 default : cdata_wr = 20'd0;
			 endcase
		   end
	  L2 : begin
             if(flat_cnt[0] == 1) cdata_wr = flatten;
			 else cdata_wr = 20'd0;
		   end	  
      default : cdata_wr = 20'd0;
      endcase	  
	end
/*--------------flatten--------------------------------------*/
always@(posedge clk)
	begin
	  if(flat_cnt[0] == 0) flatten = cdata_rd;
	  else flatten = 20'd0;
	end
/*--------------reading address setting----------------------*/
always@(*)
	begin
	  case(cur_layer)
	  L1 : begin
	         case(pool_cnt)
			 4'd0 : caddr_rd = pixel_first + (row_change << 6);
			 4'd1 : caddr_rd = pixel_first + (row_change << 6) + 12'd1;
			 4'd2 : caddr_rd = pixel_first + (row_change << 6) + 12'd64;
			 4'd3 : caddr_rd = pixel_first + (row_change << 6) + 12'd65;
			 4'd5 : caddr_rd = pixel_first + (row_change << 6);
			 4'd6 : caddr_rd = pixel_first + (row_change << 6) + 12'd1;
			 4'd7 : caddr_rd = pixel_first + (row_change << 6) + 12'd64;
			 4'd8 : caddr_rd = pixel_first + (row_change << 6) + 12'd65;
			 default : caddr_rd = 12'd0;
			 endcase
		   end
	  L2 : begin
	         if(flat_cnt[0] == 0) caddr_rd = pixel_first + (row_change << 5);
			 else caddr_rd = 12'd0;
		   end
	  default : caddr_rd = 12'd0;
      endcase	  
	end
/*--------------writing address setting----------------------*/
always@(*)
	begin
	  case(cur_layer)
      L0 : begin	  
		     case(current_state)
		     S_left_up : begin
				           case(corner_count)
					       4'd6 : caddr_wr = pixel_first ; 
		                   4'd7 : caddr_wr = pixel_first ;
		                   default : caddr_wr = 12'd0;
		                   endcase
				         end
		     S_up : begin
				      case(side_count)
				      4'd8 : caddr_wr = pixel_first + 12'd1; 
		              4'd9 : caddr_wr = pixel_first + 12'd1;
		              default : caddr_wr = 12'd0;
		              endcase
			        end
		     S_right_up : begin
				            case(corner_count)
					        4'd6 : caddr_wr = pixel_first + 12'd1; 
		                    4'd7 : caddr_wr = pixel_first + 12'd1;
		                    default : caddr_wr = 12'd0;
		                    endcase
				          end
		     S_left : begin
				        case(side_count)
				        4'd8 : caddr_wr = pixel_first + (row_change << 6); 
		                4'd9 : caddr_wr = pixel_first + (row_change << 6);
		                default : caddr_wr = 12'd0;
		                endcase
			          end
		     S_mid : begin
				       case(mid_count)
				       4'd11 : caddr_wr = pixel_first + (row_change << 6) + 12'd1; 
		               4'd12 : caddr_wr = pixel_first + (row_change << 6) + 12'd1;
		               default : caddr_wr = 12'd0;
		               endcase
			         end
		     S_right : begin
				         case(side_count)
				         4'd8 : caddr_wr = pixel_first + (row_change << 6) + 12'd1; 
		                 4'd9 : caddr_wr = pixel_first + (row_change << 6) + 12'd1;
		                 default : caddr_wr = 12'd0;
		                 endcase
			           end
		     S_left_bot : begin
				            case(corner_count)
					        4'd6 : caddr_wr = (row_change << 6); 
		                    4'd7 : caddr_wr = (row_change << 6);
		                    default : caddr_wr = 12'd0;
		                    endcase
				          end
		     S_bot : begin
				       case(side_count)
				       4'd8 : caddr_wr = pixel_first + (row_change << 6) + 12'd1; 
		               4'd9 : caddr_wr = pixel_first + (row_change << 6) + 12'd1;
		               default : caddr_wr = 12'd0;
		               endcase
			         end
		     S_right_bot : begin
				             case(corner_count)
					         4'd6 : caddr_wr = pixel_first + (row_change << 6) + 12'd1; 
		                     4'd7 : caddr_wr = pixel_first + (row_change << 6) + 12'd1;
		                     default : caddr_wr = 12'd0;
		                     endcase
				           end		
		     default : caddr_wr = 12'd0;
		     endcase
		   end
	  L1 : begin
             case(pool_cnt)
             4'd4 : caddr_wr = (pixel_first >> 1) + (row_change << 4);
             4'd9 : caddr_wr = (pixel_first >> 1) + (row_change << 4);
             default : caddr_wr = 12'd0;
             endcase
           end
	  L2 : begin
             case(flat_cnt)
			 2'd1 : caddr_wr = (pixel_first << 1) + (row_change << 6);
			 2'd3 : caddr_wr = (pixel_first << 1) + (row_change << 6) + 12'd1;
			 default : caddr_wr = 12'd0;
			 endcase
		   end	  
      default : caddr_wr = 12'd0;
      endcase	  
	end
/*---------------csel setting-----------------------------------*/	
always@(*)
    begin
      case(cur_layer)
      L0 : begin	  
		     case(current_state)
             S_left_up : begin
                           case(corner_count)
                           4'd6 : csel = 3'b001;
                           4'd7 : csel = 3'b010;
                           default : csel = 3'b000;
                           endcase
                         end
             S_up : begin
                      case(side_count)
                      4'd8 : csel = 3'b001;
                      4'd9 : csel = 3'b010;
                      default : csel = 3'b000;
                      endcase
                    end		
		     S_right_up : begin
		                    case(corner_count)
					        4'd6 : csel = 3'b001;
					        4'd7 : csel = 3'b010;
					        default : csel = 3'b000;
					        endcase
					      end
		     S_left : begin
                        case(side_count)
                        4'd8 : csel = 3'b001;
                        4'd9 : csel = 3'b010;
                        default : csel = 3'b000;
                        endcase
                      end
		     S_mid : begin
                       case(mid_count)
                       4'd11 : csel = 3'b001;
                       4'd12 : csel = 3'b010;
                       default : csel = 3'b000;
                       endcase
                     end	
		     S_right : begin
                         case(side_count)
                         4'd8 : csel = 3'b001;
                         4'd9 : csel = 3'b010;
                         default : csel = 3'b000;
                         endcase
                       end
		     S_left_bot : begin
		                    case(corner_count)
					        4'd6 : csel = 3'b001;
					        4'd7 : csel = 3'b010;
					        default : csel = 3'b000;
					        endcase
					      end
		     S_bot : begin
                       case(side_count)
                       4'd8 : csel = 3'b001;
                       4'd9 : csel = 3'b010;
                       default : csel = 3'b000;
                       endcase
                     end
		     S_right_bot : begin
		                     case(corner_count)
					         4'd6 : csel = 3'b001;
					         4'd7 : csel = 3'b010;
					         default : csel = 3'b000;
					         endcase
					       end		
		     default : csel = 3'b000;			 
             endcase
           end
	  L1 : begin
	         case(pool_cnt)
			 4'd0 : csel = 3'b001;
			 4'd1 : csel = 3'b001;
			 4'd2 : csel = 3'b001;
			 4'd3 : csel = 3'b001;
			 4'd4 : csel = 3'b011;
			 4'd5 : csel = 3'b010;
			 4'd6 : csel = 3'b010;
			 4'd7 : csel = 3'b010;
			 4'd8 : csel = 3'b010;
			 4'd9 : csel = 3'b100;
			 default : csel = 3'b000;
			 endcase
		   end
	  L2 : begin
	         case(flat_cnt)
			 2'd0 : csel = 3'b011;
			 2'd1 : csel = 3'b101;
			 2'd2 : csel = 3'b100;
			 2'd3 : csel = 3'b101;
			 endcase
		   end
	  default : csel = 3'b000;
      endcase
    end	  
endmodule