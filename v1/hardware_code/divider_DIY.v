`timescale 1ns / 1ps

module divider_DIY#(
	parameter 				W_N = 0          , 
	parameter 				W_D = 0          , 
	parameter 				W_WN = W_N + W_D  
)(
    input	wire			i_sclk           ,
    input	wire			i_rstp           ,

    input	wire			i_div_valid      , 
    input	wire[W_N-1:0]	i_numerator      , 
    input	wire[W_D-1:0]	i_denominator    , 

    output	reg 			o_div_valid      , 
    output	reg [W_N-1:0]	o_quotient       , 
    output	reg [W_D-1:0]	o_remainder        
);

//--------------------------------------------------//
//						PARAM						//
//--------------------------------------------------//
parameter	W_E = W_N + W_N;	
parameter	IDLE  = 3'b001;
parameter	SHIFT = 3'b010;
parameter	DONE  = 3'b100;
//--------------------------------------------------//
//						SIGNALS						//
//--------------------------------------------------//
reg 				div_valid   ;
reg [W_N-1:0]		numerator   ;
reg [W_D-1:0]		denominator ;

reg [2:0]			state       ;
reg [W_E-1:0]		numerator_e ; 
reg [W_WN-1:0]		cnt_shift   ;
//--------------------------------------------------//
//					SIGNALS DELAY					//
//--------------------------------------------------//
always @(posedge i_sclk)
begin
	if(i_rstp)	div_valid <= 'd0;
	else		div_valid <= i_div_valid;

	if(i_rstp)
	begin
		numerator   <= 'd0;
		denominator <= 'd0;
	end
	else if(i_div_valid)
	begin
		numerator   <= i_numerator;
		denominator <= i_denominator;
	end
end
//--------------------------------------------------//
//						STATE						//
//--------------------------------------------------//
always @(posedge i_sclk)
begin
	if(i_rstp)
	begin
		state       <= IDLE;
		numerator_e <= 'd0;
		cnt_shift   <= 'd0;
		o_quotient  <= 'd0;
		o_remainder <= 'd0;
		o_div_valid <= 'd0;
	end
	else case(state)
	IDLE:
		begin
			o_div_valid     <= 'd0;
			if(div_valid)
			begin
				numerator_e <= numerator;
				cnt_shift   <= W_N;
				state       <= SHIFT;
			end
		end
	SHIFT:
		begin
			numerator_e = {numerator_e[W_E-2:0],1'b0};
			cnt_shift   <= cnt_shift - 'd1;
			if(numerator_e[W_E-1:W_N]>=denominator)
			begin
				numerator_e[0]         <= 'd1;
				numerator_e[W_E-1:W_N] <= numerator_e[W_E-1:W_N]-denominator;   
			end
			if(cnt_shift=='d1)
				state <= DONE;
		end
	DONE:
		begin
			o_quotient  <= numerator_e[W_N-1:0];
			o_remainder <= numerator_e[W_N+W_D-1:W_N];
			o_div_valid <= 'd1;
			state       <= IDLE;
		end
	default : state <= IDLE;
	endcase
end

endmodule