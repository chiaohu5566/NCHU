module SME(clk,reset,chardata,isstring,ispattern,valid,match,match_index);
input clk;
input reset;
input [7:0] chardata;
input isstring;
input ispattern;
output reg match;
output reg [4:0] match_index;
output reg valid;
// reg match;
// reg [4:0] match_index;
// reg valid;
parameter HEAD = 'h5e;
parameter FEET = 'h24;
parameter ENEY = 'h2e;
parameter ENEY_S = 'h2a;
parameter IDLE = 3'b000;
parameter LOAD = 3'b001;
parameter RELOAD = 3'b010;
parameter RELOAD_1 = 3'b011;
parameter COMPARE = 3'b100;
parameter CHECK = 3'b101;
parameter RESULT = 3'b110;


reg [1:0] load_ctrl;
wire [7:0] eney,head,feet,eney_s;
reg com_ctrl,result_ctrl1,load_finish,nxt_pat;
reg [7:0] string_1,string_2,string_3,string_4,string_5,string_6,string_7,string_8,string_9,string_10,string_11,string_12,string_13,string_14,string_15,string_16,string_17,string_18,string_19,string_20,string_21,string_22,string_23,string_24,string_25,string_26,string_27,string_28,string_29,string_30,string_31,string_32_dly;
reg [7:0] string_reg_1,string_reg_2,string_reg_3,string_reg_4,string_reg_5,string_reg_6,string_reg_7,string_reg_8,string_reg_9,string_reg_10,string_reg_11,string_reg_12,string_reg_13,string_reg_14,string_reg_15,string_reg_16,string_reg_17,string_reg_18,string_reg_19,string_reg_20,string_reg_21,string_reg_22,string_reg_23,string_reg_24,string_reg_25,string_reg_26,string_reg_27,string_reg_28,string_reg_29,string_reg_30,string_reg_31,string_reg_32;
reg [7:0] string_reg_c1,string_reg_c2,string_reg_c3,string_reg_c4,string_reg_c5,string_reg_c6,string_reg_c7,string_reg_c8;
reg [7:0] pat_1,pat_2,pat_3,pat_4,pat_5,pat_6,pat_7,pat_8;
reg [7:0] pat_cnt1,com_cnt1,pat_cnt2,string_cnt1,index_reg,string_reg_temp,string_cnt2;
reg [7:0] cs,ns;
wire [63:0] string_check,result_r1,result_r2;
wire [63:0] pat_check,result,pat_check_1;
wire [7:0] string_32;
wire [7:0] result_1,result_2,result_3,result_4,result_5,result_6,result_7,result_8;
wire [7:0] result_t1,result_t2,result_t3,result_t4,result_t5,result_t6,result_t7,result_t8;
wire [7:0] eney_1;
assign string_32 = (isstring)?  chardata : string_32;
assign string_check = {string_reg_c1,string_reg_c2,string_reg_c3,string_reg_c4,string_reg_c5,string_reg_c6,string_reg_c7,string_reg_c8};
assign pat_check = {pat_1,pat_2,pat_3,pat_4,pat_5,pat_6,pat_7,pat_8};
assign pat_check_1 = (pat_cnt1 == 1)? {pat_check[7:0],56'b0} : (pat_cnt1 == 2)? {pat_check[15:0],48'b0} : (pat_cnt1 == 3)? {pat_check[23:0],40'b0} : (pat_cnt1 == 4)? {pat_check[31:0],32'b0} :  (pat_cnt1 == 5)? {pat_check[39:0],24'b0} : (pat_cnt1 == 6)?  {pat_check[47:0],16'b0} :(pat_cnt1 == 7)? {pat_check[55:0],8'b0} : pat_check;
//assign eney_1 = (pat_cnt1 == 1)? eney << 7 : (pat_cnt1 == 2)? eney << 6 : (pat_cnt1 == 3)? eney << 5 : (pat_cnt1 == 4)? eney << 4 :  (pat_cnt1 == 5)? eney << 3 : (pat_cnt1 == 6)?  eney << 2 :(pat_cnt1 == 7)? eney<<1  : eney;
assign result = string_check - pat_check_1;
assign result_1 =  (eney[7]||(feet[7]&&(string_reg_c8=='h20||string_reg_c8==0))||(head[7]&&(string_reg_c1=='h20||string_reg_c1==0)))? 0 : string_reg_c1 - pat_check_1[63:56];
assign result_2 =  (eney[6]||(head[6]&&(string_reg_c1=='h20||string_reg_c1==0))||(feet[6]&&(string_reg_c8=='h20||string_reg_c8==0)))? 0 : string_reg_c2 - pat_check_1[55:48];
assign result_3 =  (eney[5]||(head[5]&&(string_reg_c1=='h20||string_reg_c1==0))||(feet[5]&&(string_reg_c8=='h20||string_reg_c8==0)))? 0 : string_reg_c3 - pat_check_1[47:40];
assign result_4 =  (eney[4]||(head[4]&&(string_reg_c1=='h20||string_reg_c1==0))||(feet[4]&&(string_reg_c8=='h20||string_reg_c8==0)))? 0 : string_reg_c4 - pat_check_1[39:32];
assign result_5 =  (eney[3]||(head[3]&&(string_reg_c1=='h20||string_reg_c1==0))||(feet[3]&&(string_reg_c8=='h20||string_reg_c8==0)))? 0 : string_reg_c5 - pat_check_1[31:24];
assign result_6 =  (eney[2]||(head[2]&&(string_reg_c1=='h20||string_reg_c1==0))||(feet[2]&&(string_reg_c8=='h20||string_reg_c8==0)))? 0 : string_reg_c6 - pat_check_1[23:16];
assign result_7 =  (eney[1]||(head[1]&&(string_reg_c1=='h20||string_reg_c1==0))||(feet[1]&&(string_reg_c8=='h20||string_reg_c8==0)))? 0 : string_reg_c7 - pat_check_1[15:8];
assign result_8 =  (eney[0]||(head[0]&&(string_reg_c1=='h20||string_reg_c1==0))||(feet[0]&&(string_reg_c8=='h20||string_reg_c8==0)))? 0 : string_reg_c8 - pat_check_1[7:0];
assign result_t1 = (eney_s[7]||eney_s[4])? 0:string_reg_c1 - pat_check_1[63:56] ;
assign result_t2 = (eney_s[6]||eney_s[4])? 0:string_reg_c2 - pat_check_1[55:48] ;
assign result_t3 = (eney_s[6]||eney_s[4]||eney_s[3]||eney_s[2])? 0:string_reg_c2 - pat_check_1[47:40] ;
assign result_t4 = (eney_s[6]||eney_s[4]||eney_s[3]||eney_s[2]||eney_s[1])?0:string_reg_c2 - pat_check_1[39:32] ;
assign result_t5 = (eney_s[6]||eney_s[3]||eney_s[2]||eney_s[1]||eney_s[0])? 0:string_reg_c2 - pat_check_1[31:24] ;
assign result_t6 = (eney_s[6]||eney_s[2]||eney_s[1]||eney_s[0])? 0 : string_reg_c2 - pat_check_1[23:16] ;
assign result_t7 = (eney_s[6]||eney_s[1])? 0:string_reg_c2 - pat_check_1[15:8] ;
assign result_t8 = (eney_s[0])?0:string_reg_c2 - pat_check_1[7:0] ;
assign result_r2 =  result_t1+result_t2+result_t3+result_t4+result_t5+result_t6+result_t7+result_8 ;
assign eney[7] = (pat_check_1[63:56] == ENEY)? 1 : 0; 
assign eney[6] = (pat_check_1[55:48] == ENEY)? 1 : 0; 
assign eney[5] = (pat_check_1[47:40] == ENEY)? 1 : 0;
assign eney[4] = (pat_check_1[39:32] == ENEY)? 1 : 0;
assign eney[3] = (pat_check_1[31:24] == ENEY)? 1 : 0;
assign eney[2] = (pat_check_1[23:16] == ENEY)? 1 : 0;
assign eney[1] = (pat_check_1[15:8] == ENEY)? 1 : 0;
assign eney[0] = (pat_check_1[7:0] == ENEY)? 1 : 0;  
assign result_r1 =  result_1+result_2+result_3+result_4+result_5+result_6+result_7+result_8 ; 
assign head[7] = (pat_check_1[63:56] == HEAD)? 1 : 0; 
assign head[6] = (pat_check_1[55:48] == HEAD)? 1 : 0; 
assign head[5] = (pat_check_1[47:40] == HEAD)? 1 : 0;
assign head[4] = (pat_check_1[39:32] == HEAD)? 1 : 0;
assign head[3] = (pat_check_1[31:24] == HEAD)? 1 : 0;
assign head[2] = (pat_check_1[23:16] == HEAD)? 1 : 0;
assign head[1] = (pat_check_1[15:8] == HEAD)? 1 : 0;
assign head[0] = (pat_check_1[7:0] == HEAD)? 1 : 0;  

assign feet[7] = (pat_check_1[63:56] == FEET)? 1 : 0; 
assign feet[6] = (pat_check_1[55:48] == FEET)? 1 : 0; 
assign feet[5] = (pat_check_1[47:40] == FEET)? 1 : 0;
assign feet[4] = (pat_check_1[39:32] == FEET)? 1 : 0;
assign feet[3] = (pat_check_1[31:24] == FEET)? 1 : 0;
assign feet[2] = (pat_check_1[23:16] == FEET)? 1 : 0;
assign feet[1] = (pat_check_1[15:8] == FEET)? 1 : 0;
assign feet[0] = (pat_check_1[7:0] == FEET)? 1 : 0;  
assign eney_s[7] = (pat_check_1[63:56] == ENEY_S)? 1 : 0; 
assign eney_s[6] = (pat_check_1[55:48] == ENEY_S)? 1 : 0; 
assign eney_s[5] = (pat_check_1[47:40] == ENEY_S)? 1 : 0;
assign eney_s[4] = (pat_check_1[39:32] == ENEY_S)? 1 : 0;
assign eney_s[3] = (pat_check_1[31:24] == ENEY_S)? 1 : 0;
assign eney_s[2] = (pat_check_1[23:16] == ENEY_S)? 1 : 0;
assign eney_s[1] = (pat_check_1[15:8] == ENEY_S)? 1 : 0;
assign eney_s[0] = (pat_check_1[7:0] == ENEY_S)? 1 : 0;  
//assign result_r1 = (pat_check_1[55:48] == ENEY && result_1==0 && result_3 ==0)?  1:0;
always @(posedge clk or posedge reset)begin
    if(reset)begin
        cs <= IDLE;
    end else begin
        cs <= ns;
    end
end
always @(*)begin
    case(cs)
        IDLE             :  ns = LOAD;
        LOAD             :  ns = (load_finish)? RELOAD : LOAD;
        RELOAD           :  ns = COMPARE;
        RELOAD_1         :  ns = COMPARE;
        COMPARE         :  ns = (com_ctrl)? CHECK : COMPARE;
        CHECK            :  ns = (result_ctrl1)? RESULT : (load_ctrl==2)? RELOAD_1 : (load_ctrl)? LOAD : CHECK;
        RESULT           :  ns = (nxt_pat)? RESULT : LOAD;
        default          :  ns = IDLE;
    endcase
end
always @(posedge clk or posedge reset)begin
if(reset)begin
  string_32_dly <= 0;
end else
string_32_dly <= string_32;
end
always @(posedge clk or posedge reset)begin
    if(reset)begin
       string_1 <= 0;
       string_2 <= 0;
       string_3 <= 0;
       string_4 <= 0;
       string_5 <= 0;
       string_6 <= 0;
       string_7 <= 0;
       string_8 <= 0;
       string_9 <= 0;
       string_10 <= 0;
       string_11 <= 0;
       string_12 <= 0;
       string_13 <= 0;
       string_14 <= 0;
       string_15 <= 0;
       string_16 <= 0;
       string_17 <= 0;
       string_18 <= 0;
       string_19 <= 0;
       string_20 <= 0;
       string_21 <= 0;
       string_22 <= 0;
       string_23 <= 0;
       string_24 <= 0;
       string_25 <= 0;
       string_26 <= 0;
       string_27 <= 0;
       string_28 <= 0;
       string_29 <= 0;
       string_30 <= 0;
       string_31 <= 0;
       string_cnt1 <= 0;
       pat_1 <= 0;
       pat_2 <= 0;
       pat_3 <= 0;
       pat_4 <= 0;
       pat_5 <= 0;
       pat_6 <= 0;
       pat_7 <= 0;
       pat_8 <= 0;
       pat_cnt1 <= 0;
       pat_cnt2 <= 0;
       load_finish <= 0;
       string_cnt2<=1;
     end else begin
     if(cs == LOAD)begin
         if(nxt_pat)begin 

            match <= 1;
            valid <= 1;
            match_index <=  (head > 0)?index_reg+1 : index_reg;
            pat_1 <= 0;
               pat_2 <= 0;
               pat_3 <= 0;
               pat_4 <= 0;
               pat_5 <= 0;
               pat_6 <= 0;
               pat_7 <= 0;
               pat_8 <= 0;
               pat_cnt1 <= 0;
          end
          if(valid)begin
             valid<=0;
             match<=0;
          end
         if(load_ctrl)begin
              valid <= 1'd1;
              match<=0;
              pat_cnt1 <= 0;
              pat_1 <= 0;
               pat_2 <= 0;
               pat_3 <= 0;
               pat_4 <= 0;
               pat_5 <= 0;
               pat_6 <= 0;
               pat_7 <= 0;
               pat_8 <= 0;
        
      
         end
         if(valid)begin
             valid <= 0;
          end
          if(isstring==0)begin string_cnt2 <=0;end
           
         if(isstring)begin
            string_1 <= string_2;
            string_2 <= string_3;
            string_3 <= string_4;
            string_4 <= string_5;
            string_5 <= string_6;
            string_6 <= string_7;
            string_7 <= string_8;
            string_8 <= string_9;
            string_9 <= string_10;
            string_10 <= string_11;
            string_11 <= string_12;
            string_12 <= string_13;
            string_13 <= string_14;
            string_14 <= string_15;
            string_15 <= string_16;
            string_16 <= string_17;
            string_17 <= string_18;
            string_18 <= string_19;
            string_19 <= string_20;
            string_20 <= string_21;
            string_21 <= string_22;
            string_22 <= string_23;
            string_23 <= string_24;
            string_24 <= string_25;
            string_25 <= string_26;
            string_26 <= string_27;
            string_27 <= string_28;
            string_28 <= string_29;
            string_29 <= string_30;
            string_30 <= string_31;
            string_31 <= string_32_dly;
            string_cnt1 <= string_cnt2;
            string_cnt2 <= string_cnt2 + 1;
          end
          if(ispattern)begin
             pat_1 <= pat_2;
             pat_2 <= pat_3;
             pat_3 <= pat_4;
             pat_4 <= pat_5;
             pat_5 <= pat_6;
             pat_6 <= pat_7;
             pat_7 <= pat_8;
             pat_8 <= chardata;
            

             pat_cnt1 <= pat_cnt1+1;
             pat_cnt2 <= 1;
          end
         load_finish <= 0;
         if(pat_cnt2)begin
            if(ispattern == 0)begin
               load_finish <= 1;
               pat_cnt2 <= 0;
             end
         end
         end
     end
end

always @(posedge clk or posedge reset)begin
    if(reset)begin
       string_reg_1 <= 0;
       string_reg_2 <= 0;
       string_reg_3 <= 0;
       string_reg_4 <= 0;
       string_reg_5 <= 0;
       string_reg_6 <= 0;
       string_reg_7 <= 0;
       string_reg_8 <= 0;
       string_reg_9 <= 0;
       string_reg_10 <= 0;
       string_reg_11 <= 0;
       string_reg_12 <= 0;
       string_reg_13 <= 0;
       string_reg_14 <= 0;
       string_reg_15 <= 0;
       string_reg_16 <= 0;
       string_reg_17 <= 0;
       string_reg_18 <= 0;
       string_reg_19 <= 0;
       string_reg_20 <= 0;
       string_reg_21 <= 0;
       string_reg_22 <= 0;
       string_reg_23 <= 0;
       string_reg_24 <= 0;
       string_reg_25 <= 0;
       string_reg_26 <= 0;
       string_reg_27 <= 0;
       string_reg_28 <= 0;
       string_reg_29 <= 0;
       string_reg_30 <= 0;
       string_reg_31 <= 0;
       string_reg_32 <= 0;
       string_reg_c1 <= 0;
       string_reg_c2 <= 0;
       string_reg_c3 <= 0;
       string_reg_c4 <= 0;
       string_reg_c5 <= 0;
       string_reg_c6 <= 0;
       string_reg_c7 <= 0;
       string_reg_c8 <= 0;
       com_ctrl <= 0;
    end else begin
       if(cs == RELOAD)begin
          string_reg_1 <= string_1;
          string_reg_2 <= string_2;
          string_reg_3 <= string_3;
          string_reg_4 <= string_4;
          string_reg_5 <= string_5;
          string_reg_6 <= string_6;
          string_reg_7 <= string_7;
          string_reg_8 <= string_8;
          string_reg_9 <= string_9;
          string_reg_10 <= string_10;
          string_reg_11 <= string_11;
          string_reg_12 <= string_12;
          string_reg_13 <= string_13;
          string_reg_14 <= string_14;
          string_reg_15 <= string_15;
          string_reg_16 <= string_16;
          string_reg_17 <= string_17;
          string_reg_18 <= string_18;
          string_reg_19 <= string_19;
          string_reg_20 <= string_20;
          string_reg_21 <= string_21;
          string_reg_22 <= string_22;
          string_reg_23 <= string_23;
          string_reg_24 <= string_24;
          string_reg_25 <= string_25;
          string_reg_26 <= string_26;
          string_reg_27 <= string_27;
          string_reg_28 <= string_28;
          string_reg_29 <= string_29;
          string_reg_30 <= string_30;
          string_reg_31 <= string_31;
          string_reg_32 <= string_32;
       end
       if(cs == RELOAD_1)begin
          string_reg_1 <= string_reg_2;
          string_reg_2 <= string_reg_3;
          string_reg_3 <= string_reg_4;
          string_reg_4 <= string_reg_5;
          string_reg_5 <= string_reg_6;
          string_reg_6 <= string_reg_7;
          string_reg_7 <= string_reg_8;
          string_reg_8 <= string_reg_9;
          string_reg_9 <= string_reg_10;
          string_reg_10 <= string_reg_11;
          string_reg_11 <= string_reg_12;
          string_reg_12 <= string_reg_13;
          string_reg_13 <= string_reg_14;
          string_reg_14 <= string_reg_15;
          string_reg_15 <= string_reg_16;
          string_reg_16 <= string_reg_17;
          string_reg_17 <= string_reg_18;
          string_reg_18 <= string_reg_19;
          string_reg_19 <= string_reg_20;
          string_reg_20 <= string_reg_21;
          string_reg_21 <= string_reg_22;
          string_reg_22 <= string_reg_23;
          string_reg_23 <= string_reg_24;
          string_reg_24 <= string_reg_25;
          string_reg_25 <= string_reg_26;
          string_reg_26 <= string_reg_27;
          string_reg_27 <= string_reg_28;
          string_reg_28 <= string_reg_29;
          string_reg_29 <= string_reg_30;
          string_reg_30 <= string_reg_31;
          string_reg_31 <= string_reg_32;
       end
       if(cs == COMPARE)begin
          string_reg_c1 <= (pat_cnt1 > 'd0)? string_reg_1 : 0;
          string_reg_c2 <= (pat_cnt1 > 'd1)? string_reg_2 : 0;
          string_reg_c3 <= (pat_cnt1 > 'd2)? string_reg_3 : 0;
          string_reg_c4 <= (pat_cnt1 > 'd3)? string_reg_4 : 0;
          string_reg_c5 <= (pat_cnt1 > 'd4)? string_reg_5 : 0;
          string_reg_c6 <= (pat_cnt1 > 'd5)? string_reg_6 : 0;
          string_reg_c7 <= (pat_cnt1 > 'd6)? string_reg_7 : 0;
          string_reg_c8 <= (pat_cnt1 > 'd7)? string_reg_8 : 0;
          com_ctrl <= 'h1;
       end
    end
    end
 
 always@(posedge clk or posedge reset)begin
    if(reset)begin
       string_reg_temp<=0;
    end else begin
       string_reg_temp <= string_reg_c1;
       end
    end
 always @(posedge clk or posedge reset)begin
    if(reset)begin
       load_ctrl <= 0;
       result_ctrl1 <= 0;

//       com_cnt1 <= 0;
    end else begin 
    if(cs == LOAD) begin
         if(nxt_pat)begin 
         if( result_ctrl1 == 1) result_ctrl1 <= 0;end
      if(load_ctrl)begin
        com_cnt1<=0;
      end
    end
    if(cs == COMPARE)begin
      com_cnt1 <= (com_cnt1>='d32)? com_cnt1 :com_cnt1+1;
       end
       if(cs == LOAD)begin
        if(load_ctrl)begin
          load_ctrl <= 0;
       end
      end
       if(cs == CHECK)begin
//           com_cnt1 <= com_cnt1 + 1;
          if(result == 0 || result_r1 ==0 ||result_r2 == 0)begin
             result_ctrl1 <= 1;
             load_ctrl <= 0;
             index_reg <=((string_cnt1 + com_cnt1)>'d31)? string_cnt1 + com_cnt1-'d32 : 0;
          end
          if(result_ctrl1==1) begin
              load_ctrl <= 2'b00;
            if(cs == RESULT)begin
             
             com_cnt1 <= 0;
       end
           end
          else begin
          if(result != 0)begin
             load_ctrl <= 2'b10;
          if(com_cnt1 == 'd32)begin
             load_ctrl <= 2'b01;
             end
          end
end
        end
      end
   end

 always @(posedge clk or posedge reset)begin
    if(reset)begin
       nxt_pat <= 0;
    end else begin 
      if(cs == LOAD)begin
        if(valid)begin
           nxt_pat <= 0;
        end
end 
       if(cs == RESULT)begin
             nxt_pat <= 1;
    
       end
     end   
end
endmodule
