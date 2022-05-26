`timescale 1ns / 1ps

module Layer_1#(
	parameter						WIDTH_D = 24   ,//8*3
	parameter						WIDTH_P = 60   ,
	parameter						WIDTH_W = 20   ,
	parameter						WIDTH_A = 18   ,
	parameter						WIDTH_B = 35   ,
	parameter						QUANT_D = 5    ,
	parameter						QUANT_W = 16   ,
	parameter						CHANNEL = 64   ,
	parameter						THREAD  = 2    ,
	parameter						SIZE    = 224  ,
	parameter						LEN_W   = 7    ,
	parameter						LEN_M   = 3    ,
	parameter						STEP    = 2    ,
	parameter						PAD     = 3    ,
	parameter						WIDTH_O = 27
)(
	input	wire					i_sclk     ,
	input	wire					i_rstp     ,
	
	input	wire					i_vsync    ,
	input	wire					i_hsync    ,
	input	wire					i_valid    ,
	input	wire[WIDTH_D-1:0]		i_tdata    ,
	input	wire[2:0]				i_param_vld,
	input	wire[WIDTH_P-1:0]		i_param    ,
	
	output	wire					o_vsync    ,
	output	wire					o_hsync    ,
	output	wire					o_reuse    ,
	output	wire					o_valid    ,
	output	wire[WIDTH_O-1:0]		o_tdata    
);

//----------------------------------------------//
//					PARAM						//
//----------------------------------------------//
parameter	WIDTH_CW = WIDTH_W*3*THREAD;
parameter	WIDTH_C  = 27;
//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
wire								cw_vld     ;
wire[WIDTH_CW-1:0]					cw         ;
wire[WIDTH_A-1:0]					bn_a       ;
wire[WIDTH_B-1:0]					bn_b       ;

wire								pc_vsync   ;
wire								pc_hsync   ;
wire								pc_reuse   ;
wire								pc_valid   ;
wire[WIDTH_D*LEN_W*LEN_W-1:0]		pc_tdata   ;

wire								co_vsync   ;
wire								co_hsync   ;
wire								co_reuse   ;
wire								co_valid   ;
wire[WIDTH_C*THREAD-1:0]			co_tdata   ;

wire								mo_vsync   ;
wire								mo_hsync   ;
wire								mo_reuse   ;
wire								mo_valid   ;
wire[WIDTH_C-1:0]					mo_tdata   ;
//----------------------------------------------//
//					LOADING						//
//----------------------------------------------//
Load_param_L1#(
	.WIDTH_P      (WIDTH_P                     ),
	.WIDTH_W      (WIDTH_W                     ),
	.WIDTH_A      (WIDTH_A                     ),
	.WIDTH_B      (WIDTH_B                     ),
	.THREAD       (THREAD                      ),
	.SIZE_W       (LEN_W*LEN_W                 )
)Load_param_L1_inst(
	.i_sclk    	  (i_sclk                      ),
	.i_rstp    	  (i_rstp                      ),
	.i_param_vld  (i_param_vld                 ),
	.i_param      (i_param                     ),
	.i_Conv_req   (pc_reuse                    ),
	.o_cw_vld     (cw_vld                      ),
	.o_cw         (cw                          ),
	.i_Bn_req     (mo_reuse                    ),
	.o_bn_a       (bn_a                        ),
	.o_bn_b       (bn_b                        )
);
//----------------------------------------------//
//					PIPELING PADDING			//
//----------------------------------------------//
Reshape_Conv_L1#(
	.WIDTH        (WIDTH_D                     ),
	.SIZE		  (SIZE                        ),
	.CHANNEL      (1                           ),
	.REUSE        (32                          ),
	.LEN          (LEN_W                       ),
	.PAD          (3                           ),
	.STEP         (STEP                        ),
	.PADWAIT      (1631                        )
)Reshape_Conv_L1_inst(
	.i_sclk    	  (i_sclk                      ),
	.i_vsync   	  (i_vsync                     ),
	.i_hsync   	  (i_hsync                     ),
	.i_valid   	  (i_valid                     ),
	.i_tdata   	  (i_tdata                     ),
	.o_vsync      (pc_vsync                    ),
	.o_hsync      (pc_hsync                    ),
	.o_reuse      (pc_reuse                    ),
	.o_valid      (pc_valid                    ),
	.o_tdata      (pc_tdata                    )
);
//----------------------------------------------//
//						CONV					//
//----------------------------------------------//
Conv_L1#(
	.WIDTH_D      (WIDTH_D                     ),
	.WIDTH_W      (WIDTH_W                     ),
	.WIDTH_C      (WIDTH_C                     ),
	.SIZE		  (SIZE/2                      ),
	.THREAD       (THREAD                      ),
	.REUSE        (32                          ),
	.LEN          (LEN_W                       ),
	.QUANT_D      (QUANT_D                     )
)Conv_L1_inst(
	.i_sclk    	  (i_sclk                      ),
	.i_vsync      (pc_vsync                    ),
	.i_hsync      (pc_hsync                    ),
	.i_reuse      (pc_reuse                    ),
	.i_valid      (pc_valid                    ),
	.i_tdata      (pc_tdata                    ),
	.i_cw_vld     (cw_vld                      ),
	.i_cw         (cw                          ),
	.o_vsync      (co_vsync                    ),
	.o_hsync      (co_hsync                    ),
	.o_reuse      (co_reuse                    ),
	.o_valid      (co_valid                    ),
	.o_tdata      (co_tdata                    )
);
//----------------------------------------------//
//					PIPELING PADDING			//
//----------------------------------------------//
Maxpool_L1#(
	.WIDTH        (WIDTH_C                     ),
	.SIZE		  (SIZE/2                      ),
	.THREAD       (THREAD                      ),
	.CHANNEL      (32                          ),
	.LEN          (LEN_M                       ),
	.PAD          (1                           ),
	.STEP         (STEP                        ),
	.PADWAIT      (35                          )
)Maxpool_L1_inst(
	.i_sclk    	  (i_sclk                      ),
	.i_vsync      (co_vsync                    ),
	.i_hsync      (co_hsync                    ),
	.i_reuse      (co_reuse                    ),
	.i_valid      (co_valid                    ),
	.i_tdata      (co_tdata                    ),
	.o_vsync      (mo_vsync                    ),
	.o_hsync      (mo_hsync                    ),
	.o_reuse      (mo_reuse                    ),
	.o_valid      (mo_valid                    ),
	.o_tdata      (mo_tdata                    )
);
//----------------------------------------------//
//						Bn						//
//----------------------------------------------//
BatchNormalization#(
	.WIDTH_D      (WIDTH_C+1                   ),
	.WIDTH_A      (WIDTH_A                     ),
	.WIDTH_B      (WIDTH_B                     ),
	.WIDTH_O      (WIDTH_O                     ),
	.QUANT_W      (QUANT_W                     )
)BatchNormalization_L1(
	.i_sclk    	  (i_sclk                      ),
	.i_vsync      (mo_vsync                    ),
	.i_hsync      (mo_hsync                    ),
	.i_reuse      (mo_reuse                    ),
	.i_valid      (mo_valid                    ),
	.i_tdata      ({1'd0,mo_tdata}             ),
	.i_bn_a       (bn_a                        ),
	.i_bn_b       (bn_b                        ),
	.o_vsync      (o_vsync                     ),
	.o_hsync      (o_hsync                     ),
	.o_reuse      (o_reuse                     ),
	.o_valid      (o_valid                     ),
	.o_tdata      (o_tdata                     )
);

endmodule
