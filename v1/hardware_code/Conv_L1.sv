`timescale 1ns / 1ps

module Conv_L1#(
	parameter							WIDTH_D  = 24 ,
	parameter							WIDTH_W  = 20 ,
	parameter							WIDTH_C  = 27 ,
	parameter							SIZE     = 112,
	parameter							THREAD   = 2  ,
	parameter							REUSE    = 32 ,
	parameter							LEN      = 7  ,
	parameter							QUANT_D  = 5  
)(
	input	wire						i_sclk   ,
	input	wire						i_vsync  ,
	input	wire						i_hsync  ,
	input	wire						i_reuse  ,
	input	wire						i_valid  ,
	input	wire[WIDTH_D*LEN*LEN-1:0]	i_tdata  ,
	input	wire						i_cw_vld ,
	input	wire[WIDTH_W*3*THREAD-1:0]	i_cw     ,

	output	reg 						o_vsync  ,
	output	reg 						o_hsync  ,
	output	reg 						o_reuse  ,
	output	reg 						o_valid  ,
	output	reg [WIDTH_C*THREAD-1:0]	o_tdata
);

//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
reg 							vsync_d1  ;
reg 							hsync_d1  ;
reg 							reuse_d1  ;
reg 							valid_d1  ;
reg [WIDTH_D*LEN*LEN-1:0]		tdata_d1  ;
reg 							cw_vld_d1 ;
reg [WIDTH_W*3-1:0]				cw_t1     ;
reg [WIDTH_W*3-1:0]				cw_t2     ;

wire							c1_vsync  ;
wire							c1_hsync  ;
wire							c1_reuse  ;
wire							c1_valid  ;
wire signed[WIDTH_C:0]			c1_tdata  ;
wire[WIDTH_C-1:0]				r1_tdata  ;

wire							c2_vsync  ;
wire							c2_hsync  ;
wire							c2_reuse  ;
wire							c2_valid  ;
wire signed[WIDTH_C:0]			c2_tdata  ;
wire[WIDTH_C-1:0]				r2_tdata  ;

//----------------------------------------------//
//					CODING						//
//----------------------------------------------//
always@(posedge i_sclk)
begin
	vsync_d1  <= i_vsync;
	hsync_d1  <= i_hsync;
	reuse_d1  <= i_reuse;
	valid_d1  <= i_valid;
	tdata_d1  <= i_tdata;
	cw_vld_d1 <= i_cw_vld;
	cw_t1     <= i_cw[WIDTH_W*3*(THREAD-1)-1:WIDTH_W*3*(THREAD-2)];
	cw_t2     <= i_cw[WIDTH_W*3*THREAD-1:WIDTH_W*3*(THREAD-1)];
end

always@(posedge i_sclk)
begin
	o_vsync <= c1_vsync;
	o_hsync <= c1_hsync;
	o_reuse <= c1_reuse;
	o_valid <= c1_valid;
	o_tdata <= {r2_tdata,r1_tdata};
end

Conv_image#(
	.WIDTH_D      (WIDTH_D/3        ),
	.WIDTH_W      (WIDTH_W          ),
	.WIDTH_C      (WIDTH_C+1        ),
	.LEN          (LEN              ),
	.QUANT_D      (QUANT_D          )
)Conv_image_t1(
	.i_sclk       (i_sclk           ),
	.i_vsync      (vsync_d1         ),
	.i_hsync      (hsync_d1         ),
	.i_reuse      (reuse_d1         ),
	.i_valid      (valid_d1         ),
	.i_tdata      (tdata_d1         ),
	.i_weight_vld (cw_vld_d1        ),
	.i_weight     (cw_t1            ),
	.o_vsync      (c1_vsync         ),
	.o_hsync      (c1_hsync         ),
	.o_reuse      (c1_reuse         ),
	.o_valid      (c1_valid         ),
	.o_tdata      (c1_tdata         )
);

Relu#(
	.WIDTH        (WIDTH_C+1        )
)Relu_t1(
	.i_tdata      (c1_tdata         ),
	.o_tdata      (r1_tdata         )
);

Conv_image#(
	.WIDTH_D      (WIDTH_D/3        ),
	.WIDTH_W      (WIDTH_W          ),
	.WIDTH_C      (WIDTH_C+1        ),
	.LEN          (LEN              ),
	.QUANT_D      (QUANT_D          )
)Conv_image_t2(
	.i_sclk       (i_sclk           ),
	.i_vsync      (vsync_d1         ),
	.i_hsync      (hsync_d1         ),
	.i_reuse      (reuse_d1         ),
	.i_valid      (valid_d1         ),
	.i_tdata      (tdata_d1         ),
	.i_weight_vld (cw_vld_d1        ),
	.i_weight     (cw_t2            ),
	.o_vsync      (c2_vsync         ),
	.o_hsync      (c2_hsync         ),
	.o_reuse      (c2_reuse         ),
	.o_valid      (c2_valid         ),
	.o_tdata      (c2_tdata         )
);

Relu#(
	.WIDTH        (WIDTH_C+1        )
)Relu_t2(
	.i_tdata      (c2_tdata         ),
	.o_tdata      (r2_tdata         )
);

endmodule
