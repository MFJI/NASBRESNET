`timescale 1ns / 1ps

module Maxpool_3x3#(
	parameter							COPY  = 1'b1,
	parameter							DELAY = 4'd0,
	parameter							WIDTH = 27  ,
	parameter							LEN   = 3 
)(
	input	wire						i_sclk          ,
	
	input	wire						i_vsync         ,
	input	wire						i_hsync         ,
	input	wire						i_reuse         ,
	input	wire						i_valid         ,
	input	wire signed[WIDTH-1:0]		i_tdata[LEN-1:0],
	
	output	reg 						o_vsync         ,
	output	reg 						o_hsync         ,
	output	reg 						o_reuse         ,
	output	reg 						o_valid         ,
	output	reg  signed[WIDTH-1:0]		o_tdata         
);

//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
reg [2+DELAY:0]					vsync_s,hsync_s,reuse_s,valid_s;
reg signed[WIDTH-1:0]			max_c0,max_c1,max_c2,max_33;
reg [WIDTH*DELAY-1:0]			max_33_dly;
//----------------------------------------------//
//					CODING						//
//----------------------------------------------//
always@(posedge i_sclk)
begin
	vsync_s <= {vsync_s[1+DELAY:0],i_vsync};
	hsync_s <= {hsync_s[1+DELAY:0],i_hsync};
	reuse_s <= {reuse_s[1+DELAY:0],i_reuse};
	valid_s <= {valid_s[1+DELAY:0],i_valid};	
	
	o_vsync <= vsync_s[2+DELAY];
	o_hsync <= hsync_s[2+DELAY];
	o_reuse <= reuse_s[2+DELAY];
	o_valid <= valid_s[2+DELAY];
	
	if(valid_s[2+DELAY])
	begin
		if(DELAY==0)	o_tdata <= max_33;
		else			o_tdata <= max_33_dly[WIDTH*DELAY-1:WIDTH*(DELAY-1)];
	end
end

always@(posedge i_sclk)
begin
	if(i_hsync||reuse_s[1])										max_c0 <= {1'b1,{(WIDTH-1){1'b0}}};
	else if(COPY==0)
	begin
		if(i_tdata[2]>=i_tdata[1]&&i_tdata[2]>=i_tdata[0])		max_c0 <= i_tdata[2];
		else if(i_tdata[1]>=i_tdata[2]&&i_tdata[1]>=i_tdata[0])	max_c0 <= i_tdata[1];
		else if(i_tdata[0]>=i_tdata[2]&&i_tdata[0]>=i_tdata[1])	max_c0 <= i_tdata[0];
	end
	else if(i_valid)
	begin
		if(i_tdata[2]>=i_tdata[1]&&i_tdata[2]>=i_tdata[0])		max_c0 <= i_tdata[2];
		else if(i_tdata[1]>=i_tdata[2]&&i_tdata[1]>=i_tdata[0])	max_c0 <= i_tdata[1];
		else if(i_tdata[0]>=i_tdata[2]&&i_tdata[0]>=i_tdata[1])	max_c0 <= i_tdata[0];
	end
	
	max_c1 <= max_c0;
	max_c2 <= max_c1;
	
	if(i_vsync)								max_33 <= 'd0;
	else if(max_c0>=max_c1&&max_c0>=max_c2)	max_33 <= max_c0;
	else if(max_c1>=max_c0&&max_c1>=max_c2)	max_33 <= max_c1;
	else if(max_c2>=max_c0&&max_c2>=max_c1)	max_33 <= max_c2;
	
	if(DELAY<=1)	max_33_dly <= max_33;
	else			max_33_dly <= {max_33_dly[WIDTH*(DELAY-1)-1:0],max_33};
	
end

endmodule
