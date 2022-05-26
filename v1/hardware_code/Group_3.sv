`timescale 1ns / 1ps

module Group_3#(
	parameter						WIDTH_D    = 27   ,
	parameter						WIDTH_P    = 60   ,
	parameter						WIDTH_A_M0 = 18   ,
	parameter						WIDTH_B_M0 = 34   ,
	parameter						WIDTH_A_M1 = 16   ,
	parameter						WIDTH_B_M1 = 32   ,
	parameter						WIDTH_A_M2 = 21   ,
	parameter						WIDTH_B_M2 = 34   ,
	parameter						WIDTH_W_DS = 19   ,
	parameter						WIDTH_A_DS = 13   ,
	parameter						WIDTH_B_DS = 31   ,
	parameter						WIDTH_A_C0 = 14   ,
	parameter						WIDTH_B_C0 = 34   ,
	parameter						WIDTH_A_C1 = 25   ,
	parameter						WIDTH_B_C1 = 32   ,
	parameter						WIDTH_A_C2 = 16   ,
	parameter						WIDTH_B_C2 = 34   ,
	parameter						WIDTH_A_C3 = 15   ,
	parameter						WIDTH_B_C3 = 33   ,
	parameter						WIDTH_O    = 27   ,
	parameter						QUANT_W    = 16   ,
	parameter						CHANNEL    = 512  ,
	parameter						SIZE       = 7    ,
	parameter						LEN        = 3    
)(
	input	wire					i_sclk            ,
	input	wire					i_rstp            ,

	input	wire					i_vsync           ,
	input	wire					i_hsync           ,
	input	wire					i_reuse           ,
	input	wire					i_valid           ,
	input	wire[WIDTH_D-1:0]		i_tdata           ,
	input	wire[21:0]				i_param_vld       ,
	input	wire[WIDTH_P-1:0]		i_param           ,

	output	wire					o_vsync           ,
	output	wire					o_hsync           ,
	output	wire					o_reuse           ,
	output	wire					o_valid           ,
	output	wire[WIDTH_O-1:0]		o_tdata           
);

//----------------------------------------------//
//					PARAM						//
//----------------------------------------------//
parameter	WIDTH_B       = 2 ;
parameter	WIDTH_C       = 11;
parameter	WIDTH_BC      = 27;
parameter	WIDTH_OPS0_G3 = 27;
parameter	WIDTH_OPS1_G3 = 27;
parameter	WIDTH_DSW_G3  = 27;
parameter	WIDTH_DSB_G3  = 27;
parameter	WIDTH_BN0_G3  = 27;
parameter	WIDTH_BN1_G3  = 27;
parameter	WIDTH_BN2_G3  = 27;
parameter	WIDTH_BN3_G3  = 27;
parameter	WIDTH_G31     = 27;
parameter	WIDTH_G32     = 27;
parameter	WIDTH_OPS2_G3 = 27;
parameter	WIDTH_G33     = 27;
parameter	WIDTH_G34     = 27;
parameter	WIDTH_O_G3    = WIDTH_G34;
parameter	GAP           = 6'd25;
parameter	BATCH         = 5'd16;
//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
wire								ds_w_vld          ;
wire[WIDTH_W_DS*BATCH-1:0]			ds_w              ;
wire								c0_w_vld          ;
wire[2*LEN*LEN*BATCH-1:0]			c0_w              ;
wire[QUANT_W-1:0]					c0_we             ;
wire								c1_w_vld          ;
wire[2*LEN*LEN*BATCH-1:0]			c1_w              ;
wire[QUANT_W-1:0]					c1_we             ;
wire								c2_w_vld          ;
wire[2*LEN*LEN*BATCH-1:0]			c2_w              ;
wire[QUANT_W-1:0]					c2_we             ;
wire								c3_w_vld          ;
wire[2*LEN*LEN*BATCH-1:0]			c3_w              ;
wire[QUANT_W-1:0]					c3_we             ;
wire[WIDTH_A_DS-1:0]				ds_bn_a           ;
wire[WIDTH_B_DS-1:0]				ds_bn_b           ;
wire[WIDTH_A_M0-1:0]				m0_bn_a           ;
wire[WIDTH_B_M0-1:0]				m0_bn_b           ;
wire[WIDTH_A_M1-1:0]				m1_bn_a           ;
wire[WIDTH_B_M1-1:0]				m1_bn_b           ;
wire[WIDTH_A_M2-1:0]				m2_bn_a           ;
wire[WIDTH_B_M2-1:0]				m2_bn_b           ;
wire[WIDTH_A_C0-1:0]				c0_bn_a           ;
wire[WIDTH_B_C0-1:0]				c0_bn_b           ;
wire[WIDTH_A_C1-1:0]				c1_bn_a           ;
wire[WIDTH_B_C1-1:0]				c1_bn_b           ;
wire[WIDTH_A_C2-1:0]				c2_bn_a           ;
wire[WIDTH_B_C2-1:0]				c2_bn_b           ;
wire[WIDTH_A_C3-1:0]				c3_bn_a           ;
wire[WIDTH_B_C3-1:0]				c3_bn_b           ;

wire								b0_vsync          ;
wire								b0_hsync          ;
wire								b0_reuse          ;
wire								b0_valid          ;
wire[2*LEN*LEN-1:0]					b0_tdata          ;

wire								d_vsync           ;
wire								d_hsync           ;
wire								d_reuse           ;
wire								d_valid           ;
wire signed[WIDTH_D-1:0]			d_tdata           ;

wire								c0_vsync          ;
wire								c0_hsync          ;
wire								c0_reuse          ;
wire								c0_valid          ;
wire signed[WIDTH_BC-1:0]			c0_tdata          ;

wire								bn_0_vsync        ;
wire								bn_0_hsync        ;
wire								bn_0_reuse        ;
wire								bn_0_valid        ;
wire signed[WIDTH_BN0_G3-1:0]		bn_0_tdata        ;

wire								m0_vsync          ;
wire								m0_hsync          ;
wire								m0_reuse          ;
wire								m0_valid          ;
wire signed[WIDTH_D-1:0]			m0_tdata          ;

wire								ops_0_vsync       ;
wire								ops_0_hsync       ;
wire								ops_0_reuse       ;
wire								ops_0_valid       ;
wire signed[WIDTH_OPS0_G3-1:0]		ops_0_tdata       ;

reg 								g1_vsync          ;
reg 								g1_hsync          ;
reg 								g1_reuse          ;
reg 								g1_valid          ;
reg  signed[WIDTH_G31-1:0]			g1_tdata          ;

wire								b1_vsync          ;
wire								b1_hsync          ;
wire								b1_reuse          ;
wire								b1_valid          ;
wire[2*LEN-1:0]						b1_tdata          ;

wire								c1_vsync          ;
wire								c1_hsync          ;
wire								c1_reuse          ;
wire								c1_valid          ;
wire signed[WIDTH_BC-1:0]			c1_tdata          ;

wire								bn_1_vsync        ;
wire								bn_1_hsync        ;
wire								bn_1_reuse        ;
wire								bn_1_valid        ;
wire signed[WIDTH_BN1_G3-1:0]		bn_1_tdata        ;

wire								m1_vsync          ;
wire								m1_hsync          ;
wire								m1_reuse          ;
wire								m1_valid          ;
wire signed[WIDTH_D-1:0]			m1_tdata          ;

wire								ops_1_vsync       ;
wire								ops_1_hsync       ;
wire								ops_1_reuse       ;
wire								ops_1_valid       ;
wire signed[WIDTH_OPS1_G3-1:0]		ops_1_tdata       ;

wire								ds0_vsync         ;
wire								ds0_hsync         ;
wire								ds0_reuse         ;
wire								ds0_valid         ;
wire signed[WIDTH_DSW_G3-1:0]		ds0_tdata         ;

wire								dso_vsync         ;
wire								dso_hsync         ;
wire								dso_reuse         ;
wire								dso_valid         ;
wire signed[WIDTH_DSB_G3-1:0]		dso_tdata         ;

reg 								g2_vsync          ;
reg 								g2_hsync          ;
reg 								g2_reuse          ;
reg 								g2_valid          ;
reg  signed[WIDTH_G32-1:0]			g2_tdata          ;

wire								b2_vsync          ;
wire								b2_hsync          ;
wire								b2_reuse          ;
wire								b2_valid          ;
wire[2*LEN-1:0]						b2_tdata          ;

wire								c2_vsync          ;
wire								c2_hsync          ;
wire								c2_reuse          ;
wire								c2_valid          ;
wire signed[WIDTH_BC-1:0]			c2_tdata          ;

wire								bn_2_vsync        ;
wire								bn_2_hsync        ;
wire								bn_2_reuse        ;
wire								bn_2_valid        ;
wire signed[WIDTH_BN2_G3-1:0]		bn_2_tdata        ;

wire								md2_vsync         ;
wire								md2_hsync         ;
wire								md2_reuse         ;
wire								md2_valid         ;
wire signed[WIDTH_G32*LEN-1:0]		md2_tdata         ;
wire signed[WIDTH_G32-1:0]			md2_adata[LEN-1:0];

wire								m2_vsync          ;
wire								m2_hsync          ;
wire								m2_reuse          ;
wire								m2_valid          ;
wire signed[WIDTH_G32-1:0]			m2_tdata          ;

wire								ops_2_vsync       ;
wire								ops_2_hsync       ;
wire								ops_2_reuse       ;
wire								ops_2_valid       ;
wire signed[WIDTH_OPS2_G3-1:0]		ops_2_tdata       ;

wire								g34_vsync         ;
wire								g34_hsync         ;
wire								g34_reuse         ;
wire								g34_valid         ;
wire signed[WIDTH_G32-1:0]			g34_tdata         ;

reg 								g3_vsync          ;
reg 								g3_hsync          ;
reg 								g3_reuse          ;
reg 								g3_valid          ;
reg  signed[WIDTH_G33-1:0]			g3_tdata          ;

wire								b3_vsync          ;
wire								b3_hsync          ;
wire								b3_reuse          ;
wire								b3_valid          ;
wire[2*LEN-1:0]						b3_tdata          ;

wire								c3_vsync          ;
wire								c3_hsync          ;
wire								c3_reuse          ;
wire								c3_valid          ;
wire signed[WIDTH_BC-1:0]			c3_tdata          ;

wire								bn_3_vsync        ;
wire								bn_3_hsync        ;
wire								bn_3_reuse        ;
wire								bn_3_valid        ;
wire signed[WIDTH_BN3_G3-1:0]		bn_3_tdata        ;

reg 								g4_vsync          ;
reg 								g4_hsync          ;
reg 								g4_reuse          ;
reg 								g4_valid          ;
reg  signed[WIDTH_G34-1:0]			g4_tdata          ;

//----------------------------------------------//
//					LOADING						//
//----------------------------------------------//
Load_param_G3#(
	.WIDTH_P      (WIDTH_P                            ),
	.WIDTH_A_M0   (WIDTH_A_M0                         ),
	.WIDTH_B_M0   (WIDTH_B_M0                         ),
	.WIDTH_A_M1   (WIDTH_A_M1                         ),
	.WIDTH_B_M1   (WIDTH_B_M1                         ),
	.WIDTH_A_M2   (WIDTH_A_M2                         ),
	.WIDTH_B_M2   (WIDTH_B_M2                         ),
	.WIDTH_W_DS   (WIDTH_W_DS                         ),
	.WIDTH_A_DS   (WIDTH_A_DS                         ),
	.WIDTH_B_DS   (WIDTH_B_DS                         ),
	.WIDTH_A_C0   (WIDTH_A_C0                         ),
	.WIDTH_B_C0   (WIDTH_B_C0                         ),
	.WIDTH_A_C1   (WIDTH_A_C1                         ),
	.WIDTH_B_C1   (WIDTH_B_C1                         ),
	.WIDTH_A_C2   (WIDTH_A_C2                         ),
	.WIDTH_B_C2   (WIDTH_B_C2                         ),
	.WIDTH_A_C3   (WIDTH_A_C3                         ),
	.WIDTH_B_C3   (WIDTH_B_C3                         ),
	.QUANT_W      (QUANT_W                            ),
	.BATCH        (BATCH                              ),
	.LEN          (LEN                                ) 
)Load_param_G3_inst(
	.i_sclk    	  (i_sclk                             ),
	.i_rstp    	  (i_rstp                             ),
	.i_param_vld  (i_param_vld                        ),
	.i_param      (i_param                            ),
	.i_ds_w_req   (d_reuse                            ),
	.o_ds_w_vld   (ds_w_vld                           ),
	.o_ds_w       (ds_w                               ),
	.i_c0_w_req   (b0_reuse                           ),
	.o_c0_w_vld   (c0_w_vld                           ),
	.o_c0_w       (c0_w                               ),
	.o_c0_we      (c0_we                              ),
	.i_c1_w_req   (b1_reuse                           ),
	.o_c1_w_vld   (c1_w_vld                           ),
	.o_c1_w       (c1_w                               ),
	.o_c1_we      (c1_we                              ),
	.i_c2_w_req   (b2_reuse                           ),
	.o_c2_w_vld   (c2_w_vld                           ),
	.o_c2_w       (c2_w                               ),
	.o_c2_we      (c2_we                              ),
	.i_c3_w_req   (b3_reuse                           ),
	.o_c3_w_vld   (c3_w_vld                           ),
	.o_c3_w       (c3_w                               ),
	.o_c3_we      (c3_we                              ),
	.i_bn_m0_req  (m0_reuse                           ),
	.o_m0_bn_a    (m0_bn_a                            ),
	.o_m0_bn_b    (m0_bn_b                            ),
	.i_bn_m1_req  (m1_reuse                           ),
	.o_m1_bn_a    (m1_bn_a                            ),
	.o_m1_bn_b    (m1_bn_b                            ),
	.i_bn_m2_req  (m2_reuse                           ),
	.o_m2_bn_a    (m2_bn_a                            ),
	.o_m2_bn_b    (m2_bn_b                            ),
	.i_bn_ds_req  (ds0_reuse                          ),
	.o_ds_bn_a    (ds_bn_a                            ),
	.o_ds_bn_b    (ds_bn_b                            ),
	.i_bn_c0_req  (c0_reuse                           ),
	.o_c0_bn_a    (c0_bn_a                            ),
	.o_c0_bn_b    (c0_bn_b                            ),
	.i_bn_c1_req  (c1_reuse                           ),
	.o_c1_bn_a    (c1_bn_a                            ),
	.o_c1_bn_b    (c1_bn_b                            ),
	.i_bn_c2_req  (c2_reuse                           ),
	.o_c2_bn_a    (c2_bn_a                            ),
	.o_c2_bn_b    (c2_bn_b                            ),
	.i_bn_c3_req  (c3_reuse                           ),
	.o_c3_bn_a    (c3_bn_a                            ),
	.o_c3_bn_b    (c3_bn_b                            )
);
//----------------------------------------------//
//				PIPELING PADDING				//
//----------------------------------------------//
Reshape_Din_G3#(
	.WIDTH        (WIDTH_D                            ),
	.SIZE         (SIZE*2                             ),
	.CHANNEL      (CHANNEL/2                          ),
	.LEN          (LEN                                ),
	.STEP         (3'd2                               ),
	.GAP          (GAP                                ),
	.PADWAIT      (3900                               )
)Reshape_Din_G3_inst(
	.i_sclk    	  (i_sclk                             ),
	.i_vsync      (i_vsync                            ),
	.i_hsync      (i_hsync                            ),
	.i_reuse      (i_reuse                            ),
	.i_valid      (i_valid                            ),
	.i_tdata      (i_tdata                            ),
	.o_vsync_c    (b0_vsync                           ),
	.o_hsync_c    (b0_hsync                           ),
	.o_reuse_c    (b0_reuse                           ),
	.o_valid_c    (b0_valid                           ),
	.o_tdata_c    (b0_tdata                           ),
	.o_vsync_m    (m0_vsync                           ),
	.o_hsync_m    (m0_hsync                           ),
	.o_reuse_m    (m0_reuse                           ),
	.o_valid_m    (m0_valid                           ),
	.o_tdata_m    (m0_tdata                           ),
	.o_vsync_d    (d_vsync                            ),
	.o_hsync_d    (d_hsync                            ),
	.o_reuse_d    (d_reuse                            ),
	.o_valid_d    (d_valid                            ),
	.o_tdata_d    (d_tdata                            )
);
//----------------------------------------------//
//					BCONV_0						//
//----------------------------------------------//
Bconv_G3_0#(
	.DELAY        (4'd5                               ),
	.GAP          (GAP                                ),
	.BATCH        (BATCH                              ),
	.WIDTH_D      (WIDTH_B                            ),
	.WIDTH_C      (WIDTH_C                            ),
	.WIDTH_O      (WIDTH_BC                           ),
	.QUANT_W      (QUANT_W                            ),
	.CHANNEL      (CHANNEL                            ),
	.SIZE         (SIZE                               ),
	.LEN          (LEN                                ),
	.STEP         (2                                  ),
	.PADWAIT      (4110                               )
)Bconv_30(
	.i_sclk    	  (i_sclk                             ),
	.i_vsync      (b0_vsync                           ),
	.i_hsync      (b0_hsync                           ),
	.i_reuse      (b0_reuse                           ),
	.i_valid      (b0_valid                           ),
	.i_tdata      (b0_tdata                           ),
	.i_weight_vld (c0_w_vld                           ),
	.i_weight     (c0_w                               ),
	.i_weight_e   (c0_we                              ),
	.o_vsync      (c0_vsync                           ),
	.o_hsync      (c0_hsync                           ),
	.o_reuse      (c0_reuse                           ),
	.o_valid      (c0_valid                           ),
	.o_tdata      (c0_tdata                           )
);
BatchNormalization#(
	.WIDTH_D      (WIDTH_BC                           ),
	.WIDTH_A      (WIDTH_A_C0                         ),
	.WIDTH_B      (WIDTH_B_C0                         ),
	.WIDTH_O      (WIDTH_BN0_G3                       ),
	.QUANT_W      (QUANT_W                            )
)BatchNormalization_bconv_0(
	.i_sclk    	  (i_sclk                             ),
	.i_vsync      (c0_vsync                           ),
	.i_hsync      (c0_hsync                           ),
	.i_reuse      (c0_reuse                           ),
	.i_valid      (c0_valid                           ),
	.i_tdata      (c0_tdata                           ),
	.i_bn_a       (c0_bn_a                            ),
	.i_bn_b       (c0_bn_b                            ),
	.o_vsync      (bn_0_vsync                         ),
	.o_hsync      (bn_0_hsync                         ),
	.o_reuse      (bn_0_reuse                         ),
	.o_valid      (bn_0_valid                         ),
	.o_tdata      (bn_0_tdata                         )
);
//----------------------------------------------//
//					OPS 0						//
//----------------------------------------------//
BatchNormalization#(
	.WIDTH_D      (WIDTH_D                            ),
	.WIDTH_A      (WIDTH_A_M0                         ),
	.WIDTH_B      (WIDTH_B_M0                         ),
	.WIDTH_O      (WIDTH_OPS0_G3                      ),
	.QUANT_W      (QUANT_W                            )
)BatchNormalization_ops_0(
	.i_sclk    	  (i_sclk                             ),
	.i_vsync      (m0_vsync                           ),
	.i_hsync      (m0_hsync                           ),
	.i_reuse      (m0_reuse                           ),
	.i_valid      (m0_valid                           ),
	.i_tdata      (m0_tdata                           ),
	.i_bn_a       (m0_bn_a                            ),
	.i_bn_b       (m0_bn_b                            ),
	.o_vsync      (ops_0_vsync                        ),
	.o_hsync      (ops_0_hsync                        ),
	.o_reuse      (ops_0_reuse                        ),
	.o_valid      (ops_0_valid                        ),
	.o_tdata      (ops_0_tdata                        )
);
//----------------------------------------------//
//					GROUP_331					//
//----------------------------------------------//
always@(posedge i_sclk)
begin
	g1_vsync <= ops_0_vsync;
	g1_hsync <= ops_0_hsync;
	g1_reuse <= ops_0_reuse;
	g1_valid <= ops_0_valid;
	g1_tdata <= bn_0_tdata + ops_0_tdata;
end

Group_31#(
	.WIDTH_D      (WIDTH_G31                          ),
	.SIZE         (SIZE                               ),
	.CHANNEL      (CHANNEL                            ),
	.LEN          (LEN                                ),
	.GAP          (GAP                                ),
	.PADWAIT      (4110                               )
)Group_31_inst(
	.i_sclk    	  (i_sclk                             ),
	.i_vsync      (g1_vsync                           ),
	.i_hsync      (g1_hsync                           ),
	.i_reuse      (g1_reuse                           ),
	.i_valid      (g1_valid                           ),
	.i_tdata      (g1_tdata                           ),
	.o_vsync_c    (b1_vsync                           ),
	.o_hsync_c    (b1_hsync                           ),
	.o_reuse_c    (b1_reuse                           ),
	.o_valid_c    (b1_valid                           ),
	.o_tdata_c    (b1_tdata                           )
);
//----------------------------------------------//
//					BCONV_1						//
//----------------------------------------------//
Bconv_G3_x#(
	.DELAY        (4'd3                               ),
	.GAP          (GAP                                ),
	.BATCH        (BATCH                              ),
	.WIDTH_D      (WIDTH_B                            ),
	.WIDTH_C      (WIDTH_C                            ),
	.WIDTH_O      (WIDTH_BC                           ),
	.QUANT_W      (QUANT_W                            ),
	.CHANNEL      (CHANNEL                            ),
	.SIZE         (SIZE                               ),
	.LEN          (LEN                                ),
	.PADWAIT      (4110                               )
)Bconv_G3_x1(
	.i_sclk    	  (i_sclk                             ),
	.i_vsync      (b1_vsync                           ),
	.i_hsync      (b1_hsync                           ),
	.i_reuse      (b1_reuse                           ),
	.i_valid      (b1_valid                           ),
	.i_tdata      (b1_tdata                           ),
	.i_weight_vld (c1_w_vld                           ),
	.i_weight     (c1_w                               ),
	.i_weight_e   (c1_we                              ),
	.o_vsync      (c1_vsync                           ),
	.o_hsync      (c1_hsync                           ),
	.o_reuse      (c1_reuse                           ),
	.o_valid      (c1_valid                           ),
	.o_tdata      (c1_tdata                           )
);
BatchNormalization#(
	.WIDTH_D      (WIDTH_BC                           ),
	.WIDTH_A      (WIDTH_A_C1                         ),
	.WIDTH_B      (WIDTH_B_C1                         ),
	.WIDTH_O      (WIDTH_BN1_G3                       ),
	.QUANT_W      (QUANT_W                            )
)BatchNormalization_bconv_1(
	.i_sclk    	  (i_sclk                             ),
	.i_vsync      (c1_vsync                           ),
	.i_hsync      (c1_hsync                           ),
	.i_reuse      (c1_reuse                           ),
	.i_valid      (c1_valid                           ),
	.i_tdata      (c1_tdata                           ),
	.i_bn_a       (c1_bn_a                            ),
	.i_bn_b       (c1_bn_b                            ),
	.o_vsync      (bn_1_vsync                         ),
	.o_hsync      (bn_1_hsync                         ),
	.o_reuse      (bn_1_reuse                         ),
	.o_valid      (bn_1_valid                         ),
	.o_tdata      (bn_1_tdata                         )
);
//----------------------------------------------//
//					DOWNSAMPLE					//
//----------------------------------------------//
DownSample_G3#(
	.DELAY        (4'd14                              ),
	.GAP          (GAP                                ),
	.BATCH        (BATCH                              ),
	.WIDTH_D      (WIDTH_D                            ),
	.WIDTH_W      (WIDTH_W_DS                         ),
	.WIDTH_O      (WIDTH_DSW_G3                       ),
	.QUANT_W      (QUANT_W                            ),
	.CHANNEL      (CHANNEL                            ),
	.SIZE         (SIZE                               ),
	.PADWAIT      (4110                               )
)DownSample_G3_inst(
	.i_sclk    	  (i_sclk                             ),
	.i_vsync      (d_vsync                            ),
	.i_hsync      (d_hsync                            ),
	.i_reuse      (d_reuse                            ),
	.i_valid      (d_valid                            ),
	.i_tdata      (d_tdata                            ),
	.i_weight_vld (ds_w_vld                           ),
	.i_weight     (ds_w                               ),
	.o_vsync      (ds0_vsync                          ),
	.o_hsync      (ds0_hsync                          ),
	.o_reuse      (ds0_reuse                          ),
	.o_valid      (ds0_valid                          ),
	.o_tdata      (ds0_tdata                          )
);
BatchNormalization#(
	.WIDTH_D      (WIDTH_DSW_G3                       ),
	.WIDTH_A      (WIDTH_A_DS                         ),
	.WIDTH_B      (WIDTH_B_DS                         ),
	.WIDTH_O      (WIDTH_DSB_G3                       ),
	.QUANT_W      (QUANT_W                            )
)BatchNormalization_ds_1(
	.i_sclk    	  (i_sclk                             ),
	.i_vsync      (ds0_vsync                          ),
	.i_hsync      (ds0_hsync                          ),
	.i_reuse      (ds0_reuse                          ),
	.i_valid      (ds0_valid                          ),
	.i_tdata      (ds0_tdata                          ),
	.i_bn_a       (ds_bn_a                            ),
	.i_bn_b       (ds_bn_b                            ),
	.o_vsync      (dso_vsync                          ),
	.o_hsync      (dso_hsync                          ),
	.o_reuse      (dso_reuse                          ),
	.o_valid      (dso_valid                          ),
	.o_tdata      (dso_tdata                          )
);
//----------------------------------------------//
//					OPS 1						//
//----------------------------------------------//
Maxpool_cache_g3m1#(
	.WIDTH_D      (WIDTH_D                            ),
	.SIZE         (SIZE                               ),
	.CHANNEL      (CHANNEL                            ),
	.GAP          (GAP                                ),
	.PADWAIT      (4110                               )
)Maxpool_cache_g2m3_inst(
	.i_sclk    	  (i_sclk                             ),
	.i_vsync      (m0_vsync                           ),
	.i_hsync      (m0_hsync                           ),
	.i_reuse      (m0_reuse                           ),
	.i_valid      (m0_valid                           ),
	.i_tdata      (m0_tdata                           ),
	.o_vsync      (m1_vsync                           ),
	.o_hsync      (m1_hsync                           ),
	.o_reuse      (m1_reuse                           ),
	.o_valid      (m1_valid                           ),
	.o_tdata      (m1_tdata                           )
);
BatchNormalization#(
	.WIDTH_D      (WIDTH_D                            ),
	.WIDTH_A      (WIDTH_A_M1                         ),
	.WIDTH_B      (WIDTH_B_M1                         ),
	.WIDTH_O      (WIDTH_OPS1_G3                      ),
	.QUANT_W      (QUANT_W                            )
)BatchNormalization_ops_1(
	.i_sclk       (i_sclk                             ),
	.i_vsync      (m1_vsync                           ),
	.i_hsync      (m1_hsync                           ),
	.i_reuse      (m1_reuse                           ),
	.i_valid      (m1_valid                           ),
	.i_tdata      (m1_tdata                           ),
	.i_bn_a       (m1_bn_a                            ),
	.i_bn_b       (m1_bn_b                            ),
	.o_vsync      (ops_1_vsync                        ),
	.o_hsync      (ops_1_hsync                        ),
	.o_reuse      (ops_1_reuse                        ),
	.o_valid      (ops_1_valid                        ),
	.o_tdata      (ops_1_tdata                        )
);
//----------------------------------------------//
//					GROUP_32					//
//----------------------------------------------//
always@(posedge i_sclk)
begin
	g2_vsync <= dso_vsync;
	g2_hsync <= dso_hsync;
	g2_reuse <= dso_reuse;
	g2_valid <= dso_valid;
	g2_tdata <= dso_tdata + bn_1_tdata + ops_1_tdata;
end

Group_32#(
	.WIDTH_D      (WIDTH_G32                          ),
	.SIZE         (SIZE                               ),
	.CHANNEL      (CHANNEL                            ),
	.LEN          (LEN                                ),
	.GAP          (GAP                                ),
	.PADWAIT      (4110                               )
)Group_32_inst(
	.i_sclk    	  (i_sclk                             ),
	.i_vsync      (g2_vsync                           ),
	.i_hsync      (g2_hsync                           ),
	.i_reuse      (g2_reuse                           ),
	.i_valid      (g2_valid                           ),
	.i_tdata      (g2_tdata                           ),
	.o_vsync_c    (b2_vsync                           ),
	.o_hsync_c    (b2_hsync                           ),
	.o_reuse_c    (b2_reuse                           ),
	.o_valid_c    (b2_valid                           ),
	.o_tdata_c    (b2_tdata                           ),
	.o_vsync_m    (md2_vsync                          ),
	.o_hsync_m    (md2_hsync                          ),
	.o_reuse_m    (md2_reuse                          ),
	.o_valid_m    (md2_valid                          ),
	.o_tdata_m    (md2_tdata                          ),
	.o_vsync_g34  (g34_vsync                          ),
	.o_hsync_g34  (g34_hsync                          ),
	.o_reuse_g34  (g34_reuse                          ),
	.o_valid_g34  (g34_valid                          ),
	.o_tdata_g34  (g34_tdata                          )
);
//----------------------------------------------//
//					BCONV_2						//
//----------------------------------------------//
Bconv_G3_x#(
	.DELAY        (4'd3                               ),
	.GAP          (GAP                                ),
	.BATCH        (BATCH                              ),
	.WIDTH_D      (WIDTH_B                            ),
	.WIDTH_C      (WIDTH_C                            ),
	.WIDTH_O      (WIDTH_BC                           ),
	.QUANT_W      (QUANT_W                            ),
	.CHANNEL      (CHANNEL                            ),
	.SIZE         (SIZE                               ),
	.LEN          (LEN                                ),
	.PADWAIT      (4110                               )
)Bconv_G3_x2(
	.i_sclk    	  (i_sclk                             ),
	.i_vsync      (b2_vsync                           ),
	.i_hsync      (b2_hsync                           ),
	.i_reuse      (b2_reuse                           ),
	.i_valid      (b2_valid                           ),
	.i_tdata      (b2_tdata                           ),
	.i_weight_vld (c2_w_vld                           ),
	.i_weight     (c2_w                               ),
	.i_weight_e   (c2_we                              ),
	.o_vsync      (c2_vsync                           ),
	.o_hsync      (c2_hsync                           ),
	.o_reuse      (c2_reuse                           ),
	.o_valid      (c2_valid                           ),
	.o_tdata      (c2_tdata                           )
);
BatchNormalization#(
	.WIDTH_D      (WIDTH_BC                           ),
	.WIDTH_A      (WIDTH_A_C2                         ),
	.WIDTH_B      (WIDTH_B_C2                         ),
	.WIDTH_O      (WIDTH_BN2_G3                       ),
	.QUANT_W      (QUANT_W                            )
)BatchNormalization_bconv_2(
	.i_sclk    	  (i_sclk                             ),
	.i_vsync      (c2_vsync                           ),
	.i_hsync      (c2_hsync                           ),
	.i_reuse      (c2_reuse                           ),
	.i_valid      (c2_valid                           ),
	.i_tdata      (c2_tdata                           ),
	.i_bn_a       (c2_bn_a                            ),
	.i_bn_b       (c2_bn_b                            ),
	.o_vsync      (bn_2_vsync                         ),
	.o_hsync      (bn_2_hsync                         ),
	.o_reuse      (bn_2_reuse                         ),
	.o_valid      (bn_2_valid                         ),
	.o_tdata      (bn_2_tdata                         )
);
//----------------------------------------------//
//					OPS 2						//
//----------------------------------------------//
assign md2_adata[0] = md2_tdata[WIDTH_G32*1-1:WIDTH_G32*0];
assign md2_adata[1] = md2_tdata[WIDTH_G32*2-1:WIDTH_G32*1];
assign md2_adata[2] = md2_tdata[WIDTH_G32*3-1:WIDTH_G32*2];

Maxpool_3x3#(
	.WIDTH        (WIDTH_G32                          ),
	.LEN          (LEN                                )
)Maxpool_3x3_t2(
	.i_sclk       (i_sclk                             ),
	.i_vsync      (md2_vsync                          ),
	.i_hsync      (md2_hsync                          ),
	.i_reuse      (md2_reuse                          ),
	.i_valid      (md2_valid                          ),
	.i_tdata      (md2_adata                          ),
	.o_vsync      (m2_vsync                           ),
	.o_hsync      (m2_hsync                           ),
	.o_reuse      (m2_reuse                           ),
	.o_valid      (m2_valid                           ),
	.o_tdata      (m2_tdata                           )
);
BatchNormalization#(
	.WIDTH_D      (WIDTH_G32                          ),
	.WIDTH_A      (WIDTH_A_M2                         ),
	.WIDTH_B      (WIDTH_B_M2                         ),
	.WIDTH_O      (WIDTH_OPS2_G3                      ),
	.QUANT_W      (QUANT_W                            )
)BatchNormalization_ops_2(
	.i_sclk    	  (i_sclk                             ),
	.i_vsync      (m2_vsync                           ),
	.i_hsync      (m2_hsync                           ),
	.i_reuse      (m2_reuse                           ),
	.i_valid      (m2_valid                           ),
	.i_tdata      (m2_tdata                           ),
	.i_bn_a       (m2_bn_a                            ),
	.i_bn_b       (m2_bn_b                            ),
	.o_vsync      (ops_2_vsync                        ),
	.o_hsync      (ops_2_hsync                        ),
	.o_reuse      (ops_2_reuse                        ),
	.o_valid      (ops_2_valid                        ),
	.o_tdata      (ops_2_tdata                        )
);
//----------------------------------------------//
//					GROUP_33					//
//----------------------------------------------//
always@(posedge i_sclk)
begin
	g3_vsync <= bn_2_vsync;
	g3_hsync <= bn_2_hsync;
	g3_reuse <= bn_2_reuse;
	g3_valid <= bn_2_valid;
	g3_tdata <= bn_2_tdata + ops_2_tdata;
end

Group_33#(
	.WIDTH_D      (WIDTH_G33                          ),
	.SIZE         (SIZE                               ),
	.CHANNEL      (CHANNEL                            ),
	.LEN          (LEN                                ),
	.GAP          (GAP                                ),
	.PADWAIT      (4110                               )
)Group_33_inst(
	.i_sclk    	  (i_sclk                             ),
	.i_vsync      (g3_vsync                           ),
	.i_hsync      (g3_hsync                           ),
	.i_reuse      (g3_reuse                           ),
	.i_valid      (g3_valid                           ),
	.i_tdata      (g3_tdata                           ),
	.o_vsync_c    (b3_vsync                           ),
	.o_hsync_c    (b3_hsync                           ),
	.o_reuse_c    (b3_reuse                           ),
	.o_valid_c    (b3_valid                           ),
	.o_tdata_c    (b3_tdata                           )
);
//----------------------------------------------//
//					BCONV_3						//
//----------------------------------------------//
Bconv_G3_x#(
	.DELAY        (4'd0                               ),
	.GAP          (GAP                                ),
	.BATCH        (BATCH                              ),
	.WIDTH_D      (WIDTH_B                            ),
	.WIDTH_C      (WIDTH_C                            ),
	.WIDTH_O      (WIDTH_BC                           ),
	.QUANT_W      (QUANT_W                            ),
	.CHANNEL      (CHANNEL                            ),
	.SIZE         (SIZE                               ),
	.LEN          (LEN                                ),
	.PADWAIT      (4110                               )
)Bconv_G3_x3(
	.i_sclk    	  (i_sclk                             ),
	.i_vsync      (b3_vsync                           ),
	.i_hsync      (b3_hsync                           ),
	.i_reuse      (b3_reuse                           ),
	.i_valid      (b3_valid                           ),
	.i_tdata      (b3_tdata                           ),
	.i_weight_vld (c3_w_vld                           ),
	.i_weight     (c3_w                               ),
	.i_weight_e   (c3_we                              ),
	.o_vsync      (c3_vsync                           ),
	.o_hsync      (c3_hsync                           ),
	.o_reuse      (c3_reuse                           ),
	.o_valid      (c3_valid                           ),
	.o_tdata      (c3_tdata                           )
);
BatchNormalization#(
	.WIDTH_D      (WIDTH_BC                           ),
	.WIDTH_A      (WIDTH_A_C3                         ),
	.WIDTH_B      (WIDTH_B_C3                         ),
	.WIDTH_O      (WIDTH_BN3_G3                       ),
	.QUANT_W      (QUANT_W                            )
)BatchNormalization_bconv_3(
	.i_sclk    	  (i_sclk                             ),
	.i_vsync      (c3_vsync                           ),
	.i_hsync      (c3_hsync                           ),
	.i_reuse      (c3_reuse                           ),
	.i_valid      (c3_valid                           ),
	.i_tdata      (c3_tdata                           ),
	.i_bn_a       (c3_bn_a                            ),
	.i_bn_b       (c3_bn_b                            ),
	.o_vsync      (bn_3_vsync                         ),
	.o_hsync      (bn_3_hsync                         ),
	.o_reuse      (bn_3_reuse                         ),
	.o_valid      (bn_3_valid                         ),
	.o_tdata      (bn_3_tdata                         )
);
//----------------------------------------------//
//					GROUP_34					//
//----------------------------------------------//
always@(posedge i_sclk)
begin
	g4_vsync <= bn_3_vsync;
	g4_hsync <= bn_3_hsync;
	g4_reuse <= bn_3_reuse;
	g4_valid <= bn_3_valid;
	g4_tdata <= bn_3_tdata + g34_tdata + g34_tdata;
end

assign o_vsync = i_vsync;
assign o_hsync = g4_hsync;
assign o_reuse = g4_reuse;
assign o_valid = g4_valid;
assign o_tdata = g4_valid ? g4_tdata:'d0;

endmodule
