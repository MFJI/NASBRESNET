`timescale 1ns / 1ps

module Conv_image#(
	parameter							WIDTH_D  = 8 ,
	parameter							WIDTH_W  = 20,
	parameter							WIDTH_C  = 27,
	parameter							LEN      = 7 ,
	parameter							QUANT_D  = 5 
)(
	input	wire						i_sclk       ,

	input	wire						i_vsync      ,
	input	wire						i_hsync      ,
	input	wire						i_reuse      ,
	input	wire						i_valid      ,
	input	wire[WIDTH_D*3*LEN*LEN-1:0]	i_tdata      ,
	input	wire						i_weight_vld ,
	input	wire[WIDTH_W*3-1:0]			i_weight     ,
	
	output	reg 						o_vsync      ,
	output	reg 						o_hsync      ,
	output	reg 						o_reuse      ,
	output	reg 						o_valid      ,
	output	reg signed[WIDTH_C-1:0]		o_tdata      
);

//----------------------------------------------//
//					PARAMETER					//
//----------------------------------------------//
parameter	WIDTH_DI = WIDTH_D*3*LEN*LEN;
//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
reg [WIDTH_W*LEN*LEN-1:0]			weight_r   ,weight_r_r  ;
reg [WIDTH_W*LEN*LEN-1:0]			weight_g   ,weight_g_r  ;
reg [WIDTH_W*LEN*LEN-1:0]			weight_b   ,weight_b_r  ;
wire								cr_vsync   , cg_vsync   , cb_vsync   ;
wire								cr_hsync   , cg_hsync   , cb_hsync   ;
wire								cr_reuse   , cg_reuse   , cb_reuse   ;
wire								cr_valid   , cg_valid   , cb_valid   ;
wire signed[WIDTH_D+WIDTH_W+5:0]	cr_tdata   , cg_tdata   , cb_tdata   ;

reg 								cs_vsync   ;
reg 								cs_hsync   ;
reg 								cs_reuse   ;
reg 								cs_valid   ;
reg  signed[WIDTH_D+WIDTH_W+7:0]	cs_sdata   ;

//----------------------------------------------//
//					CODING						//
//----------------------------------------------//
always@(posedge i_sclk)
begin
	if(i_vsync)
	begin
		weight_r   <= 'd0;
		weight_g   <= 'd0;
		weight_b   <= 'd0;
		weight_r_r <= 'd0;
		weight_g_r <= 'd0;
		weight_b_r <= 'd0;
	end
	else
	begin
		if(i_weight_vld)
		begin
			weight_r <= {i_weight[WIDTH_W*3-1:WIDTH_W*2],weight_r[WIDTH_W*LEN*LEN-1:WIDTH_W]};
			weight_g <= {i_weight[WIDTH_W*2-1:WIDTH_W*1],weight_g[WIDTH_W*LEN*LEN-1:WIDTH_W]};
			weight_b <= {i_weight[WIDTH_W*1-1:WIDTH_W*0],weight_b[WIDTH_W*LEN*LEN-1:WIDTH_W]};
		end
		if(i_reuse)
		begin
			weight_r_r <= weight_r;
			weight_g_r <= weight_g;
			weight_b_r <= weight_b;
		end
	end
end

always@(posedge i_sclk)
begin
	cs_vsync <= cr_vsync;
	cs_hsync <= cr_hsync;
	cs_reuse <= cr_reuse;
	cs_valid <= cr_valid;
	cs_sdata <= cr_tdata + cg_tdata + cb_tdata;
	
	o_vsync  <= cs_vsync;
	o_hsync  <= cs_hsync;
	o_reuse  <= cs_reuse;
	o_valid  <= cs_valid;
	
	if(cs_sdata[QUANT_D-1])	o_tdata <= (cs_sdata>>QUANT_D) + 1'b1;
	else					o_tdata <= (cs_sdata>>QUANT_D);
end

Conv_7x7#(
	.WIDTH_D      (WIDTH_D                              ),
	.WIDTH_W      (WIDTH_W                              ),
	.LEN          (LEN                                  )
)Conv_7x7_R(
	.i_sclk       (i_sclk                               ),
	.i_vsync      (i_vsync                              ),
	.i_hsync      (i_hsync                              ),
	.i_reuse      (i_reuse                              ),
	.i_valid      (i_valid                              ),
	.i_tdata      (i_tdata [WIDTH_DI-1:WIDTH_DI/3*2]    ),
	.i_weight     (weight_r_r                           ),
	.o_vsync      (cr_vsync                             ),
	.o_hsync      (cr_hsync                             ),
	.o_reuse      (cr_reuse                             ),
	.o_valid      (cr_valid                             ),
	.o_tdata      (cr_tdata                             )
);

Conv_7x7#(
	.WIDTH_D      (WIDTH_D                              ),
	.WIDTH_W      (WIDTH_W                              ),
	.LEN          (LEN                                  )
)Conv_7x7_G(
	.i_sclk       (i_sclk                               ),
	.i_vsync      (i_vsync                              ),
	.i_hsync      (i_hsync                              ),
	.i_reuse      (i_reuse                              ),
	.i_valid      (i_valid                              ),
	.i_tdata      (i_tdata [WIDTH_DI/3*2-1:WIDTH_DI/3*1]),
	.i_weight     (weight_g_r                           ),
	.o_vsync      (cg_vsync                             ),
	.o_hsync      (cg_hsync                             ),
	.o_reuse      (cg_reuse                             ),
	.o_valid      (cg_valid                             ),
	.o_tdata      (cg_tdata                             )
);

Conv_7x7#(
	.WIDTH_D      (WIDTH_D                              ),
	.WIDTH_W      (WIDTH_W                              ),
	.LEN          (LEN                                  )
)Conv_7x7_B(
	.i_sclk       (i_sclk                               ),
	.i_vsync      (i_vsync                              ),
	.i_hsync      (i_hsync                              ),
	.i_reuse      (i_reuse                              ),
	.i_valid      (i_valid                              ),
	.i_tdata      (i_tdata [WIDTH_DI/3-1:0]             ),
	.i_weight     (weight_b_r                           ),
	.o_vsync      (cb_vsync                             ),
	.o_hsync      (cb_hsync                             ),
	.o_reuse      (cb_reuse                             ),
	.o_valid      (cb_valid                             ),
	.o_tdata      (cb_tdata                             )
);

endmodule
