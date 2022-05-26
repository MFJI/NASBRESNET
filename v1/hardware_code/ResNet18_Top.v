`timescale 1ns / 1ps

module ResNet18_Top#(
	parameter					WIDTH_P = 32,
	parameter					WIDTH_O = 10
)(
	input	wire				i_sclk      ,
	input	wire				i_rstp      ,
	
	output	wire				o_ready     ,
	input	wire				i_valid     ,
	input	wire[WIDTH_P-1:0]	i_tdata     ,
	
	input	wire				i_ready     ,
	output	wire				o_valid     ,
	output	wire[WIDTH_O-1:0]	o_tdata     
);

//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
wire							predict_vld ;
wire[9:0]						predict     ;
wire[84:0]						param_vld   ;
wire[59:0]						param       ;
//----------------------------------------------//
//					CODING						//
//----------------------------------------------//
DecodeParameter#(
	.WIDTH_P                   (WIDTH_P     ),
	.WIDTH_O                   (WIDTH_O     )
)DecodeParameter_inst(
	.i_sclk                    (i_sclk      ),
	.i_rstp                    (i_rstp      ),
	.o_ready                   (o_ready     ),
	.i_valid                   (i_valid     ),
	.i_tdata                   (i_tdata     ),
	.i_ready                   (i_ready     ),
	.o_valid                   (o_valid     ),
	.o_tdata                   (o_tdata     ),
	.o_param_vld               (param_vld   ),
	.o_param                   (param       ),
	.i_predict_vld             (predict_vld ),
	.i_predict                 (predict     )
);
ResNet18 ResNet18_inst(
	.i_sclk                    (i_sclk      ),
	.i_rstp                    (i_rstp      ),
	.i_param_vld               (param_vld   ),
	.i_param                   (param       ),
	.o_predict_vld             (predict_vld ),
	.o_predict                 (predict     ) 
);

endmodule
