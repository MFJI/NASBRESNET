`timescale 1ns / 1ps

module ResNet18(
	input	wire		i_sclk        ,
	input	wire		i_rstp        ,
	
	input	wire[84:0]	i_param_vld   ,
	input	wire[59:0]	i_param       ,
	
	output	wire		o_predict_vld ,
	output	wire[9:0]	o_predict      
);

//----------------------------------------------//
//					PARAMETER					//
//----------------------------------------------//
parameter	QUANT_W       = 16 ;
parameter	QUANT_D       = 5  ;
parameter	WIDTH_D       = 24 ;
parameter	WIDTH_P       = 60 ;

parameter	CHANNEL_L1    = 64;
parameter	SIZE_L1       = 224;
parameter	WIDTH_W_L1    = 20 ;
parameter	WIDTH_A_L1    = 18 ;
parameter	WIDTH_B_L1    = 35 ;
parameter	LEN_W_L1      = 7  ;
parameter	LEN_M_L1      = 3  ;
parameter	STEP_L1       = 2  ;
parameter	PAD_L1        = 3  ;
parameter	WIDTH_O_L1    = 27 ;

parameter	WIDTH_WE      = QUANT_W;
parameter	WIDTH_BC      = 21;

parameter	CHANNEL_G0    = 64;
parameter	SIZE_G0       = 56;
parameter	WIDTH_A_M0_G0 = 18;
parameter	WIDTH_B_M0_G0 = 34;
parameter	WIDTH_W_DS_G0 = 20;
parameter	WIDTH_A_DS_G0 = 16;
parameter	WIDTH_B_DS_G0 = 35;
parameter	WIDTH_A_C0_G0 = 12;
parameter	WIDTH_B_C0_G0 = 33;
parameter	WIDTH_A_C1_G0 = 22;
parameter	WIDTH_B_C1_G0 = 33;
parameter	WIDTH_A_C2_G0 = 13;
parameter	WIDTH_B_C2_G0 = 34;
parameter	WIDTH_A_C3_G0 = 15;
parameter	WIDTH_B_C3_G0 = 34;
parameter	WIDTH_O_G0    = 27;

parameter	CHANNEL_G1    = 128;
parameter	SIZE_G1       = 28;
parameter	WIDTH_A_M0_G1 = 17;
parameter	WIDTH_B_M0_G1 = 34;
parameter	WIDTH_A_M3_G1 = 20;
parameter	WIDTH_B_M3_G1 = 35;
parameter	WIDTH_W_DS_G1 = 19;
parameter	WIDTH_A_DS_G1 = 15;
parameter	WIDTH_B_DS_G1 = 33;
parameter	WIDTH_A_C0_G1 = 13;
parameter	WIDTH_B_C0_G1 = 33;
parameter	WIDTH_A_C1_G1 = 16;
parameter	WIDTH_B_C1_G1 = 33;
parameter	WIDTH_A_C2_G1 = 15;
parameter	WIDTH_B_C2_G1 = 34;
parameter	WIDTH_A_C3_G1 = 16;
parameter	WIDTH_B_C3_G1 = 34;
parameter	WIDTH_O_G1    = 27;

parameter	CHANNEL_G2    = 256;
parameter	SIZE_G2       = 14;
parameter	WIDTH_A_M0_G2 = 18;
parameter	WIDTH_B_M0_G2 = 34;
parameter	WIDTH_A_M1_G2 = 22;
parameter	WIDTH_B_M1_G2 = 33;
parameter	WIDTH_A_M3_G2 = 21;
parameter	WIDTH_B_M3_G2 = 34;
parameter	WIDTH_W_DS_G2 = 20;
parameter	WIDTH_A_DS_G2 = 14;
parameter	WIDTH_B_DS_G2 = 33;
parameter	WIDTH_A_C0_G2 = 19;
parameter	WIDTH_B_C0_G2 = 34;
parameter	WIDTH_A_C1_G2 = 24;
parameter	WIDTH_B_C1_G2 = 33;
parameter	WIDTH_A_C2_G2 = 24;
parameter	WIDTH_B_C2_G2 = 34;
parameter	WIDTH_A_C3_G2 = 17;
parameter	WIDTH_B_C3_G2 = 34;
parameter	WIDTH_O_G2    = 27;

parameter	CHANNEL_G3    = 512;
parameter	SIZE_G3       = 7 ;
parameter	WIDTH_A_M0_G3 = 18;
parameter	WIDTH_B_M0_G3 = 34;
parameter	WIDTH_A_M1_G3 = 16;
parameter	WIDTH_B_M1_G3 = 32;
parameter	WIDTH_A_M2_G3 = 21;
parameter	WIDTH_B_M2_G3 = 34;
parameter	WIDTH_W_DS_G3 = 19;
parameter	WIDTH_A_DS_G3 = 13;
parameter	WIDTH_B_DS_G3 = 31;
parameter	WIDTH_A_C0_G3 = 14;
parameter	WIDTH_B_C0_G3 = 34;
parameter	WIDTH_A_C1_G3 = 25;
parameter	WIDTH_B_C1_G3 = 32;
parameter	WIDTH_A_C2_G3 = 16;
parameter	WIDTH_B_C2_G3 = 34;
parameter	WIDTH_A_C3_G3 = 15;
parameter	WIDTH_B_C3_G3 = 33;
parameter	WIDTH_O_G3    = 27;

parameter	CHANNEL_FC    = 1000;
parameter	WIDTH_W_FC    = 20;
parameter	WIDTH_B_FC    = 20;
//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
wire					Img_vsync  ;
wire					Img_hsync  ;
wire					Img_valid  ;
wire[WIDTH_D-1:0]		Img_tdata  ;

wire					L1_vsync   ;
wire					L1_hsync   ;
wire					L1_reuse   ;
wire					L1_valid   ;
wire[WIDTH_O_L1-1:0]	L1_tdata   ;

wire					G0_vsync   ;
wire					G0_hsync   ;
wire					G0_reuse   ;
wire					G0_valid   ;
wire[WIDTH_O_G0-1:0]	G0_tdata   ;

wire					G1_vsync   ;
wire					G1_hsync   ;
wire					G1_reuse   ;
wire					G1_valid   ;
wire[WIDTH_O_G1-1:0]	G1_tdata   ;

wire					G2_vsync   ;
wire					G2_hsync   ;
wire					G2_reuse   ;
wire					G2_valid   ;
wire[WIDTH_O_G2-1:0]	G2_tdata   ;

wire					G3_vsync   ;
wire					G3_hsync   ;
wire					G3_reuse   ;
wire					G3_valid   ;
wire[WIDTH_O_G3-1:0]	G3_tdata   ;

wire					Avg_vsync  ;
wire					Avg_valid  ;
wire[WIDTH_O_G3-1:0]	Avg_tdata  ;

//----------------------------------------------//
//					CODING						//
//----------------------------------------------//
Load_image#(
	.WIDTH_D      (WIDTH_D                             ),
	.SIZE         (SIZE_L1                             )
)Load_image_inst(
	.i_sclk       (i_sclk                              ),
	.i_rstp       (i_rstp                              ),
	.i_image_vld  (i_param_vld[84]                     ),
	.i_image      (i_param[WIDTH_D-1:0]                ),
	.o_vsync      (Img_vsync                           ),
	.o_hsync      (Img_hsync                           ),
	.o_valid      (Img_valid                           ),
	.o_tdata      (Img_tdata                           )
);
Layer_1#(
	.WIDTH_D      (WIDTH_D                             ),
	.WIDTH_P      (WIDTH_P                             ),
	.WIDTH_W      (WIDTH_W_L1                          ),
	.WIDTH_A      (WIDTH_A_L1                          ),
	.WIDTH_B      (WIDTH_B_L1                          ),
	.QUANT_D      (QUANT_D                             ),
	.QUANT_W      (QUANT_W                             ),
	.CHANNEL      (CHANNEL_L1                          ),
	.SIZE         (SIZE_L1                             ),
	.LEN_W        (LEN_W_L1                            ),
	.LEN_M        (LEN_M_L1                            ),
	.STEP         (STEP_L1                             ),
	.PAD          (PAD_L1                              ),
	.WIDTH_O      (WIDTH_O_L1                          )
)Layer_1_inst(
	.i_sclk    	  (i_sclk                              ),
	.i_rstp    	  (i_rstp                              ),
	.i_vsync   	  (Img_vsync                           ),
	.i_hsync   	  (Img_hsync                           ),
	.i_valid   	  (Img_valid                           ),
	.i_tdata   	  (Img_tdata                           ),
	.i_param_vld  (i_param_vld[2:0]                    ),
	.i_param      (i_param                             ),
	.o_vsync      (L1_vsync                            ),
	.o_hsync      (L1_hsync                            ),
	.o_reuse      (L1_reuse                            ),
	.o_valid      (L1_valid                            ),
	.o_tdata      (L1_tdata                            )
);
Group_0#(
	.WIDTH_D      (WIDTH_O_L1                          ),
	.WIDTH_P      (WIDTH_P                             ),
	.WIDTH_A_M0   (WIDTH_A_M0_G0                       ),
	.WIDTH_B_M0   (WIDTH_B_M0_G0                       ),
	.WIDTH_W_DS   (WIDTH_W_DS_G0                       ),
	.WIDTH_A_DS   (WIDTH_A_DS_G0                       ),
	.WIDTH_B_DS   (WIDTH_B_DS_G0                       ),
	.WIDTH_A_C0   (WIDTH_A_C0_G0                       ),
	.WIDTH_B_C0   (WIDTH_B_C0_G0                       ),
	.WIDTH_A_C1   (WIDTH_A_C1_G0                       ),
	.WIDTH_B_C1   (WIDTH_B_C1_G0                       ),
	.WIDTH_A_C2   (WIDTH_A_C2_G0                       ),
	.WIDTH_B_C2   (WIDTH_B_C2_G0                       ),
	.WIDTH_A_C3   (WIDTH_A_C3_G0                       ),
	.WIDTH_B_C3   (WIDTH_B_C3_G0                       ),
	.QUANT_W      (QUANT_W                             ),
	.CHANNEL      (CHANNEL_G0                          ),
	.SIZE         (SIZE_G0                             ),
	.LEN          (LEN_M_L1                            ),
	.WIDTH_O      (WIDTH_O_G0                          )
)Group_0_inst(
	.i_sclk       (i_sclk                              ),
	.i_rstp       (i_rstp                              ),
	.i_vsync      (L1_vsync                            ),
	.i_hsync      (L1_hsync                            ),
	.i_reuse      (L1_reuse                            ),
	.i_valid      (L1_valid                            ),
	.i_tdata      (L1_tdata                            ),
	.i_param_vld  ({i_param_vld[83],i_param_vld[19:3]} ),
	.i_param      (i_param                             ),
	.o_vsync      (G0_vsync                            ),
	.o_hsync      (G0_hsync                            ),
	.o_reuse      (G0_reuse                            ),
	.o_valid      (G0_valid                            ),
	.o_tdata      (G0_tdata                            )
);
Group_1#(
	.WIDTH_D      (WIDTH_O_G0                          ),
	.WIDTH_P      (WIDTH_P                             ),
	.WIDTH_A_M0   (WIDTH_A_M0_G1                       ),
	.WIDTH_B_M0   (WIDTH_B_M0_G1                       ),
	.WIDTH_A_M3   (WIDTH_A_M3_G1                       ),
	.WIDTH_B_M3   (WIDTH_B_M3_G1                       ),
	.WIDTH_W_DS   (WIDTH_W_DS_G1                       ),
	.WIDTH_A_DS   (WIDTH_A_DS_G1                       ),
	.WIDTH_B_DS   (WIDTH_B_DS_G1                       ),
	.WIDTH_A_C0   (WIDTH_A_C0_G1                       ),
	.WIDTH_B_C0   (WIDTH_B_C0_G1                       ),
	.WIDTH_A_C1   (WIDTH_A_C1_G1                       ),
	.WIDTH_B_C1   (WIDTH_B_C1_G1                       ),
	.WIDTH_A_C2   (WIDTH_A_C2_G1                       ),
	.WIDTH_B_C2   (WIDTH_B_C2_G1                       ),
	.WIDTH_A_C3   (WIDTH_A_C3_G1                       ),
	.WIDTH_B_C3   (WIDTH_B_C3_G1                       ),
	.QUANT_W      (QUANT_W                             ),
	.CHANNEL      (CHANNEL_G1                          ),
	.SIZE         (SIZE_G1                             ),
	.LEN          (LEN_M_L1                            ),
	.WIDTH_O      (WIDTH_O_G1                          )
)Group_1_inst(
	.i_sclk       (i_sclk                              ),
	.i_rstp       (i_rstp                              ),
	.i_vsync      (G0_vsync                            ),
	.i_hsync      (G0_hsync                            ),
	.i_reuse      (G0_reuse                            ),
	.i_valid      (G0_valid                            ),
	.i_tdata      (G0_tdata                            ),
	.i_param_vld  ({i_param_vld[83],i_param_vld[38:20]}),
	.i_param      (i_param                             ),
	.o_vsync      (G1_vsync                            ),
	.o_hsync      (G1_hsync                            ),
	.o_reuse      (G1_reuse                            ),
	.o_valid      (G1_valid                            ),
	.o_tdata      (G1_tdata                            )
);
Group_2#(
	.WIDTH_D      (WIDTH_O_G1                          ),
	.WIDTH_P      (WIDTH_P                             ),
	.WIDTH_A_M0   (WIDTH_A_M0_G2                       ),
	.WIDTH_B_M0   (WIDTH_B_M0_G2                       ),
	.WIDTH_A_M1   (WIDTH_A_M1_G2                       ),
	.WIDTH_B_M1   (WIDTH_B_M1_G2                       ),
	.WIDTH_A_M3   (WIDTH_A_M3_G2                       ),
	.WIDTH_B_M3   (WIDTH_B_M3_G2                       ),
	.WIDTH_W_DS   (WIDTH_W_DS_G2                       ),
	.WIDTH_A_DS   (WIDTH_A_DS_G2                       ),
	.WIDTH_B_DS   (WIDTH_B_DS_G2                       ),
	.WIDTH_A_C0   (WIDTH_A_C0_G2                       ),
	.WIDTH_B_C0   (WIDTH_B_C0_G2                       ),
	.WIDTH_A_C1   (WIDTH_A_C1_G2                       ),
	.WIDTH_B_C1   (WIDTH_B_C1_G2                       ),
	.WIDTH_A_C2   (WIDTH_A_C2_G2                       ),
	.WIDTH_B_C2   (WIDTH_B_C2_G2                       ),
	.WIDTH_A_C3   (WIDTH_A_C3_G2                       ),
	.WIDTH_B_C3   (WIDTH_B_C3_G2                       ),
	.QUANT_W      (QUANT_W                             ),
	.CHANNEL      (CHANNEL_G2                          ),
	.SIZE         (SIZE_G2                             ),
	.LEN          (LEN_M_L1                            ),
	.WIDTH_O      (WIDTH_O_G2                          )
)Group_2_inst(
	.i_sclk       (i_sclk                              ),
	.i_rstp       (i_rstp                              ),
	.i_vsync      (G1_vsync                            ),
	.i_hsync      (G1_hsync                            ),
	.i_reuse      (G1_reuse                            ),
	.i_valid      (G1_valid                            ),
	.i_tdata      (G1_tdata                            ),
	.i_param_vld  ({i_param_vld[83],i_param_vld[59:39]}),
	.i_param      (i_param                             ),
	.o_vsync      (G2_vsync                            ),
	.o_hsync      (G2_hsync                            ),
	.o_reuse      (G2_reuse                            ),
	.o_valid      (G2_valid                            ),
	.o_tdata      (G2_tdata                            )
);
Group_3#(
	.WIDTH_D      (WIDTH_O_G2                          ),
	.WIDTH_P      (WIDTH_P                             ),
	.WIDTH_A_M0   (WIDTH_A_M0_G3                       ),
	.WIDTH_B_M0   (WIDTH_B_M0_G3                       ),
	.WIDTH_A_M1   (WIDTH_A_M1_G3                       ),
	.WIDTH_B_M1   (WIDTH_B_M1_G3                       ),
	.WIDTH_A_M2   (WIDTH_A_M2_G3                       ),
	.WIDTH_B_M2   (WIDTH_B_M2_G3                       ),
	.WIDTH_W_DS   (WIDTH_W_DS_G3                       ),
	.WIDTH_A_DS   (WIDTH_A_DS_G3                       ),
	.WIDTH_B_DS   (WIDTH_B_DS_G3                       ),
	.WIDTH_A_C0   (WIDTH_A_C0_G3                       ),
	.WIDTH_B_C0   (WIDTH_B_C0_G3                       ),
	.WIDTH_A_C1   (WIDTH_A_C1_G3                       ),
	.WIDTH_B_C1   (WIDTH_B_C1_G3                       ),
	.WIDTH_A_C2   (WIDTH_A_C2_G3                       ),
	.WIDTH_B_C2   (WIDTH_B_C2_G3                       ),
	.WIDTH_A_C3   (WIDTH_A_C3_G3                       ),
	.WIDTH_B_C3   (WIDTH_B_C3_G3                       ),
	.QUANT_W      (QUANT_W                             ),
	.CHANNEL      (CHANNEL_G3                          ),
	.SIZE         (SIZE_G3                             ),
	.LEN          (LEN_M_L1                            ),
	.WIDTH_O      (WIDTH_O_G3                          )
)Group_3_inst(
	.i_sclk       (i_sclk                              ),
	.i_rstp       (i_rstp                              ),
	.i_vsync      (G2_vsync                            ),
	.i_hsync      (G2_hsync                            ),
	.i_reuse      (G2_reuse                            ),
	.i_valid      (G2_valid                            ),
	.i_tdata      (G2_tdata                            ),
	.i_param_vld  ({i_param_vld[83],i_param_vld[80:60]}),
	.i_param      (i_param                             ),
	.o_vsync      (G3_vsync                            ),
	.o_hsync      (G3_hsync                            ),
	.o_reuse      (G3_reuse                            ),
	.o_valid      (G3_valid                            ),
	.o_tdata      (G3_tdata                            )
);
AvgPool#(
	.WIDTH_D      (WIDTH_O_G3                          ),
	.QUANT_W      (QUANT_W                             ),
	.SIZE_I       (CHANNEL_G3                          ),
	.SIZE_O       (CHANNEL_FC                          )
)AvgPool_inst(
	.i_sclk       (i_sclk                              ),
	.i_vsync      (G3_vsync                            ),
	.i_hsync      (G3_hsync                            ),
	.i_reuse      (G3_reuse                            ),
	.i_valid      (G3_valid                            ),
	.i_tdata      (G3_tdata                            ),
	.o_vsync      (Avg_vsync                           ),
	.o_valid      (Avg_valid                           ),
	.o_tdata      (Avg_tdata                           )
);
Fullconnect#(
	.WIDTH_D      (WIDTH_O_G3                          ),
	.WIDTH_P      (WIDTH_P                             ),
	.WIDTH_W      (WIDTH_W_FC                          ),
	.WIDTH_B      (WIDTH_B_FC                          ),
	.QUANT_W      (QUANT_W                             ),
	.SIZE_I       (CHANNEL_G3                          ),
	.SIZE_O       (CHANNEL_FC                          )
)Fullconnect_inst(
	.i_sclk       (i_sclk                              ),
	.i_rstp       (i_rstp                              ),
	.i_vsync      (Avg_vsync                           ),
	.i_valid      (Avg_valid                           ),
	.i_tdata      (Avg_tdata                           ),
	.i_param_vld  (i_param_vld[82:81]                  ),
	.i_param      (i_param                             ),
	.o_predict_vld(o_predict_vld                       ),
	.o_predict    (o_predict                           )
);

endmodule
