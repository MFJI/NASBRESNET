`timescale 1ns / 1ps

module Group_0#(
	parameter						WIDTH_D    = 27   ,
	parameter						WIDTH_P    = 60   ,
	parameter						WIDTH_A_M0 = 18   ,
	parameter						WIDTH_B_M0 = 34   ,
	parameter						WIDTH_W_DS = 20   ,
	parameter						WIDTH_A_DS = 16   ,
	parameter						WIDTH_B_DS = 35   ,
	parameter						WIDTH_A_C0 = 12   ,
	parameter						WIDTH_B_C0 = 33   ,
	parameter						WIDTH_A_C1 = 22   ,
	parameter						WIDTH_B_C1 = 33   ,
	parameter						WIDTH_A_C2 = 13   ,
	parameter						WIDTH_B_C2 = 34   ,
	parameter						WIDTH_A_C3 = 15   ,
	parameter						WIDTH_B_C3 = 34   ,
	parameter						WIDTH_O    = 27   ,
	parameter						QUANT_W    = 16   ,
	parameter						CHANNEL    = 64   ,
	parameter						SIZE       = 56   ,
	parameter						LEN        = 3    
)(
	input	wire					i_sclk            ,
	input	wire					i_rstp            ,

	input	wire					i_vsync           ,
	input	wire					i_hsync           ,
	input	wire					i_reuse           ,
	input	wire					i_valid           ,
	input	wire[WIDTH_D-1:0]		i_tdata           ,
	input	wire[17:0]				i_param_vld       ,
	input	wire[WIDTH_P-1:0]		i_param           ,

	output	wire					o_vsync           ,
	output	wire					o_hsync           ,
	output	wire					o_reuse           ,
	output	wire					o_valid           ,
	output	wire[WIDTH_O-1:0]		o_tdata           
);

//----------------------------------------------//
//					PARAM						//
//----------------------------------------------//=
parameter	WIDTH_B       = 2 ;
parameter	WIDTH_C       = 11;
parameter	WIDTH_BC      = 26;
parameter	WIDTH_OPS0_G0 = 27;
parameter	WIDTH_DSW_G0  = 27;
parameter	WIDTH_DSB_G0  = 27;
parameter	WIDTH_BN0_G0  = 27;
parameter	WIDTH_BN1_G0  = 27;
parameter	WIDTH_BN2_G0  = 27;
parameter	WIDTH_BN3_G0  = 27;
parameter	WIDTH_G01     = 27;
parameter	WIDTH_G02     = 27;
parameter	WIDTH_G03     = 27;
parameter	WIDTH_G04     = 27;
parameter	WIDTH_O_G0    = WIDTH_G04;
//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
wire								ds_w_vld          ;
wire[WIDTH_W_DS*2-1:0]				ds_w              ;
wire								c0_w_vld          ;
wire[2*LEN*LEN*2-1:0]				c0_w              ;
wire[QUANT_W-1:0]					c0_we             ;
wire								c1_w_vld          ;
wire[2*LEN*LEN*2-1:0]				c1_w              ;
wire[QUANT_W-1:0]					c1_we             ;
wire								c2_w_vld          ;
wire[2*LEN*LEN*2-1:0]				c2_w              ;
wire[QUANT_W-1:0]					c2_we             ;
wire								c3_w_vld          ;
wire[2*LEN*LEN*2-1:0]				c3_w              ;
wire[QUANT_W-1:0]					c3_we             ;
wire[WIDTH_A_DS-1:0]				ds_bn_a           ;
wire[WIDTH_B_DS-1:0]				ds_bn_b           ;
wire[WIDTH_A_M0-1:0]				m0_bn_a           ;
wire[WIDTH_B_M0-1:0]				m0_bn_b           ;
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
wire[2*LEN-1:0]						b0_tdata          ;

wire								md0_vsync         ;
wire								md0_hsync         ;
wire								md0_reuse         ;
wire								md0_valid         ;
wire[WIDTH_D*LEN-1:0]				md0_tdata         ;
wire signed[WIDTH_D-1:0]			md0_adata[LEN-1:0];

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
wire signed[WIDTH_BN0_G0-1:0]		bn_0_tdata        ;

wire								m0_vsync          ;
wire								m0_hsync          ;
wire								m0_reuse          ;
wire								m0_valid          ;
wire signed[WIDTH_D-1:0]			m0_tdata          ;

wire								ops_0_vsync       ;
wire								ops_0_hsync       ;
wire								ops_0_reuse       ;
wire								ops_0_valid       ;
wire signed[WIDTH_OPS0_G0-1:0]		ops_0_tdata       ;

reg 								g01_vsync         ;
reg 								g01_hsync         ;
reg 								g01_reuse         ;
reg 								g01_valid         ;
reg  signed[WIDTH_G01-1:0]			g01_tdata         ;

wire								b1_vsync          ;
wire								b1_hsync          ;
wire								b1_reuse          ;
wire								b1_valid          ;
wire[2*LEN-1:0]						b1_tdata          ;

wire								g12_vsync         ;
wire								g12_hsync         ;
wire								g12_reuse         ;
wire								g12_valid         ;
wire signed[WIDTH_G01-1:0]			g12_tdata         ;

wire								g13_vsync         ;
wire								g13_hsync         ;
wire								g13_reuse         ;
wire								g13_valid         ;
wire signed[WIDTH_G01-1:0]			g13_tdata         ;

wire								g14_vsync         ;
wire								g14_hsync         ;
wire								g14_reuse         ;
wire								g14_valid         ;
wire signed[WIDTH_G01-1:0]			g14_tdata         ;

wire								c1_vsync          ;
wire								c1_hsync          ;
wire								c1_reuse          ;
wire								c1_valid          ;
wire signed[WIDTH_BC-1:0]			c1_tdata          ;

wire								bn_1_vsync        ;
wire								bn_1_hsync        ;
wire								bn_1_reuse        ;
wire								bn_1_valid        ;
wire signed[WIDTH_BN1_G0-1:0]		bn_1_tdata        ;

wire								ds0_vsync         ;
wire								ds0_hsync         ;
wire								ds0_reuse         ;
wire								ds0_valid         ;
wire signed[WIDTH_DSW_G0-1:0]		ds0_tdata         ;

wire								dso_vsync         ;
wire								dso_hsync         ;
wire								dso_reuse         ;
wire								dso_valid         ;
wire signed[WIDTH_DSB_G0-1:0]		dso_tdata         ;

reg 								g02_vsync         ;
reg 								g02_hsync         ;
reg 								g02_reuse         ;
reg 								g02_valid         ;
reg  signed[WIDTH_G02-1:0]			g02_tdata         ;

wire								b2_vsync          ;
wire								b2_hsync          ;
wire								b2_reuse          ;
wire								b2_valid          ;
wire[2*LEN-1:0]						b2_tdata          ;

wire								g24_vsync         ;
wire								g24_hsync         ;
wire								g24_reuse         ;
wire								g24_valid         ;
wire signed[WIDTH_G02-1:0]			g24_tdata         ;

wire								c2_vsync          ;
wire								c2_hsync          ;
wire								c2_reuse          ;
wire								c2_valid          ;
wire signed[WIDTH_BC-1:0]			c2_tdata          ;

wire								bn_2_vsync        ;
wire								bn_2_hsync        ;
wire								bn_2_reuse        ;
wire								bn_2_valid        ;
wire signed[WIDTH_BN2_G0-1:0]		bn_2_tdata        ;

reg 								g03_vsync         ;
reg 								g03_hsync         ;
reg 								g03_reuse         ;
reg 								g03_valid         ;
reg  signed[WIDTH_G03-1:0]			g03_tdata         ;

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
wire signed[WIDTH_BN3_G0-1:0]		bn_3_tdata        ;

reg 								g04_vsync         ;
reg 								g04_hsync         ;
reg 								g04_reuse         ;
reg 								g04_valid         ;
reg  signed[WIDTH_G04-1:0]			g04_tdata         ;

//----------------------------------------------//
//					LOADING						//
//----------------------------------------------//
Load_param_G0#(
	.WIDTH_P      (WIDTH_P                            ),
	.WIDTH_A_M0   (WIDTH_A_M0                         ),
	.WIDTH_B_M0   (WIDTH_B_M0                         ),
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
	.LEN          (LEN                                ) 
)Load_param_G0_inst(
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
Reshape_Din_G0#(
	.WIDTH        (WIDTH_D                            ),
	.SIZE         (SIZE                               ),
	.CHANNEL      (CHANNEL                            ),
	.LEN          (LEN                                ),
	.PADWAIT      (3653                               )
)Reshape_Din_G0_inst(
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
	.o_vsync_m    (md0_vsync                          ),
	.o_hsync_m    (md0_hsync                          ),
	.o_reuse_m    (md0_reuse                          ),
	.o_valid_m    (md0_valid                          ),
	.o_tdata_m    (md0_tdata                          ),
	.o_vsync_d    (d_vsync                            ),
	.o_hsync_d    (d_hsync                            ),
	.o_reuse_d    (d_reuse                            ),
	.o_valid_d    (d_valid                            ),
	.o_tdata_d    (d_tdata                            )
);
//----------------------------------------------//
//					BCONV_0						//
//----------------------------------------------//
Bconv_G0#(
	.DELAY        (4'd3                               ),
	.WIDTH_D      (WIDTH_B                            ),
	.WIDTH_C      (WIDTH_C                            ),
	.WIDTH_O      (WIDTH_BC                           ),
	.QUANT_W      (QUANT_W                            ),
	.CHANNEL      (CHANNEL                            ),
	.SIZE         (SIZE                               ),
	.LEN          (LEN                                ),
	.PADWAIT      (3653                               )
)Bconv_G00(
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
	.WIDTH_O      (WIDTH_BN0_G0                       ),
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
assign md0_adata[0] = md0_tdata[WIDTH_D*1-1:WIDTH_D*0];
assign md0_adata[1] = md0_tdata[WIDTH_D*2-1:WIDTH_D*1];
assign md0_adata[2] = md0_tdata[WIDTH_D*3-1:WIDTH_D*2];

Maxpool_3x3#(
	.WIDTH        (WIDTH_D                            ),
	.LEN          (LEN                                )
)Maxpool_3x3_t1(
	.i_sclk    	  (i_sclk                             ),
	.i_vsync      (md0_vsync                          ),
	.i_hsync      (md0_hsync                          ),
	.i_reuse      (md0_reuse                          ),
	.i_valid      (md0_valid                          ),
	.i_tdata      (md0_adata                          ),
	.o_vsync      (m0_vsync                           ),
	.o_hsync      (m0_hsync                           ),
	.o_reuse      (m0_reuse                           ),
	.o_valid      (m0_valid                           ),
	.o_tdata      (m0_tdata                           )
);
BatchNormalization#(
	.WIDTH_D      (WIDTH_D                            ),
	.WIDTH_A      (WIDTH_A_M0                         ),
	.WIDTH_B      (WIDTH_B_M0                         ),
	.WIDTH_O      (WIDTH_OPS0_G0                      ),
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
//					GROUP_01					//
//----------------------------------------------//
always@(posedge i_sclk)
begin
	g01_vsync <= ops_0_vsync;
	g01_hsync <= ops_0_hsync;
	g01_reuse <= ops_0_reuse;
	g01_valid <= ops_0_valid;
	g01_tdata <= bn_0_tdata + ops_0_tdata;
end

Group_01#(
	.WIDTH_D      (WIDTH_G01                          ),
	.SIZE         (SIZE                               ),
	.CHANNEL      (CHANNEL                            ),
	.LEN          (LEN                                ),
	.PADWAIT      (3653                               )
)Group_01_inst(
	.i_sclk    	  (i_sclk                             ),
	.i_vsync      (g01_vsync                          ),
	.i_hsync      (g01_hsync                          ),
	.i_reuse      (g01_reuse                          ),
	.i_valid      (g01_valid                          ),
	.i_tdata      (g01_tdata                          ),
	.o_vsync_cm   (b1_vsync                           ),
	.o_hsync_cm   (b1_hsync                           ),
	.o_reuse_cm   (b1_reuse                           ),
	.o_valid_cm   (b1_valid                           ),
	.o_tdata_cm   (b1_tdata                           ),
	.o_vsync_g12  (g12_vsync                          ),
	.o_hsync_g12  (g12_hsync                          ),
	.o_reuse_g12  (g12_reuse                          ),
	.o_valid_g12  (g12_valid                          ),
	.o_tdata_g12  (g12_tdata                          ),
	.o_vsync_g13  (g13_vsync                          ),
	.o_hsync_g13  (g13_hsync                          ),
	.o_reuse_g13  (g13_reuse                          ),
	.o_valid_g13  (g13_valid                          ),
	.o_tdata_g13  (g13_tdata                          ),
	.o_vsync_g14  (g14_vsync                          ),
	.o_hsync_g14  (g14_hsync                          ),
	.o_reuse_g14  (g14_reuse                          ),
	.o_valid_g14  (g14_valid                          ),
	.o_tdata_g14  (g14_tdata                          )
);
//----------------------------------------------//
//					BCONV_1						//
//----------------------------------------------//
Bconv_G0#(
	.DELAY        (4'd0                               ),
	.WIDTH_D      (WIDTH_B                            ),
	.WIDTH_C      (WIDTH_C                            ),
	.WIDTH_O      (WIDTH_BC                           ),
	.QUANT_W      (QUANT_W                            ),
	.CHANNEL      (CHANNEL                            ),
	.SIZE         (SIZE                               ),
	.LEN          (LEN                                ),
	.PADWAIT      (3653                               )
)Bconv_G01(
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
	.WIDTH_O      (WIDTH_BN1_G0                       ),
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
DownSample_G0#(
	.DELAY        (4'd9                               ),
	.WIDTH_D      (WIDTH_D                            ),
	.WIDTH_W      (WIDTH_W_DS                         ),
	.WIDTH_O      (WIDTH_DSW_G0                       ),
	.QUANT_W      (QUANT_W                            ),
	.CHANNEL      (CHANNEL                            ),
	.SIZE         (SIZE                               ),
	.PADWAIT      (3653                               )
)DownSample_G0_inst(
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
	.WIDTH_D      (WIDTH_DSW_G0                       ),
	.WIDTH_A      (WIDTH_A_DS                         ),
	.WIDTH_B      (WIDTH_B_DS                         ),
	.WIDTH_O      (WIDTH_DSB_G0                       ),
	.QUANT_W      (QUANT_W                            )
)BatchNormalization_ds_0(
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
//					GROUP_02					//
//----------------------------------------------//
always@(posedge i_sclk)
begin
	g02_vsync <= dso_vsync;
	g02_hsync <= dso_hsync;
	g02_reuse <= dso_reuse;
	g02_valid <= dso_valid;
	g02_tdata <= dso_tdata + bn_1_tdata + g12_tdata;
end

Group_02#(
	.WIDTH_D      (WIDTH_G02                          ),
	.SIZE         (SIZE                               ),
	.CHANNEL      (CHANNEL                            ),
	.LEN          (LEN                                ),
	.PADWAIT      (3653                               )
)Group_02_inst(
	.i_sclk    	  (i_sclk                             ),
	.i_vsync      (g02_vsync                          ),
	.i_hsync      (g02_hsync                          ),
	.i_reuse      (g02_reuse                          ),
	.i_valid      (g02_valid                          ),
	.i_tdata      (g02_tdata                          ),
	.o_vsync_c    (b2_vsync                           ),
	.o_hsync_c    (b2_hsync                           ),
	.o_reuse_c    (b2_reuse                           ),
	.o_valid_c    (b2_valid                           ),
	.o_tdata_c    (b2_tdata                           ),
	.o_vsync_g24  (g24_vsync                          ),
	.o_hsync_g24  (g24_hsync                          ),
	.o_reuse_g24  (g24_reuse                          ),
	.o_valid_g24  (g24_valid                          ),
	.o_tdata_g24  (g24_tdata                          )
);
//----------------------------------------------//
//					BCONV_2						//
//----------------------------------------------//
Bconv_G0#(
	.DELAY        (4'd0                               ),
	.WIDTH_D      (WIDTH_B                            ),
	.WIDTH_C      (WIDTH_C                            ),
	.WIDTH_O      (WIDTH_BC                           ),
	.QUANT_W      (QUANT_W                            ),
	.CHANNEL      (CHANNEL                            ),
	.SIZE         (SIZE                               ),
	.LEN          (LEN                                ),
	.PADWAIT      (3653                               )
)Bconv_G02(
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
	.WIDTH_O      (WIDTH_BN2_G0                       ),
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
//					GROUP_03					//
//----------------------------------------------//
always@(posedge i_sclk)
begin
	g03_vsync <= bn_2_vsync;
	g03_hsync <= bn_2_hsync;
	g03_reuse <= bn_2_reuse;
	g03_valid <= bn_2_valid;
	g03_tdata <= bn_2_tdata + g13_tdata;
end

Group_03#(
	.WIDTH_D      (WIDTH_G03                          ),
	.SIZE         (SIZE                               ),
	.CHANNEL      (CHANNEL                            ),
	.LEN          (LEN                                ),
	.PADWAIT      (3653                               )
)Group_03_inst(
	.i_sclk    	  (i_sclk                             ),
	.i_vsync      (g03_vsync                          ),
	.i_hsync      (g03_hsync                          ),
	.i_reuse      (g03_reuse                          ),
	.i_valid      (g03_valid                          ),
	.i_tdata      (g03_tdata                          ),
	.o_vsync_c    (b3_vsync                           ),
	.o_hsync_c    (b3_hsync                           ),
	.o_reuse_c    (b3_reuse                           ),
	.o_valid_c    (b3_valid                           ),
	.o_tdata_c    (b3_tdata                           )
);
//----------------------------------------------//
//					BCONV_3						//
//----------------------------------------------//
Bconv_G0#(
	.DELAY        (4'd0                               ),
	.WIDTH_D      (WIDTH_B                            ),
	.WIDTH_C      (WIDTH_C                            ),
	.WIDTH_O      (WIDTH_BC                           ),
	.QUANT_W      (QUANT_W                            ),
	.CHANNEL      (CHANNEL                            ),
	.SIZE         (SIZE                               ),
	.LEN          (LEN                                ),
	.PADWAIT      (3653                               )
)Bconv_G03(
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
	.WIDTH_O      (WIDTH_BN3_G0                       ),
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
//					GROUP_04					//
//----------------------------------------------//
always@(posedge i_sclk)
begin
	g04_vsync <= bn_3_vsync;
	g04_hsync <= bn_3_hsync;
	g04_reuse <= bn_3_reuse;
	g04_valid <= bn_3_valid;
	g04_tdata <= bn_3_tdata + g14_tdata + g24_tdata;
end

assign o_vsync = i_vsync;
assign o_hsync = g04_hsync;
assign o_reuse = g04_reuse;
assign o_valid = g04_valid;
assign o_tdata = g04_valid ? g04_tdata:'d0;

endmodule
