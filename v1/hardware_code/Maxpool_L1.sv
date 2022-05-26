`timescale 1ns / 1ps

module Maxpool_L1#(
	parameter							WIDTH   = 27 ,
	parameter							SIZE    = 112,
	parameter							THREAD  = 2  ,
	parameter							CHANNEL = 32 ,
	parameter							LEN     = 3  ,
	parameter							PAD     = 1  ,
	parameter							STEP    = 2  ,
	parameter							PADWAIT = 21 
)(
	input	wire						i_sclk       ,
	input	wire						i_vsync      ,
	input	wire						i_hsync      ,
	input	wire						i_reuse      ,
	input	wire						i_valid      ,
	input	wire[WIDTH*THREAD-1:0]		i_tdata      ,

	output	wire						o_vsync      ,
	output	wire						o_hsync      ,
	output	wire						o_reuse      ,
	output	wire						o_valid      ,
	output	wire[WIDTH-1:0]				o_tdata      
);

//----------------------------------------------//
//					PARAMETER					//
//----------------------------------------------//
parameter	WIDTH_D = WIDTH*THREAD;
//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
wire[WIDTH_D-1:0]					p3_tdata_r ;

wire								p2_rdreq   ;
wire								p2_vsync   ;
wire								p2_hsync   ;
wire								p2_valid   ;
wire[WIDTH_D-1:0]					p2_rddat   ;
wire[WIDTH_D-1:0]					p2_rddat_r ;
wire								p2_full    ;
wire								p2_empty   ;

wire								p1_rdreq   ;
wire								p1_vsync   ;
wire								p1_hsync   ;
wire								p1_valid   ;
wire[WIDTH_D-1:0]					p1_rddat   ;
wire[WIDTH_D-1:0]					p1_rddat_r ;
wire								p1_full    ;
wire								p1_empty   ;

reg 								p3_vsync   ;
reg 								p3_hsync   ;
reg 								p3_valid   ;
reg  signed[WIDTH:0]				p3_rddat_t1[LEN-1:0];
reg  signed[WIDTH:0]				p3_rddat_t2[LEN-1:0];

wire								m1_vsync   ;
wire								m1_hsync   ;
wire								m1_valid   ;
wire[WIDTH:0]						m1_tdata   ;

wire								m2_vsync   ;
wire								m2_hsync   ;
wire								m2_valid   ;
wire[WIDTH:0]						m2_tdata   ;

reg 								t4_vsync   ;
reg 								t4_hsync   ;
reg 								t4_valid   ;
reg [WIDTH*THREAD-1:0]				t4_tdata   ;

wire								R1_wrvld   ;
wire[WIDTH*THREAD-1:0]				R1_wrdat   ;
wire[10:0]							R1_wrcnt   ;
wire								R1_rdreq   ;
wire[10:0]							R1_rdcnt   ;
wire[WIDTH*THREAD-1:0]				R1_rddat   ;

//----------------------------------------------//
//					CODING						//
//----------------------------------------------//
assign p3_tdata_r = i_valid  ? i_tdata :'d0;
assign p2_rddat_r = p2_valid ? p2_rddat:'d0;
assign p1_rddat_r = p1_valid ? p1_rddat:'d0;

always@(posedge i_sclk)
begin
	p3_vsync       <= i_vsync;
	p3_hsync       <= p2_hsync;
	p3_valid       <= p2_valid;
	
	p3_rddat_t2[0] <= {1'd0,p1_rddat_r[WIDTH_D-1   :WIDTH_D/2 ]};
	p3_rddat_t2[1] <= {1'd0,p2_rddat_r[WIDTH_D-1   :WIDTH_D/2 ]};
	p3_rddat_t2[2] <= {1'd0,p3_tdata_r[WIDTH_D-1   :WIDTH_D/2 ]};
															  
	p3_rddat_t1[0] <= {1'd0,p1_rddat_r[WIDTH_D/2-1 :0         ]};
	p3_rddat_t1[1] <= {1'd0,p2_rddat_r[WIDTH_D/2-1 :0         ]};
	p3_rddat_t1[2] <= {1'd0,p3_tdata_r[WIDTH_D/2-1 :0         ]};
end

always@(posedge i_sclk)
begin
	t4_vsync <= m1_vsync;
	t4_hsync <= m1_hsync;
	t4_valid <= m1_valid;
	t4_tdata <= {m2_tdata[WIDTH-1:0],m1_tdata[WIDTH-1:0]};
end

Pipeline#(
	.DELAY		  (2              ),
	.SIZE		  (SIZE           ),
	.CHANNEL      (CHANNEL        ),
	.PADWAIT      (PADWAIT        )
)Pipeline_R2(
	.i_sclk    	  (i_sclk         ),
	.i_vsync   	  (i_vsync        ),
	.i_hsync   	  (i_hsync        ),
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

fifo_maxpool_L1 fifo_maxpool_R2(
	.clk	      (i_sclk         ),  // input wire clk
	.rst	      (i_vsync        ),  // input wire rst
	.din	      (p3_tdata_r     ),  // input wire [57 : 0] din
	.wr_en	      (i_valid        ),  // input wire wr_en
	.rd_en	      (p2_rdreq       ),  // input wire rd_en
	.dout	      (p2_rddat       ),  // output wire [57 : 0] dout
	.full	      (p2_full        ),  // output wire full
	.empty	      (p2_empty       )   // output wire empty
);
fifo_maxpool_L1 fifo_maxpool_R1(
	.clk	      (i_sclk         ),  // input wire clk
	.rst	      (i_vsync        ),  // input wire rst
	.din	      (p2_rddat       ),  // input wire [57 : 0] din
	.wr_en	      (p2_valid       ),  // input wire wr_en
	.rd_en	      (p1_rdreq       ),  // input wire rd_en
	.dout	      (p1_rddat       ),  // output wire [57 : 0] dout
	.full	      (p1_full        ),  // output wire full
	.empty	      (p1_empty       )   // output wire empty
);

Maxpool_3x3#(
	.COPY         (1'b0           ), 
	.WIDTH        (WIDTH+1        ),
	.LEN          (LEN            )
)Maxpool_3x3_t1(
	.i_sclk    	  (i_sclk         ),
	.i_vsync      (p3_vsync       ),
	.i_hsync      (p3_hsync       ),
	.i_valid      (p3_valid       ),
	.i_tdata      (p3_rddat_t1    ),
	.o_vsync      (m1_vsync       ),
	.o_hsync      (m1_hsync       ),
	.o_valid      (m1_valid       ),
	.o_tdata      (m1_tdata       )
);
Maxpool_3x3#(
	.COPY         (1'b0           ), 
	.WIDTH        (WIDTH+1        ),
	.LEN          (LEN            )
)Maxpool_3x3_t2(
	.i_sclk    	  (i_sclk         ),
	.i_vsync      (p3_vsync       ),
	.i_hsync      (p3_hsync       ),
	.i_valid      (p3_valid       ),
	.i_tdata      (p3_rddat_t2    ),
	.o_vsync      (m2_vsync       ),
	.o_hsync      (m2_hsync       ),
	.o_valid      (m2_valid       ),
	.o_tdata      (m2_tdata       )
);
Reshape_MaxPool_L1#(
	.WIDTH_D      (WIDTH          ),
	.WIDTH_A      (11             ),
	.SIZE		  (SIZE           ),
	.CHANNEL      (CHANNEL        ),
	.THREAD       (THREAD         ),
	.LEN 		  (LEN            ),
	.PAD 		  (PAD            ),
	.STEP         (STEP           )
)Reshape_MaxPool_L1_inst(
	.i_sclk    	  (i_sclk         ),
	.i_vsync      (t4_vsync       ),
	.i_hsync      (t4_hsync       ),
	.i_valid      (t4_valid       ),
	.i_tdata      (t4_tdata       ),
	.o_wrvld      (R1_wrvld       ),
	.o_wrdat      (R1_wrdat       ),
	.o_wrcnt      (R1_wrcnt       ),
	.o_rdreq      (R1_rdreq       ),
	.o_rdcnt      (R1_rdcnt       ),
	.i_rddat      (R1_rddat       ),
	.o_vsync      (o_vsync        ),
	.o_hsync      (o_hsync        ),
	.o_reuse      (o_reuse        ),
	.o_valid      (o_valid        ),
	.o_tdata      (o_tdata        )
);


xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (11                ),// DECIMAL
	.ADDR_WIDTH_B            (11                ),// DECIMAL
	.AUTO_SLEEP_TIME         (0                 ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (WIDTH*THREAD         ),// DECIMAL
	.CASCADE_HEIGHT          (0                 ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"    ),// String
	.ECC_MODE                ("no_ecc"          ),// String
	.MEMORY_INIT_FILE        ("none"            ),// String
	.MEMORY_INIT_PARAM       ("0"               ),// String
	.MEMORY_OPTIMIZATION     ("true"            ),// String
	.MEMORY_PRIMITIVE        ("auto"            ),// String
	.MEMORY_SIZE             (WIDTH*THREAD *1792   ),// DECIMAL
	.MESSAGE_CONTROL         (0                 ),// DECIMAL
	.READ_DATA_WIDTH_B       (WIDTH*THREAD         ),// DECIMAL
	.READ_LATENCY_B          (1                 ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"               ),// String
	.RST_MODE_A              ("SYNC"            ),// String
	.RST_MODE_B              ("SYNC"            ),// String
	.SIM_ASSERT_CHK          (1                 ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0                 ),// DECIMAL
	.USE_MEM_INIT            (0                 ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep"   ),// String
	.WRITE_DATA_WIDTH_A      (WIDTH*THREAD         ),// DECIMAL
	.WRITE_MODE_B            ("no_change"       ) // String
)
xpm_memory_sdpram_inst(
	.doutb                   (R1_rddat          ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (R1_wrcnt          ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (R1_rdcnt          ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk            ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk            ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (R1_wrdat          ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (R1_wrvld          ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (R1_rdreq          ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0              ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0              ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0              ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_vsync           ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0              ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (R1_wrvld          ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
                                                  // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
                                                  // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);

endmodule
