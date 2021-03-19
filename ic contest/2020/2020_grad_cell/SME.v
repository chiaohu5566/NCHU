module SME(clk,reset,chardata,isstring,ispattern,valid,match,match_index,n_state,c_state);
input clk;
input reset;
input [7:0] chardata;
input isstring;
input ispattern;
output match;
output [4:0] match_index;
output valid;
output c_state, n_state;

//=================================================

reg match;
reg [4:0] match_index;
reg valid;

reg [7:0] str [31:0];
reg [7:0] pat [7:0];
reg [3:0] str_l, pat_l;
reg [4:0] p, s, i;							//p and s are compared bit. 
										//i is match_index's counter.
reg [2:0] c_state, n_state;

//=======================FSM========================
parameter  IDLE = 3'b000;         //reset data
parameter  STR  = 3'b001;         //string input
parameter  PAT  = 3'b010;         //pattern input
parameter  COMP = 3'b011;         //compare
parameter  OUT  = 3'b100;
//=======================FSM========================
always @(posedge clk or posedge reset) begin
    if (reset)	c_state <= IDLE;
    else 		c_state <= n_state;
end

always @(*) begin
    case (c_state)
		IDLE : begin
        	if(isstring) n_state <= STR;
			else if(ispattern) n_state <= PAT;
			else n_state <= IDLE;
    	end
		STR  : begin
	    	if(isstring)begin
		 	 str[str_l] <= chardata;
			  str_l <= str_l + 4'b1;
			  n_state <= STR;
      	    end
			else  n_state <= PAT;
		end
   		PAT  : begin
	  		if(ispattern)begin
			pat[pat_l] <= chardata;
			pat_l <= pat_l + 4'b1;
			n_state <= PAT;
        	end
	   	 	else  n_state <= COMP;
		end
		COMP : begin
	    	if(valid)begin
			n_state <= IDLE;
			str_l <= 4'b0;
			pat_l <= 4'b0;
			end  
			else n_state <= COMP;
	    end 
		default : n_state <= IDLE;
  	endcase	
end
//============================================================
//========================  compare  =========================
//============================================================
always @(posedge clk) begin
	if (c_state == COMP) begin
		if (pat[0]==8'h5e && pat[pat_l-1]==8'h24) begin				//	^...$
			if (pat[p+1] == str[s]) begin
				
			end
		end
		else if	(pat[0]==8'h5e && pat[pat_l-1]!=8'h24) begin		//	^....	
			if ((p+1) != pat_l && s != str_l) begin
				if (pat[p+1] == str[s] || pat[p+1] == 8'h2e) begin
					p <= p + 4'b1; s <= s + 4'b1;
				end
				else if (str[s-1] == 8'h20 && pat[p+1] == str[s]) begin
					p <= p + 4'b1; s <= s + 4'b1;
				end
				else if (pat[p+1] == 8'h2a) begin
					if (pat[p+2] != str[s]) begin
						s <= s + 4'b1;
					end
					else begin
						p <= p +4'b1;	
					end	
				end
				else begin
					if (s != str_l) begin
						s <= s + 4'b1;
					end
					else begin
						valid <= 1; match <= 0;
					end
					
				end	
			end
			else if (s == str_l) begin
				valid <= 1;
				match <= 0;
			end
			else begin
			  match <= 1;
			  valid <= 1;
			  match_index <= ;
			end
		end
		else if (pat[0]!=8'h5e && pat[pat_l-1]!=8'h24) begin		//	.....
			if (p != pat_l && s != str_l) begin
				if (pat[p] == str[s] || pat[p] == 8'h2e) begin			//bit match and compare next bit.
					p <= p + 4'b1; s <= s + 4'b1;
					i <= i + 4'b1;	
				end
				else if (pat[p] = 8'h2a) begin							//next bit is "*" 
					if (pat[p+1] != str[s]) begin						//compare next string's bit until next bit is matched.
						s <= s + 4'b1;
						i <= i + 4'b1;
					end
					else begin
						s <= s + 4'b1; p <= p + 4'b1;
					end
				end
				else begin
					if (s != (str_l-1)) begin							//if "s" isn't the last bit of string, compare next bit.
						s <= s + 4'b1;
						i <= i + 4'b0;
					end
					else begin											//"s" is the last bit of string,so that is unmatch.
						valid <= 1;
						match <= 0;
					end	
				end  
			end
			else if (s == str_l) begin
				valid <= 1;
				match <= 0;
			end
			else begin
				valid <= 1;         									//pattern is match!!!
				match <= 1;
				match_index <= ((s-i)+4'b1);
			end
		end 
		else if (pat[0]!=8'h5e && pat[pat_l-1]==8'h24) begin		//	....$
		
		end
		else begin
			match <= 0;
			valid <= 1;
		end
	end
	else begin
		valid <= 0;
		i <= 4'b0; s <= 4'b0; p <= 4'b0;
	end
end
endmodule
