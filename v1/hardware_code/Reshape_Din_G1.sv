`timescale 1ns / 1ps

module Reshape_Din_G1#(
	parameter						WIDTH   = 27  ,
	parameter						SIZE    = 56  ,
	parameter						CHANNEL = 64  ,
	parameter						LEN     = 3   ,
	parameter						STEP    = 2   ,
	parameter						GAP     = 4'd0,
	parameter						PADWAIT = 21
)(
	input	wire					i_sclk        ,
	input	wire					i_vsync       ,
	input	wire					i_hsync       ,
	input	wire					i_reuse       ,
	input	wire					i_valid       ,
	input	wire[WIDTH-1:0]			i_tdata       ,

	output	wire					o_vsync_c     ,
	output	wire					o_hsync_c     ,
	output	wire					o_reuse_c     ,
	output	wire					o_valid_c     ,
	output	wire[2*LEN*LEN-1:0]		o_tdata_c     ,

	output	wire					o_vsync_m     ,
	output	wire					o_hsync_m     ,
	output	wire					o_reuse_m     ,
	output	wire					o_valid_m     ,
	output	wire[WIDTH-1:0]			o_tdata_m     ,

	output	wire					o_vsync_d     ,
	output	wire					o_hsync_d     ,
	output	wire					o_reuse_d     ,
	output	wire					o_valid_d     ,
	output	wire[WIDTH-1:0]			o_tdata_d     
);

//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
wire[WIDTH-1:0]					p3_tdata_r        ;
wire[1:0]						s3_tdata_r        ;
wire[1:0]						s2_tdata_r        ;
wire[1:0]						s1_tdata_r        ;
												
wire							p2_rdreq          ;
wire							p2_vsync          ;
wire							p2_hsync          ;
wire							p2_reuse          ;
wire							p2_valid          ;
wire[WIDTH-1:0]					p2_rddat          ;
wire[WIDTH-1:0]					p2_rddat_r        ;
wire							p2_full           ;
wire							p2_empty          ;
												
wire							p1_rdreq          ;
wire							p1_vsync          ;
wire							p1_hsync          ;
wire							p1_reuse          ;
wire							p1_valid          ;
wire[WIDTH-1:0]					p1_rddat          ;
wire[WIDTH-1:0]					p1_rddat_r        ;
wire							p1_full           ;
wire							p1_empty          ;
												
reg [2:0]						cnt_step_c        ;
reg [2:0]						cnt_step_r        ;
reg 							hsync_r           ;
reg 							reuse_r           ;
reg 							valid_r           ;
reg [WIDTH*LEN-1:0]				tdata_m           ;
reg [2*LEN*LEN-1:0]				tdata_c_9         ;
												
reg 							vsync_r_o         ;
reg 							hsync_r_o         ;
reg 							reuse_r_o         ;
reg 							valid_r_o         ;
reg [WIDTH*LEN-1:0]				tdata_m_o         ;
reg [WIDTH-1:0]					tdata_d_o         ;
wire signed[WIDTH-1:0]			md_adata[LEN-1:0] ;
												
wire							m_vsync           ;
wire							m_hsync           ;
wire							m_reuse           ;
wire							m_valid           ;
wire[WIDTH-1:0]					m_tdata           ;
reg [10:0]						m_waddr           ;
												
wire							pm1_rdreq         ;
wire							pm1_rdreq_r       ;
reg [10:0]						pm1_rdcnt         ;
wire							pm1_vsync         ;
wire							pm1_hsync         ;
wire							pm1_reuse         ;
wire							pm1_valid         ;
wire[WIDTH-1:0]					pm1_rddat         ;
wire							pm1_full          ;
wire							pm1_empty         ;
reg 							pm1_half          ;
												
reg [1:0]						pm1_vsync_dly     ;
reg [1:0]						pm1_hsync_dly     ;
reg [1:0]						pm1_reuse_dly     ;
												
reg 							pmo_wrreq         ;
reg [10:0]						pmo_wrcnt         ;
reg 							pmo_rdreq         ;
reg [10:0]						pmo_rdcnt         ;
reg 							pmo_valid         ;
wire[WIDTH-1:0]					pmo_rddat         ;
	
wire							pd2_rdreq         ;
wire							pd2_vsync         ;
wire							pd2_hsync         ;
wire							pd2_reuse         ;
wire							pd2_valid         ;
wire[WIDTH-1:0]					pd2_rddat         ;
wire[WIDTH-1:0]					pd2_rddat_r       ;
wire							pd2_full          ;
wire							pd2_empty         ;
	
wire							pd1_rdreq         ;
wire							pd1_vsync         ;
wire							pd1_hsync         ;
wire							pd1_reuse         ;
wire							pd1_valid         ;
wire[WIDTH-1:0]					pd1_rddat         ;
wire[WIDTH-1:0]					pd1_rddat_r       ;
wire							pd1_full          ;
wire							pd1_empty         ;

//----------------------------------------------//
//					CODING						//
//----------------------------------------------//
assign o_vsync_c  = i_vsync;
assign o_hsync_c = hsync_r_o;
assign o_reuse_c = reuse_r_o;
assign o_valid_c = valid_r_o;
assign o_tdata_c = tdata_c_9;

assign o_vsync_m  = i_vsync;
assign o_hsync_m  = pm1_hsync_dly[1];
assign o_reuse_m  = pm1_reuse_dly[1];
assign o_valid_m  = pmo_valid;
assign o_tdata_m  = pmo_rddat;

assign o_vsync_d  = i_vsync;
assign o_hsync_d  = pd1_hsync;
assign o_reuse_d  = pd1_reuse;
assign o_valid_d  = pd1_valid;
assign o_tdata_d  = pd1_rddat_r;

assign p3_tdata_r  = i_valid  ? i_tdata :'d0;
assign p2_rddat_r  = p2_valid ? p2_rddat:'d0;
assign p1_rddat_r  = p1_valid ? p1_rddat:'d0;
assign md_adata[0] = tdata_m_o[WIDTH*1-1:WIDTH*0];
assign md_adata[1] = tdata_m_o[WIDTH*2-1:WIDTH*1];
assign md_adata[2] = tdata_m_o[WIDTH*3-1:WIDTH*2];

assign pm1_rdreq_r = pm1_half&pm1_rdreq;
assign pd2_rddat_r = pd2_valid ? pd2_rddat:'d0;
assign pd1_rddat_r = pd1_valid ? pd1_rddat:'d0;

always@(posedge i_sclk)
begin
	if(p2_reuse)				cnt_step_c <= 'd0;
	else if(p2_valid)
	begin
		if(cnt_step_c==STEP-1)	cnt_step_c <= 'd0;
		else					cnt_step_c <= cnt_step_c + 'd1;
	end
	
	if(i_vsync)					cnt_step_r <= 'd0;
	else if(p2_hsync)
	begin
		if(cnt_step_r==STEP-1)	cnt_step_r <= 'd0;
		else					cnt_step_r <= cnt_step_r + 'd1;
	end
end

always@(posedge i_sclk)
begin
	if(p2_hsync)	tdata_c_9 <= 'd0;
	else
	begin
		tdata_c_9[2  -1:  0] <= tdata_c_9[2*2-1:2  ];
		tdata_c_9[2*2-1:2  ] <= tdata_c_9[2*3-1:2*2];
		tdata_c_9[2*4-1:2*3] <= tdata_c_9[2*5-1:2*4];
		tdata_c_9[2*5-1:2*4] <= tdata_c_9[2*6-1:2*5];
		tdata_c_9[2*7-1:2*6] <= tdata_c_9[2*8-1:2*7];
		tdata_c_9[2*8-1:2*7] <= tdata_c_9[2*9-1:2*8];
		
		if(p2_valid)
		begin
			tdata_c_9[2*3-1:2*2] <= s1_tdata_r;
			tdata_c_9[2*6-1:2*5] <= s2_tdata_r;
			tdata_c_9[2*9-1:2*8] <= s3_tdata_r;
		end
		else
		begin
			tdata_c_9[2*3-1:2*2] <= 'd0;
			tdata_c_9[2*6-1:2*5] <= 'd0;
			tdata_c_9[2*9-1:2*8] <= 'd0;
		end
	end
end

always@(posedge i_sclk)
begin
	vsync_r_o <= p2_vsync;
	hsync_r   <= p2_hsync;
	reuse_r   <= p2_reuse;
	valid_r   <= p2_valid;
	
	if(p2_valid&&!p1_valid)		tdata_m <= {p3_tdata_r,p2_rddat_r,p2_rddat_r};
	else if(p2_valid&&!i_valid)	tdata_m <= {p2_rddat_r,p2_rddat_r,p1_rddat_r};
	else						tdata_m <= {p3_tdata_r,p2_rddat_r,p1_rddat_r};
	
	if(cnt_step_r==STEP-1)
	begin
		hsync_r_o <= hsync_r;
		reuse_r_o <= reuse_r;
		tdata_m_o <= tdata_m;
		if(cnt_step_c==STEP-1)
		begin
			valid_r_o <= valid_r;
			tdata_d_o <= tdata_m[WIDTH*(LEN-1)-1:WIDTH*(LEN-2)];
		end
		else
		begin
			valid_r_o <= 'd0;
			tdata_d_o <= 'd0;
		end
	end
	else
	begin
		hsync_r_o <= 'd0;
		reuse_r_o <= 'd0;
		valid_r_o <= 'd0;
		tdata_d_o <= 'd0;
	end
end

always@(posedge i_sclk)
begin
	pmo_rdreq     <= pm1_valid;
	pmo_valid     <= pmo_rdreq;
	pmo_wrreq     <= pm1_rdreq_r;
	pm1_vsync_dly <= {pm1_vsync_dly[0:0],pm1_vsync};
	pm1_hsync_dly <= {pm1_hsync_dly[0:0],pm1_hsync};
	pm1_reuse_dly <= {pm1_reuse_dly[0:0],pm1_reuse};

	if(m_hsync)									m_waddr <= 'd0;
	else if(m_valid)							m_waddr <= m_waddr + 'd1;

	if(pm1_hsync||pm1_rdcnt==SIZE/2*CHANNEL)	pm1_rdcnt <= 'd0;
	else if(pm1_rdreq)							pm1_rdcnt <= pm1_rdcnt + 'd1;
	
	if(pm1_vsync||pm1_rdcnt==SIZE/2*CHANNEL)	pm1_half <= 'd0;
	else if(pm1_hsync)							pm1_half <= 'd1;

	if(pm1_hsync_dly[0])						pmo_wrcnt <= 'd0;
	else if(pmo_wrreq)							pmo_wrcnt <= pmo_wrcnt + 'd1;

	if(pm1_vsync||pmo_rdcnt==SIZE/2*CHANNEL)	pmo_rdcnt <= 'd0;
	else if(pmo_rdreq)							pmo_rdcnt <= pmo_rdcnt + 'd1;
end

//----------------------------------------------//
//					SIGN						//
//----------------------------------------------//
Sign#(
	.WIDTH        (WIDTH          )
)Sign_3(
	.i_tdata      (p3_tdata_r     ),
	.o_tdata      (s3_tdata_r     )
);
Sign#(
	.WIDTH        (WIDTH          )
)Sign_2(
	.i_tdata      (p2_rddat_r     ),
	.o_tdata      (s2_tdata_r     )
);
Sign#(
	.WIDTH        (WIDTH          )
)Sign_1(
	.i_tdata      (p1_rddat_r     ),
	.o_tdata      (s1_tdata_r     )
);
//----------------------------------------------//
//				PIPELING PADDING				//
//----------------------------------------------//
Pipeline#(
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
	.o_reuse      (p2_reuse       ),
	.o_valid      (p2_valid       )
);
Pipeline#(
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
	.o_reuse      (p1_reuse       ),
	.o_valid      (p1_valid       )
);

fifo_din_G01 fifo_din_G01_R2(
	.clk	      (i_sclk         ),  // input wire clk
	.rst	      (i_vsync        ),  // input wire rst
	//.din	      ({2'd0,i_tdata} ),  // input wire [47 : 0] din
	.din	      (i_tdata        ),
	.wr_en	      (i_valid        ),  // input wire wr_en
	.rd_en	      (p2_rdreq       ),  // input wire rd_en
	.dout	      (p2_rddat       ),  // output wire [47 : 0] dout
	.full	      (p2_full        ),  // output wire full
	.empty	      (p2_empty       )   // output wire empty
);
fifo_din_G01 fifo_din_G01_R1(
	.clk	      (i_sclk         ),  // input wire clk
	.rst	      (i_vsync        ),  // input wire rst
	.din	      (p2_rddat       ),  // input wire [47 : 0] din
	.wr_en	      (p2_valid       ),  // input wire wr_en
	.rd_en	      (p1_rdreq       ),  // input wire rd_en
	.dout	      (p1_rddat       ),  // output wire [47 : 0] dout
	.full	      (p1_full        ),  // output wire full
	.empty	      (p1_empty       )   // output wire empty
);
//----------------------------------------------//
//					Maxpool_3x3					//
//----------------------------------------------//
Maxpool_3x3#(
	.COPY         (1'b0           ),
	.WIDTH        (WIDTH          ),
	.LEN          (LEN            )
)Maxpool_3x3_t1(
	.i_sclk    	  (i_sclk         ),
	.i_vsync      (vsync_r_o      ),
	.i_hsync      (hsync_r_o      ),
	.i_reuse      (reuse_r_o      ),
	.i_valid      (valid_r_o      ),
	.i_tdata      (md_adata       ),
	.o_vsync      (m_vsync        ),
	.o_hsync      (m_hsync        ),
	.o_reuse      (m_reuse        ),
	.o_valid      (m_valid        ),
	.o_tdata      (m_tdata        )
);
Pipeline#(
	.GAP          (GAP            ),
	.SIZE		  (SIZE/2         ),
	.CHANNEL      (CHANNEL*2      ),
	.PADWAIT      (3800           )
)Pipeline_Rm1(
	.i_sclk    	  (i_sclk         ),
	.i_vsync   	  (m_vsync        ),
	.i_hsync   	  (m_hsync        ),
	.o_rdreq      (pm1_rdreq      ),
	.o_vsync      (pm1_vsync      ),
	.o_hsync      (pm1_hsync      ),
	.o_reuse      (pm1_reuse      ),
	.o_valid      (pm1_valid      )
);

fifo_ds_s1 fifo_ds_s1_Rm1(
	.clk	      (i_sclk         ),  // input wire clk
	.rst	      (i_vsync        ),  // input wire rst
	.din	      (m_tdata        ),  // input wire [45 : 0] din
	.wr_en	      (m_valid        ),  // input wire wr_en
	.rd_en	      (pm1_rdreq_r    ),  // input wire rd_en
	.dout	      (pm1_rddat      ),  // output wire [45 : 0] dout
	.full	      (pm1_full       ),  // output wire full
	.empty	      (pm1_empty      )   // output wire empty
);
xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (11              ),// DECIMAL
	.ADDR_WIDTH_B            (11              ),// DECIMAL
	.AUTO_SLEEP_TIME         (0               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (WIDTH           ),// DECIMAL
	.CASCADE_HEIGHT          (0               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"  ),// String
	.ECC_MODE                ("no_ecc"        ),// String
	.MEMORY_INIT_FILE        ("none"          ),// String
	.MEMORY_INIT_PARAM       ("0"             ),// String
	.MEMORY_OPTIMIZATION     ("true"          ),// String
	.MEMORY_PRIMITIVE        ("auto"          ),// String
	.MEMORY_SIZE             (WIDTH*2048      ),// DECIMAL
	.MESSAGE_CONTROL         (0               ),// DECIMAL
	.READ_DATA_WIDTH_B       (WIDTH           ),// DECIMAL
	.READ_LATENCY_B          (1               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"             ),// String
	.RST_MODE_A              ("SYNC"          ),// String
	.RST_MODE_B              ("SYNC"          ),// String
	.SIM_ASSERT_CHK          (1               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0               ),// DECIMAL
	.USE_MEM_INIT            (0               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep" ),// String
	.WRITE_DATA_WIDTH_A      (WIDTH           ),// DECIMAL
	.WRITE_MODE_B            ("no_change"     )// String
)
xpm_memory_sdpram_g1m0(
	.doutb                   (pmo_rddat       ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (pmo_wrcnt       ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (pmo_rdcnt       ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (pm1_rddat       ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (pmo_wrreq       ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (pmo_rdreq       ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_vsync         ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (pmo_wrreq       ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
											    // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
                                                // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);
//----------------------------------------------//
//					DOWNSAMPLE					//
//----------------------------------------------//
Pipeline#(
	.GAP          (GAP            ),
	.SIZE		  (SIZE/2         ),
	.CHANNEL      (CHANNEL        ),
	.PADWAIT      (6040           )
)Pipeline_Rd2(
	.i_sclk    	  (i_sclk         ),
	.i_vsync   	  (vsync_r_o      ),
	.i_hsync   	  (hsync_r_o      ),
	.o_rdreq      (pd2_rdreq      ),
	.o_vsync      (pd2_vsync      ),
	.o_hsync      (pd2_hsync      ),
	.o_reuse      (pd2_reuse      ),
	.o_valid      (pd2_valid      )
);
Pipeline#(
	.GAP          (GAP            ),
	.SIZE		  (SIZE/2         ),
	.CHANNEL      (CHANNEL        ),
	.PADWAIT      (6040           )
)Pipeline_Rd1(
	.i_sclk    	  (i_sclk         ),
	.i_vsync   	  (i_vsync        ),
	.i_hsync   	  (pd2_hsync      ),
	.o_rdreq      (pd1_rdreq      ),
	.o_vsync      (pd1_vsync      ),
	.o_hsync      (pd1_hsync      ),
	.o_reuse      (pd1_reuse      ),
	.o_valid      (pd1_valid      )
);

fifo_ds_s1 fifo_ds_s1_Rd2(
	.clk	      (i_sclk          ),  // input wire clk
	.rst	      (i_vsync         ),  // input wire rst
	.din	      (tdata_d_o       ),  // input wire [45 : 0] din
	.wr_en	      (valid_r_o       ),  // input wire wr_en
	.rd_en	      (pd2_rdreq       ),  // input wire rd_en
	.dout	      (pd2_rddat       ),  // output wire [45 : 0] dout
	.full	      (pd2_full        ),  // output wire full
	.empty	      (pd2_empty       )   // output wire empty
);
fifo_ds_s1 fifo_ds_s1_Rd1(
	.clk	      (i_sclk          ),  // input wire clk
	.rst	      (i_vsync         ),  // input wire rst
	.din	      (pd2_rddat       ),  // input wire [45 : 0] din
	.wr_en	      (pd2_valid       ),  // input wire wr_en
	.rd_en	      (pd1_rdreq       ),  // input wire rd_en
	.dout	      (pd1_rddat       ),  // output wire [45 : 0] dout
	.full	      (pd1_full        ),  // output wire full
	.empty	      (pd1_empty       )   // output wire empty
);

endmodule
