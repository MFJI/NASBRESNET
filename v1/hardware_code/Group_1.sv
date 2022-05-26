`timescale 1ns / 1ps

module Group_1#(
	parameter						WIDTH_D    = 27   ,
	parameter						WIDTH_P    = 60   ,
	parameter						WIDTH_A_M0 = 17   ,
	parameter						WIDTH_B_M0 = 34   ,
	parameter						WIDTH_A_M3 = 20   ,
	parameter						WIDTH_B_M3 = 35   ,
	parameter						WIDTH_W_DS = 19   ,
	parameter						WIDTH_A_DS = 15   ,
	parameter						WIDTH_B_DS = 33   ,
	parameter						WIDTH_A_C0 = 13   ,
	parameter						WIDTH_B_C0 = 33   ,
	parameter						WIDTH_A_C1 = 16   ,
	parameter						WIDTH_B_C1 = 33   ,
	parameter						WIDTH_A_C2 = 15   ,
	parameter						WIDTH_B_C2 = 34   ,
	parameter						WIDTH_A_C3 = 16   ,
	parameter						WIDTH_B_C3 = 34   ,
	parameter						WIDTH_O    = 27   ,
	parameter						QUANT_W    = 16   ,
	parameter						CHANNEL    = 128  ,
	parameter						SIZE       = 28   ,
	parameter						LEN        = 3    
)(
	input	wire					i_sclk            ,
	input	wire					i_rstp            ,

	input	wire					i_vsync           ,
	input	wire					i_hsync           ,
	input	wire					i_reuse           ,
	input	wire					i_valid           ,
	input	wire[WIDTH_D-1:0]		i_tdata           ,
	input	wire[19:0]				i_param_vld       ,
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
parameter	WIDTH_OPS0_G1 = 27;
parameter	WIDTH_DSW_G1  = 27;
parameter	WIDTH_DSB_G1  = 27;
parameter	WIDTH_BN0_G1  = 27;
parameter	WIDTH_BN1_G1  = 27;
parameter	WIDTH_BN2_G1  = 27;
parameter	WIDTH_BN3_G1  = 27;
parameter	WIDTH_G11     = 27;
parameter	WIDTH_G12     = 27;
parameter	WIDTH_G13     = 27;
parameter	WIDTH_G14     = 27;
parameter	WIDTH_OPS3_G1 = 27;
parameter	WIDTH_O_G1    = WIDTH_G14;
parameter	GAP           = 6'd4;
parameter	BATCH         = 4'd4;
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
wire[WIDTH_A_M3-1:0]				m3_bn_a           ;
wire[WIDTH_B_M3-1:0]				m3_bn_b           ;
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
wire signed[WIDTH_BN0_G1-1:0]		bn_0_tdata        ;

wire								m0_vsync          ;
wire								m0_hsync          ;
wire								m0_reuse          ;
wire								m0_valid          ;
wire signed[WIDTH_D-1:0]			m0_tdata          ;

wire								ops_0_vsync       ;
wire								ops_0_hsync       ;
wire								ops_0_reuse       ;
wire								ops_0_valid       ;
wire signed[WIDTH_OPS0_G1-1:0]		ops_0_tdata       ;

reg 								g1_vsync          ;
reg 								g1_hsync          ;
reg 								g1_reuse          ;
reg 								g1_valid          ;
reg  signed[WIDTH_G11-1:0]			g1_tdata          ;

wire								b1_vsync          ;
wire								b1_hsync          ;
wire								b1_reuse          ;
wire								b1_valid          ;
wire[2*LEN-1:0]						b1_tdata          ;

wire								g12_vsync         ;
wire								g12_hsync         ;
wire								g12_reuse         ;
wire								g12_valid         ;
wire signed[WIDTH_G11-1:0]			g12_tdata         ;

wire								c1_vsync          ;
wire								c1_hsync          ;
wire								c1_reuse          ;
wire								c1_valid          ;
wire signed[WIDTH_BC-1:0]			c1_tdata          ;

wire								bn_1_vsync        ;
wire								bn_1_hsync        ;
wire								bn_1_reuse        ;
wire								bn_1_valid        ;
wire signed[WIDTH_BN1_G1-1:0]		bn_1_tdata        ;

wire								ds0_vsync         ;
wire								ds0_hsync         ;
wire								ds0_reuse         ;
wire								ds0_valid         ;
wire signed[WIDTH_DSW_G1-1:0]		ds0_tdata         ;

wire								dso_vsync         ;
wire								dso_hsync         ;
wire								dso_reuse         ;
wire								dso_valid         ;
wire signed[WIDTH_DSB_G1-1:0]		dso_tdata         ;

reg 								g2_vsync          ;
reg 								g2_hsync          ;
reg 								g2_reuse          ;
reg 								g2_valid          ;
reg  signed[WIDTH_G12-1:0]			g2_tdata          ;

wire								b2_vsync          ;
wire								b2_hsync          ;
wire								b2_reuse          ;
wire								b2_valid          ;
wire[2*LEN-1:0]						b2_tdata          ;

wire								g23_vsync         ;
wire								g23_hsync         ;
wire								g23_reuse         ;
wire								g23_valid         ;
wire signed[WIDTH_G12-1:0]			g23_tdata         ;

wire								g24_vsync         ;
wire								g24_hsync         ;
wire								g24_reuse         ;
wire								g24_valid         ;
wire signed[WIDTH_G12-1:0]			g24_tdata         ;

wire								c2_vsync          ;
wire								c2_hsync          ;
wire								c2_reuse          ;
wire								c2_valid          ;
wire signed[WIDTH_BC-1:0]			c2_tdata          ;

wire								bn_2_vsync        ;
wire								bn_2_hsync        ;
wire								bn_2_reuse        ;
wire								bn_2_valid        ;
wire signed[WIDTH_BN2_G1-1:0]		bn_2_tdata        ;

reg 								g3_vsync          ;
reg 								g3_hsync          ;
reg 								g3_reuse          ;
reg 								g3_valid          ;
reg  signed[WIDTH_G13-1:0]			g3_tdata          ;

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
wire signed[WIDTH_BN3_G1-1:0]		bn_3_tdata        ;

wire								md3_vsync         ;
wire								md3_hsync         ;
wire								md3_reuse         ;
wire								md3_valid         ;
wire[WIDTH_G12*LEN-1:0]				md3_tdata         ;
wire signed[WIDTH_G12-1:0]			md3_adata[LEN-1:0];

wire								m3_vsync          ;
wire								m3_hsync          ;
wire								m3_reuse          ;
wire								m3_valid          ;
wire[WIDTH_G12-1:0]					m3_tdata          ;

wire								ops_3_vsync       ;
wire								ops_3_hsync       ;
wire								ops_3_reuse       ;
wire								ops_3_valid       ;
wire signed[WIDTH_OPS3_G1-1:0]		ops_3_tdata       ;

reg 								g4_vsync          ;
reg 								g4_hsync          ;
reg 								g4_reuse          ;
reg 								g4_valid          ;
reg  signed[WIDTH_G14-1:0]			g4_tdata          ;

//----------------------------------------------//
//					LOADING						//
//----------------------------------------------//
Load_param_G1#(
	.WIDTH_P      (WIDTH_P                            ),
	.WIDTH_A_M0   (WIDTH_A_M0                         ),
	.WIDTH_B_M0   (WIDTH_B_M0                         ),
	.WIDTH_A_M3   (WIDTH_A_M3                         ),
	.WIDTH_B_M3   (WIDTH_B_M3                         ),
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
)Load_param_G1_inst(
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
	.i_bn_m3_req  (m3_reuse                           ),
	.o_m3_bn_a    (m3_bn_a                            ),
	.o_m3_bn_b    (m3_bn_b                            ),
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
Reshape_Din_G1#(
	.WIDTH        (WIDTH_D                            ),
	.SIZE         (SIZE*2                             ),
	.CHANNEL      (CHANNEL/2                          ),
	.LEN          (LEN                                ),
	.STEP         (3'd2                               ),
	.GAP          (GAP                                ),
	.PADWAIT      (3653                               )
)Reshape_Din_G1_inst(
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
Bconv_G1_0#(
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
	.PADWAIT      (3800                               )
)Bconv_10(
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
	.WIDTH_O      (WIDTH_BN0_G1                       ),
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
	.WIDTH_O      (WIDTH_OPS0_G1                      ),
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
//					GROUP_11					//
//----------------------------------------------//
always@(posedge i_sclk)
begin
	g1_vsync <= ops_0_vsync;
	g1_hsync <= ops_0_hsync;
	g1_reuse <= ops_0_reuse;
	g1_valid <= ops_0_valid;
	g1_tdata <= bn_0_tdata + ops_0_tdata;
end

Group_11#(
	.WIDTH_D      (WIDTH_G11                          ),
	.SIZE         (SIZE                               ),
	.CHANNEL      (CHANNEL                            ),
	.LEN          (LEN                                ),
	.GAP          (GAP                                ),
	.PADWAIT      (3800                               )
)Group_11_inst(
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
	.o_tdata_c    (b1_tdata                           ),
	.o_vsync_g12  (g12_vsync                          ),
	.o_hsync_g12  (g12_hsync                          ),
	.o_reuse_g12  (g12_reuse                          ),
	.o_valid_g12  (g12_valid                          ),
	.o_tdata_g12  (g12_tdata                          )
);
//----------------------------------------------//
//					BCONV_1						//
//----------------------------------------------//
Bconv_G1_x#(
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
	.PADWAIT      (3800                               )
)Bconv_G1_x1(
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
	.WIDTH_O      (WIDTH_BN1_G1                       ),
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
DownSample_G1#(
	.DELAY        (4'd11                              ),
	.GAP          (GAP                                ),
	.BATCH        (BATCH                              ),
	.WIDTH_D      (WIDTH_D                            ),
	.WIDTH_W      (WIDTH_W_DS                         ),
	.WIDTH_O      (WIDTH_DSW_G1                       ),
	.QUANT_W      (QUANT_W                            ),
	.CHANNEL      (CHANNEL                            ),
	.SIZE         (SIZE                               ),
	.PADWAIT      (3800                               )
)DownSample_G1_inst(
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
	.WIDTH_D      (WIDTH_DSW_G1                       ),
	.WIDTH_A      (WIDTH_A_DS                         ),
	.WIDTH_B      (WIDTH_B_DS                         ),
	.WIDTH_O      (WIDTH_DSB_G1                       ),
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
//					GROUP_12					//
//----------------------------------------------//
always@(posedge i_sclk)
begin
	g2_vsync <= dso_vsync;
	g2_hsync <= dso_hsync;
	g2_reuse <= dso_reuse;
	g2_valid <= dso_valid;
	g2_tdata <= dso_tdata + bn_1_tdata + g12_tdata;
end

Group_12#(
	.WIDTH_D      (WIDTH_G12                          ),
	.SIZE         (SIZE                               ),
	.CHANNEL      (CHANNEL                            ),
	.LEN          (LEN                                ),
	.GAP          (GAP                                ),
	.PADWAIT      (3800                               )
)Group_12_inst(
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
	.o_vsync_g23  (g23_vsync                          ),
	.o_hsync_g23  (g23_hsync                          ),
	.o_reuse_g23  (g23_reuse                          ),
	.o_valid_g23  (g23_valid                          ),
	.o_tdata_g23  (g23_tdata                          ),
	.o_vsync_m    (md3_vsync                          ),
	.o_hsync_m    (md3_hsync                          ),
	.o_reuse_m    (md3_reuse                          ),
	.o_valid_m    (md3_valid                          ),
	.o_tdata_m    (md3_tdata                          ),
	.o_vsync_g24  (g24_vsync                          ),
	.o_hsync_g24  (g24_hsync                          ),
	.o_reuse_g24  (g24_reuse                          ),
	.o_valid_g24  (g24_valid                          ),
	.o_tdata_g24  (g24_tdata                          )
);
//----------------------------------------------//
//					BCONV_2						//
//----------------------------------------------//
Bconv_G1_x#(
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
	.PADWAIT      (3800                               )
)Bconv_G1_x2(
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
	.WIDTH_O      (WIDTH_BN2_G1                       ),
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
//					GROUP_13					//
//----------------------------------------------//
always@(posedge i_sclk)
begin
	g3_vsync <= bn_2_vsync;
	g3_hsync <= bn_2_hsync;
	g3_reuse <= bn_2_reuse;
	g3_valid <= bn_2_valid;
	g3_tdata <= bn_2_tdata + g23_tdata;
end

Group_13#(
	.WIDTH_D      (WIDTH_G13                          ),
	.SIZE         (SIZE                               ),
	.CHANNEL      (CHANNEL                            ),
	.LEN          (LEN                                ),
	.GAP          (GAP                                ),
	.PADWAIT      (3800                               )
)Group_13_inst(
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
Bconv_G1_x#(
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
	.PADWAIT      (3800                               )
)Bconv_G1_x3(
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
	.WIDTH_O      (WIDTH_BN3_G1                       ),
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
//					OPS 3						//
//----------------------------------------------//
assign md3_adata[0] = md3_tdata[WIDTH_G12*1-1:WIDTH_G12*0];
assign md3_adata[1] = md3_tdata[WIDTH_G12*2-1:WIDTH_G12*1];
assign md3_adata[2] = md3_tdata[WIDTH_G12*3-1:WIDTH_G12*2];

Maxpool_3x3#(
	.DELAY        (4'd3                               ),
	.WIDTH        (WIDTH_G12                          ),
	.LEN          (LEN                                )
)Maxpool_3x3_t2(
	.i_sclk    	  (i_sclk                             ),
	.i_vsync      (md3_vsync                          ),
	.i_hsync      (md3_hsync                          ),
	.i_reuse      (md3_reuse                          ),
	.i_valid      (md3_valid                          ),
	.i_tdata      (md3_adata                          ),
	.o_vsync      (m3_vsync                           ),
	.o_hsync      (m3_hsync                           ),
	.o_reuse      (m3_reuse                           ),
	.o_valid      (m3_valid                           ),
	.o_tdata      (m3_tdata                           )
);
BatchNormalization#(
	.WIDTH_D      (WIDTH_G12                          ),
	.WIDTH_A      (WIDTH_A_M3                         ),
	.WIDTH_B      (WIDTH_B_M3                         ),
	.WIDTH_O      (WIDTH_OPS3_G1                      ),
	.QUANT_W      (QUANT_W                            )
)BatchNormalization_ops_3(
	.i_sclk    	  (i_sclk                             ),
	.i_vsync      (m3_vsync                           ),
	.i_hsync      (m3_hsync                           ),
	.i_reuse      (m3_reuse                           ),
	.i_valid      (m3_valid                           ),
	.i_tdata      (m3_tdata                           ),
	.i_bn_a       (m3_bn_a                            ),
	.i_bn_b       (m3_bn_b                            ),
	.o_vsync      (ops_3_vsync                        ),
	.o_hsync      (ops_3_hsync                        ),
	.o_reuse      (ops_3_reuse                        ),
	.o_valid      (ops_3_valid                        ),
	.o_tdata      (ops_3_tdata                        )
);
//----------------------------------------------//
//					GROUP_114					//
//----------------------------------------------//
always@(posedge i_sclk)
begin
	g4_vsync <= bn_3_vsync;
	g4_hsync <= bn_3_hsync;
	g4_reuse <= bn_3_reuse;
	g4_valid <= bn_3_valid;
	g4_tdata <= bn_3_tdata + g24_tdata + ops_3_tdata;
end

assign o_vsync = i_vsync;
assign o_hsync = g4_hsync;
assign o_reuse = g4_reuse;
assign o_valid = g4_valid;
assign o_tdata = g4_valid ? g4_tdata:'d0;

endmodule
