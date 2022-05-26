`timescale 1ns / 1ps

module Reshape_Conv_L1#(
	parameter							WIDTH   = 24 ,
	parameter							SIZE    = 224,
	parameter							CHANNEL = 1  ,
	parameter							REUSE   = 32 ,
	parameter							LEN     = 7  ,
	parameter							PAD     = 3  ,
	parameter							STEP    = 2  ,
	parameter							PADWAIT = 234*3
)(
	input	wire						i_sclk ,
	input	wire						i_vsync,
	input	wire						i_hsync,
	input	wire						i_valid,
	input	wire[WIDTH-1:0]				i_tdata,
	
	output	reg 						o_vsync,
	output	reg 						o_hsync,
	output	reg 						o_reuse,
	output	reg 						o_valid,
	output	reg [WIDTH*LEN*LEN-1:0]		o_tdata
);

//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
wire[WIDTH-1:0]						p7_tdata_r ;

wire								p6_rdreq   ;
wire								p6_vsync   ;
wire								p6_hsync   ;
wire								p6_valid   ;
wire[WIDTH-1:0]						p6_rddat   ;
wire[WIDTH-1:0]						p6_rddat_r ;
wire								p6_full    ;
wire								p6_empty   ;

wire								p5_rdreq   ;
wire								p5_vsync   ;
wire								p5_hsync   ;
wire								p5_valid   ;
wire[WIDTH-1:0]						p5_rddat   ;
wire[WIDTH-1:0]						p5_rddat_r ;
wire								p5_full    ;
wire								p5_empty   ;

wire								p4_rdreq   ;
wire								p4_vsync   ;
wire								p4_hsync   ;
wire								p4_valid   ;
wire[WIDTH-1:0]						p4_rddat   ;
wire[WIDTH-1:0]						p4_rddat_r ;
wire								p4_full    ;
wire								p4_empty   ;

wire								p3_rdreq   ;
wire								p3_vsync   ;
wire								p3_hsync   ;
wire								p3_valid   ;
wire[WIDTH-1:0]						p3_rddat   ;
wire[WIDTH-1:0]						p3_rddat_r ;
wire								p3_full    ;
wire								p3_empty   ;

wire								p2_rdreq   ;
wire								p2_vsync   ;
wire								p2_hsync   ;
wire								p2_valid   ;
wire[WIDTH-1:0]						p2_rddat   ;
wire[WIDTH-1:0]						p2_rddat_r ;
wire								p2_full    ;
wire								p2_empty   ;

wire								p1_rdreq   ;
wire								p1_vsync   ;
wire								p1_hsync   ;
wire								p1_valid   ;
wire[WIDTH-1:0]						p1_rddat   ;
wire[WIDTH-1:0]						p1_rddat_r ;
wire								p1_full    ;
wire								p1_empty   ;

reg 								p7_vsync   ;
reg 								p7_hsync   ;
reg 								p7_valid   ;
reg [WIDTH/3*LEN-1:0]				p7_rddat_r ;
reg [WIDTH/3*LEN-1:0]				p7_rddat_g ;
reg [WIDTH/3*LEN-1:0]				p7_rddat_b ;

wire								Rr_wrvld   ;
wire[WIDTH/3*LEN*LEN-1:0]			Rr_wrdat   ;
wire[6:0]							Rr_wrcnt   ;
wire								Rr_rdreq   ;
wire[6:0]							Rr_rdcnt   ;
wire								Rr_vsync   ;
wire								Rr_hsync   ;
wire								Rr_reuse   ;
wire								Rr_valid   ;
wire[WIDTH/3*LEN*LEN-1:0]			Rr_rddat   ;

wire								Rg_wrvld   ;
wire[WIDTH/3*LEN*LEN-1:0]			Rg_wrdat   ;
wire[6:0]							Rg_wrcnt   ;
wire								Rg_rdreq   ;
wire[6:0]							Rg_rdcnt   ;
wire								Rg_vsync   ;
wire								Rg_hsync   ;
wire								Rg_reuse   ;
wire								Rg_valid   ;
wire[WIDTH/3*LEN*LEN-1:0]			Rg_rddat   ;

wire								Rb_wrvld   ;
wire[WIDTH/3*LEN*LEN-1:0]			Rb_wrdat   ;
wire[6:0]							Rb_wrcnt   ;
wire								Rb_rdreq   ;
wire[6:0]							Rb_rdcnt   ;
wire								Rb_vsync   ;
wire								Rb_hsync   ;
wire								Rb_reuse   ;
wire								Rb_valid   ;
wire[WIDTH/3*LEN*LEN-1:0]			Rb_rddat   ;

//----------------------------------------------//
//					CODING						//
//----------------------------------------------//
assign p7_tdata_r = i_valid  ? i_tdata :'d0;
assign p6_rddat_r = p6_valid ? p6_rddat:'d0;
assign p5_rddat_r = p5_valid ? p5_rddat:'d0;
assign p4_rddat_r = p4_valid ? p4_rddat:'d0;
assign p3_rddat_r = p3_valid ? p3_rddat:'d0;
assign p2_rddat_r = p2_valid ? p2_rddat:'d0;
assign p1_rddat_r = p1_valid ? p1_rddat:'d0;

always@(posedge i_sclk)
begin
	p7_vsync   <= i_vsync;
	p7_hsync   <= i_hsync|p1_hsync;
	p7_valid   <= i_valid|p1_valid;
	p7_rddat_r <= {p7_tdata_r[WIDTH-1:WIDTH/3*2],
				   p6_rddat_r[WIDTH-1:WIDTH/3*2],
				   p5_rddat_r[WIDTH-1:WIDTH/3*2],
				   p4_rddat_r[WIDTH-1:WIDTH/3*2],
				   p3_rddat_r[WIDTH-1:WIDTH/3*2],
				   p2_rddat_r[WIDTH-1:WIDTH/3*2],
				   p1_rddat_r[WIDTH-1:WIDTH/3*2]};
	p7_rddat_g <= {p7_tdata_r[WIDTH/3*2-1:WIDTH/3],
				   p6_rddat_r[WIDTH/3*2-1:WIDTH/3],
				   p5_rddat_r[WIDTH/3*2-1:WIDTH/3],
				   p4_rddat_r[WIDTH/3*2-1:WIDTH/3],
				   p3_rddat_r[WIDTH/3*2-1:WIDTH/3],
				   p2_rddat_r[WIDTH/3*2-1:WIDTH/3],
				   p1_rddat_r[WIDTH/3*2-1:WIDTH/3]};
	p7_rddat_b <= {p7_tdata_r[WIDTH/3-1:0],
				   p6_rddat_r[WIDTH/3-1:0],
				   p5_rddat_r[WIDTH/3-1:0],
				   p4_rddat_r[WIDTH/3-1:0],
				   p3_rddat_r[WIDTH/3-1:0],
				   p2_rddat_r[WIDTH/3-1:0],
				   p1_rddat_r[WIDTH/3-1:0]};
end

always@(posedge i_sclk)
begin
	o_vsync <= Rr_vsync;
	o_hsync <= Rr_hsync;
	o_reuse <= Rr_reuse;
	o_valid <= Rr_valid;
	o_tdata <= {Rr_rddat,Rg_rddat,Rb_rddat};
end

Pipeline#(
	.DELAY		  (2              ),
	.SIZE		  (SIZE           ),
	.CHANNEL      (CHANNEL        ),
	.PADWAIT      (PADWAIT        )
)Pipeline_R6(
	.i_sclk    	  (i_sclk         ),
	.i_vsync   	  (i_vsync        ),
	.i_hsync   	  (i_hsync        ),
	.o_rdreq      (p6_rdreq       ),
	.o_vsync      (p6_vsync       ),
	.o_hsync      (p6_hsync       ),
	.o_reuse      (               ),
	.o_valid      (p6_valid       )
);
Pipeline#(
	.DELAY		  (2              ),
	.SIZE		  (SIZE           ),
	.CHANNEL      (CHANNEL        ),
	.PADWAIT      (PADWAIT        )
)Pipeline_R5(
	.i_sclk    	  (i_sclk         ),
	.i_vsync   	  (i_vsync        ),
	.i_hsync   	  (p6_hsync       ),
	.o_rdreq      (p5_rdreq       ),
	.o_vsync      (p5_vsync       ),
	.o_hsync      (p5_hsync       ),
	.o_reuse      (               ),
	.o_valid      (p5_valid       )
);
Pipeline#(
	.DELAY		  (2              ),
	.SIZE		  (SIZE           ),
	.CHANNEL      (CHANNEL        ),
	.PADWAIT      (PADWAIT        )
)Pipeline_R4(
	.i_sclk    	  (i_sclk         ),
	.i_vsync   	  (i_vsync        ),
	.i_hsync   	  (p5_hsync       ),
	.o_rdreq      (p4_rdreq       ),
	.o_vsync      (p4_vsync       ),
	.o_hsync      (p4_hsync       ),
	.o_reuse      (               ),
	.o_valid      (p4_valid       )
);
Pipeline#(
	.DELAY		  (2              ),
	.SIZE		  (SIZE           ),
	.CHANNEL      (CHANNEL        ),
	.PADWAIT      (PADWAIT        )
)Pipeline_R3(
	.i_sclk    	  (i_sclk         ),
	.i_vsync   	  (i_vsync        ),
	.i_hsync   	  (p4_hsync       ),
	.o_rdreq      (p3_rdreq       ),
	.o_vsync      (p3_vsync       ),
	.o_hsync      (p3_hsync       ),
	.o_reuse      (               ),
	.o_valid      (p3_valid       )
);
Pipeline#(
	.DELAY		  (2              ),
	.SIZE		  (SIZE           ),
	.CHANNEL      (CHANNEL        ),
	.PADWAIT      (PADWAIT        )
)Pipeline_R2(
	.i_sclk    	  (i_sclk         ),
	.i_vsync   	  (i_vsync        ),
	.i_hsync   	  (p3_hsync       ),
	.o_rdreq      (p2_rdreq       ),
	.o_vsync      (p2_vsync       ),
	.o_hsync      (p2_hsync       ),
	.o_reuse      (               ),
	.o_valid      (p2_valid       )
);
Pipeline#(
	.DELAY		  (2              ),
	.SIZE		  (SIZE           ),
	.CHANNEL      (CHANNEL        ),
	.PADWAIT      (PADWAIT        )
)Pipeline_R1(
	.i_sclk    	  (i_sclk         ),
	.i_vsync   	  (i_vsync        ),
	.i_hsync   	  (p2_hsync       ),
	.o_rdreq      (p1_rdreq       ),
	.o_vsync      (p1_vsync       ),
	.o_hsync      (p1_hsync       ),
	.o_reuse      (               ),
	.o_valid      (p1_valid       )
);


fifo_image_i fifo_image_i_R6(
	.clk	      (i_sclk         ),  // input wire clk
	.rst	      (i_vsync        ),  // input wire rst
	.din	      (i_tdata        ),  // input wire [23 : 0] din
	.wr_en	      (i_valid        ),  // input wire wr_en
	.rd_en	      (p6_rdreq       ),  // input wire rd_en
	.dout	      (p6_rddat       ),  // output wire [23 : 0] dout
	.full	      (p6_full        ),  // output wire full
	.empty	      (p6_empty       )   // output wire empty
);
fifo_image_i fifo_image_i_R5(
	.clk	      (i_sclk         ),  // input wire clk
	.rst	      (i_vsync        ),  // input wire rst
	.din	      (p6_rddat       ),  // input wire [23 : 0] din
	.wr_en	      (p6_valid       ),  // input wire wr_en
	.rd_en	      (p5_rdreq       ),  // input wire rd_en
	.dout	      (p5_rddat       ),  // output wire [23 : 0] dout
	.full	      (p5_full        ),  // output wire full
	.empty	      (p5_empty       )   // output wire empty
);
fifo_image_i fifo_image_i_R4(
	.clk	      (i_sclk         ),  // input wire clk
	.rst	      (i_vsync        ),  // input wire rst
	.din	      (p5_rddat       ),  // input wire [23 : 0] din
	.wr_en	      (p5_valid       ),  // input wire wr_en
	.rd_en	      (p4_rdreq       ),  // input wire rd_en
	.dout	      (p4_rddat       ),  // output wire [23 : 0] dout
	.full	      (p4_full        ),  // output wire full
	.empty	      (p4_empty       )   // output wire empty
);
fifo_image_i fifo_image_i_R3(
	.clk	      (i_sclk         ),  // input wire clk
	.rst	      (i_vsync        ),  // input wire rst
	.din	      (p4_rddat       ),  // input wire [23 : 0] din
	.wr_en	      (p4_valid       ),  // input wire wr_en
	.rd_en	      (p3_rdreq       ),  // input wire rd_en
	.dout	      (p3_rddat       ),  // output wire [23 : 0] dout
	.full	      (p3_full        ),  // output wire full
	.empty	      (p3_empty       )   // output wire empty
);
fifo_image_i fifo_image_i_R2(
	.clk	      (i_sclk         ),  // input wire clk
	.rst	      (i_vsync        ),  // input wire rst
	.din	      (p3_rddat       ),  // input wire [23 : 0] din
	.wr_en	      (p3_valid       ),  // input wire wr_en
	.rd_en	      (p2_rdreq       ),  // input wire rd_en
	.dout	      (p2_rddat       ),  // output wire [23 : 0] dout
	.full	      (p2_full        ),  // output wire full
	.empty	      (p2_empty       )   // output wire empty
);
fifo_image_i fifo_image_i_R1(
	.clk	      (i_sclk         ),  // input wire clk
	.rst	      (i_vsync        ),  // input wire rst
	.din	      (p2_rddat       ),  // input wire [23 : 0] din
	.wr_en	      (p2_valid       ),  // input wire wr_en
	.rd_en	      (p1_rdreq       ),  // input wire rd_en
	.dout	      (p1_rddat       ),  // output wire [23 : 0] dout
	.full	      (p1_full        ),  // output wire full
	.empty	      (p1_empty       )   // output wire empty
);

Reuse_Data_L1#(
	.WIDTH        (WIDTH/3        ),
	.SIZE		  (SIZE           ),
	.CHANNEL      (CHANNEL        ),
	.REUSE        (REUSE          ),
	.LEN 		  (LEN            ),
	.PAD 		  (PAD            ),
	.STEP         (STEP           )
)Reuse_Data_L1_R(
	.i_sclk    	  (i_sclk         ),
	.i_vsync      (p7_vsync       ),
	.i_hsync      (p7_hsync       ),
	.i_valid      (p7_valid       ),
	.i_tdata      (p7_rddat_r     ),
	.o_wrvld      (Rr_wrvld       ),
	.o_wrdat      (Rr_wrdat       ),
	.o_wrcnt      (Rr_wrcnt       ),
	.o_rdreq      (Rr_rdreq       ),
	.o_rdcnt      (Rr_rdcnt       ),
	.o_vsync      (Rr_vsync       ),
	.o_hsync      (Rr_hsync       ),
	.o_reuse      (Rr_reuse       ),
	.o_valid      (Rr_valid       )
);
Reuse_Data_L1#(
	.WIDTH        (WIDTH/3        ),
	.SIZE		  (SIZE           ),
	.CHANNEL      (CHANNEL        ),
	.REUSE        (REUSE          ),
	.LEN 		  (LEN            ),
	.PAD 		  (PAD            ),
	.STEP         (STEP           )
)Reuse_Data_L1_G(
	.i_sclk    	  (i_sclk         ),
	.i_vsync      (p7_vsync       ),
	.i_hsync      (p7_hsync       ),
	.i_valid      (p7_valid       ),
	.i_tdata      (p7_rddat_g     ),
	.o_wrvld      (Rg_wrvld       ),
	.o_wrdat      (Rg_wrdat       ),
	.o_wrcnt      (Rg_wrcnt       ),
	.o_rdreq      (Rg_rdreq       ),
	.o_rdcnt      (Rg_rdcnt       ),
	.o_vsync      (Rg_vsync       ),
	.o_hsync      (Rg_hsync       ),
	.o_reuse      (Rg_reuse       ),
	.o_valid      (Rg_valid       )
);
Reuse_Data_L1#(
	.WIDTH        (WIDTH/3        ),
	.SIZE		  (SIZE           ),
	.CHANNEL      (CHANNEL        ),
	.REUSE        (REUSE          ),
	.LEN 		  (LEN            ),
	.PAD 		  (PAD            ),
	.STEP         (STEP           )
)Reuse_Data_L1_B(
	.i_sclk    	  (i_sclk         ),
	.i_vsync      (p7_vsync       ),
	.i_hsync      (p7_hsync       ),
	.i_valid      (p7_valid       ),
	.i_tdata      (p7_rddat_b     ),
	.o_wrvld      (Rb_wrvld       ),
	.o_wrdat      (Rb_wrdat       ),
	.o_wrcnt      (Rb_wrcnt       ),
	.o_rdreq      (Rb_rdreq       ),
	.o_rdcnt      (Rb_rdcnt       ),
	.o_vsync      (Rb_vsync       ),
	.o_hsync      (Rb_hsync       ),
	.o_reuse      (Rb_reuse       ),
	.o_valid      (Rb_valid       )
);


xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (7                 ),// DECIMAL
	.ADDR_WIDTH_B            (7                 ),// DECIMAL
	.AUTO_SLEEP_TIME         (0                 ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (392               ),// DECIMAL
	.CASCADE_HEIGHT          (0                 ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"    ),// String
	.ECC_MODE                ("no_ecc"          ),// String
	.MEMORY_INIT_FILE        ("none"            ),// String
	.MEMORY_INIT_PARAM       ("0"               ),// String
	.MEMORY_OPTIMIZATION     ("true"            ),// String
	.MEMORY_PRIMITIVE        ("auto"            ),// String
	.MEMORY_SIZE             (392*112           ),// DECIMAL
	.MESSAGE_CONTROL         (0                 ),// DECIMAL
	.READ_DATA_WIDTH_B       (392               ),// DECIMAL
	.READ_LATENCY_B          (1                 ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"               ),// String
	.RST_MODE_A              ("SYNC"            ),// String
	.RST_MODE_B              ("SYNC"            ),// String
	.SIM_ASSERT_CHK          (1                 ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0                 ),// DECIMAL
	.USE_MEM_INIT            (0                 ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep"   ),// String
	.WRITE_DATA_WIDTH_A      (392               ),// DECIMAL
	.WRITE_MODE_B            ("no_change"       )// String
)
xpm_memory_sdpram_r(
	.doutb                   (Rr_rddat          ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (Rr_wrcnt          ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (Rr_rdcnt          ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk            ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk            ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (Rr_wrdat          ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (Rr_wrvld          ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (Rr_rdreq          ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0              ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0              ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0              ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_vsync           ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0              ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (Rr_wrvld          ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
												  // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
												  // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);
xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (7                 ),// DECIMAL
	.ADDR_WIDTH_B            (7                 ),// DECIMAL
	.AUTO_SLEEP_TIME         (0                 ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (392               ),// DECIMAL
	.CASCADE_HEIGHT          (0                 ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"    ),// String
	.ECC_MODE                ("no_ecc"          ),// String
	.MEMORY_INIT_FILE        ("none"            ),// String
	.MEMORY_INIT_PARAM       ("0"               ),// String
	.MEMORY_OPTIMIZATION     ("true"            ),// String
	.MEMORY_PRIMITIVE        ("auto"            ),// String
	.MEMORY_SIZE             (392*112           ),// DECIMAL
	.MESSAGE_CONTROL         (0                 ),// DECIMAL
	.READ_DATA_WIDTH_B       (392               ),// DECIMAL
	.READ_LATENCY_B          (1                 ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"               ),// String
	.RST_MODE_A              ("SYNC"            ),// String
	.RST_MODE_B              ("SYNC"            ),// String
	.SIM_ASSERT_CHK          (1                 ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0                 ),// DECIMAL
	.USE_MEM_INIT            (0                 ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep"   ),// String
	.WRITE_DATA_WIDTH_A      (392               ),// DECIMAL
	.WRITE_MODE_B            ("no_change"       )// String
)
xpm_memory_sdpram_g(
	.doutb                   (Rg_rddat          ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (Rg_wrcnt          ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (Rg_rdcnt          ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk            ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk            ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (Rg_wrdat          ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (Rg_wrvld          ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (Rg_rdreq          ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0              ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0              ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0              ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_vsync           ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0              ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (Rg_wrvld          ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
												  // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
												  // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);
xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (7                 ),// DECIMAL
	.ADDR_WIDTH_B            (7                 ),// DECIMAL
	.AUTO_SLEEP_TIME         (0                 ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (392               ),// DECIMAL
	.CASCADE_HEIGHT          (0                 ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"    ),// String
	.ECC_MODE                ("no_ecc"          ),// String
	.MEMORY_INIT_FILE        ("none"            ),// String
	.MEMORY_INIT_PARAM       ("0"               ),// String
	.MEMORY_OPTIMIZATION     ("true"            ),// String
	.MEMORY_PRIMITIVE        ("auto"            ),// String
	.MEMORY_SIZE             (392*112           ),// DECIMAL
	.MESSAGE_CONTROL         (0                 ),// DECIMAL
	.READ_DATA_WIDTH_B       (392               ),// DECIMAL
	.READ_LATENCY_B          (1                 ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"               ),// String
	.RST_MODE_A              ("SYNC"            ),// String
	.RST_MODE_B              ("SYNC"            ),// String
	.SIM_ASSERT_CHK          (1                 ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0                 ),// DECIMAL
	.USE_MEM_INIT            (0                 ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep"   ),// String
	.WRITE_DATA_WIDTH_A      (392               ),// DECIMAL
	.WRITE_MODE_B            ("no_change"       )// String
)
xpm_memory_sdpram_b(
	.doutb                   (Rb_rddat          ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (Rb_wrcnt          ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (Rb_rdcnt          ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk            ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk            ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (Rb_wrdat          ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (Rb_wrvld          ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (Rb_rdreq          ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0              ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0              ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0              ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_vsync           ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0              ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (Rb_wrvld          ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
												  // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
												  // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);

endmodule
