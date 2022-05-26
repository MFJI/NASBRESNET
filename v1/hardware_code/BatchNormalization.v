`timescale 1ns / 1ps

module BatchNormalization#(
	parameter							WIDTH_D  = 29 ,
	parameter							WIDTH_A  = 10 ,
	parameter							WIDTH_B  = 10 ,
	parameter							WIDTH_O  = 10 ,
	parameter							QUANT_W  = 16 
)(
	input	wire						i_sclk ,
	
	input	wire						i_vsync,
	input	wire						i_hsync,
	input	wire						i_reuse,
	input	wire						i_valid,
	input	wire signed[WIDTH_D-1:0]	i_tdata,
	input	wire signed[WIDTH_A-1:0]	i_bn_a ,
	input	wire signed[WIDTH_B-1:0]	i_bn_b ,
	
	output	reg 						o_vsync,
	output	reg 						o_hsync,
	output	reg 						o_reuse,
	output	reg 						o_valid,
	output	reg  signed[WIDTH_O-1:0]	o_tdata
);
//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
reg [1:0]											vsync_s;
reg [1:0]											hsync_s;
reg [1:0]											reuse_s;
reg [1:0]											valid_s;

(* use_dsp="yes" *)	reg signed[WIDTH_D+WIDTH_A-2:0]	mult_r;
reg  signed[WIDTH_D+WIDTH_A-1:0]					sum_p;
wire signed[WIDTH_D+WIDTH_A-1:0]					sum_p_abs;
//----------------------------------------------//
//					CODING						//
//----------------------------------------------//
always@(posedge i_sclk)
begin
	vsync_s <= {vsync_s[0:0],i_vsync};
	hsync_s <= {hsync_s[0:0],i_hsync};
	reuse_s <= {reuse_s[0:0],i_reuse};
	valid_s <= {valid_s[0:0],i_valid};
end

always@(posedge i_sclk)
begin
	mult_r <= i_tdata*i_bn_a;
	
	if(i_vsync)			sum_p <= 'd0;
	else if(valid_s[0])	sum_p <= mult_r + i_bn_b;
end

assign sum_p_abs = sum_p[WIDTH_D+WIDTH_A-1] ? (0-sum_p):sum_p;

always@(posedge i_sclk)
begin
	o_vsync <= vsync_s[1];
	o_hsync <= hsync_s[1];
	o_reuse <= reuse_s[1];
	o_valid <= valid_s[1];
	
	if(sum_p[WIDTH_D+WIDTH_A-1])	
		o_tdata <= 0 - (sum_p_abs[WIDTH_D+WIDTH_A-1:QUANT_W] + sum_p_abs[QUANT_W-1]);
	else
		o_tdata <= sum_p_abs[WIDTH_D+WIDTH_A-1:QUANT_W] + sum_p_abs[QUANT_W-1];
end

endmodule
