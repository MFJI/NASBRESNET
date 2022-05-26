`timescale 1ns / 1ps

module Conv_7x7#(
	parameter							WIDTH_D = 8  ,
	parameter							WIDTH_W = 20 ,
	parameter							LEN     = 7  
)(
	input	wire						i_sclk  ,
	
	input	wire						i_vsync ,
	input	wire						i_hsync ,
	input	wire						i_reuse ,
	input	wire						i_valid ,
	input	wire[WIDTH_D*LEN*LEN-1:0]	i_tdata ,
	input	wire[WIDTH_W*LEN*LEN-1:0]	i_weight,
	
	output	reg 						o_vsync ,
	output	reg 						o_hsync ,
	output	reg 						o_reuse ,
	output	reg 						o_valid ,
	output	reg [WIDTH_D+WIDTH_W+5:0]	o_tdata 
);

//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
reg [3:0]											vsync_dly;
reg [3:0]											hsync_dly;
reg [3:0]											reuse_dly;
reg [3:0]											valid_dly;

wire signed[WIDTH_D-1:0]							aim_d[LEN*LEN-1:0];
wire signed[WIDTH_W-1:0]							aim_w[LEN*LEN-1:0];
(* use_dsp="yes" *)	reg signed[WIDTH_D+WIDTH_W-1:0]	mult_r[LEN*LEN-1:0];
reg  signed[WIDTH_D+WIDTH_W+2:0]					sum_R[6:0];
reg  signed[WIDTH_D+WIDTH_W+5:0]					sum_c;

//----------------------------------------------//
//					CODING						//
//----------------------------------------------//
genvar c;
generate
	for (c=0; c<(LEN*LEN); c=c+1)
	begin
		assign aim_d[c] = i_tdata[WIDTH_D*(c+1)-1:WIDTH_D*c];
		assign aim_w[c] = i_weight[WIDTH_W*(c+1)-1:WIDTH_W*c];
		always@(posedge i_sclk)
		begin
			mult_r[c] <= aim_d[c]*aim_w[c];
		end
	end
endgenerate

always@(posedge i_sclk)
begin
	vsync_dly  <= {vsync_dly[2:0],i_vsync};
	hsync_dly  <= {hsync_dly[2:0],i_hsync};
	reuse_dly  <= {reuse_dly[2:0],i_reuse};
	valid_dly  <= {valid_dly[2:0],i_valid};
end

always@(posedge i_sclk)
begin
	sum_R[0] <= mult_r[ 0] + mult_r[ 1] + mult_r[ 2] + mult_r[ 3] + mult_r[ 4] + mult_r[ 5] + mult_r[ 6];
	sum_R[1] <= mult_r[ 7] + mult_r[ 8] + mult_r[ 9] + mult_r[10] + mult_r[11] + mult_r[12] + mult_r[13];
	sum_R[2] <= mult_r[14] + mult_r[15] + mult_r[16] + mult_r[17] + mult_r[18] + mult_r[19] + mult_r[20];
	sum_R[3] <= mult_r[21] + mult_r[22] + mult_r[23] + mult_r[24] + mult_r[25] + mult_r[26] + mult_r[27];
	sum_R[4] <= mult_r[28] + mult_r[29] + mult_r[30] + mult_r[31] + mult_r[32] + mult_r[33] + mult_r[34];
	sum_R[5] <= mult_r[35] + mult_r[36] + mult_r[37] + mult_r[38] + mult_r[39] + mult_r[40] + mult_r[41];
	sum_R[6] <= mult_r[42] + mult_r[43] + mult_r[44] + mult_r[45] + mult_r[46] + mult_r[47] + mult_r[48];
	
	if(valid_dly[1])
		sum_c <= sum_R[0] + sum_R[1] + sum_R[2] + sum_R[3] + sum_R[4] + sum_R[5] + sum_R[6];
	else
		sum_c <= 'd0;
end

always@(posedge i_sclk)
begin
	o_vsync <= vsync_dly[2];
	o_hsync <= hsync_dly[2];
	o_reuse <= reuse_dly[2];
	o_valid <= valid_dly[2];
	o_tdata <= sum_c;
end

endmodule
