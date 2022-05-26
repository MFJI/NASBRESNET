`timescale 1ns / 1ps

module Load_param_L1#(
	parameter							WIDTH_P = 60 ,
	parameter							WIDTH_W = 20 ,
	parameter							WIDTH_A = 18 ,
	parameter							WIDTH_B = 35 ,
	parameter							THREAD  = 2  ,
	parameter							SIZE_W  = 49 
)(
	input	wire						i_sclk       ,
	input	wire						i_rstp       ,

	input	wire[2:0]					i_param_vld  ,
	input	wire[WIDTH_P-1:0]			i_param      ,

	input	wire						i_Conv_req   ,
	output	wire						o_cw_vld     ,
	output	wire[WIDTH_P*THREAD-1:0]	o_cw         ,
	
	input	wire						i_Bn_req     ,
	output	wire[WIDTH_A-1:0]			o_bn_a       ,
	output	wire[WIDTH_B-1:0]			o_bn_b       
);

//----------------------------------------------//
//					PARAM						//
//----------------------------------------------//
parameter	SIZE_WT = SIZE_W*64/THREAD;
parameter	SIZE_BN = 64;
//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
reg [8:0]				wr_addr_bn           ;
reg 					rd_en_bn             ;
reg [8:0]				rd_addr_bn           ;
wire[34:0]				rd_data_a            ;
wire[34:0]				rd_data_b            ;

reg [5:0]				cnt_w                ;
reg [1:0]				cnt_thread           ;
reg [1:0]				cnt_thread_d1        ;
reg [THREAD-1:0]		wr_en_w              ;
reg [10:0]				wr_addr_w            ;
reg [WIDTH_P-1:0]		wr_data_w[THREAD-1:0];
reg 					wr_done              ;

reg 					rd_en_w              ;
reg [5:0]				rd_cnt_w             ;
reg [10:0]				rd_addr_w            ;
wire[WIDTH_P-1:0]		rd_data_w[THREAD-1:0];
reg 					rd_data_w_vld        ;
//----------------------------------------------//
//					CODING						//
//----------------------------------------------//
assign o_cw_vld = rd_data_w_vld;
assign o_cw     = {rd_data_w[1],rd_data_w[0]};
assign o_bn_a   = rd_data_a;
assign o_bn_b   = rd_data_b;

always @(posedge i_sclk)
begin
	rd_en_bn <= i_Bn_req;
	
	if(i_rstp||wr_addr_bn==SIZE_BN)	wr_addr_bn <= 'd0;
	else if(|i_param_vld[2:1])		wr_addr_bn <= wr_addr_bn + 'd1;
	
	if(i_rstp||rd_addr_bn==SIZE_BN)	rd_addr_bn <= 'd0;
	else if(rd_en_bn)				rd_addr_bn <= rd_addr_bn + 'd1;
end

always @(posedge i_sclk)
begin
	rd_data_w_vld <= rd_en_w;
	cnt_thread_d1 <= cnt_thread;
	
	if(i_rstp)						cnt_thread <= 'd0;
	else if(i_param_vld[0]&&cnt_w==SIZE_W-1)
	begin
		if(cnt_thread==THREAD-1)	cnt_thread <= 'd0;
		else						cnt_thread <= cnt_thread + 'd1;
	end
	
	if(i_rstp||wr_done)
	begin
		cnt_w      <= 'd0;
		wr_addr_w  <= 'd0;
	end
	else if(|wr_en_w)
	begin
		if(cnt_w==SIZE_W-1)							cnt_w <= 'd0;
		else										cnt_w <= cnt_w + 'd1;
		
		if(cnt_w==SIZE_W-1&&cnt_thread_d1<THREAD-1)	wr_addr_w <= wr_addr_w + 1'b1 - SIZE_W;
		else										wr_addr_w <= wr_addr_w + 'd1;
	end
	
	if(wr_addr_w==SIZE_WT)							wr_done <= 'd1;
	else											wr_done <= 'd0;

	if(i_rstp||rd_cnt_w==SIZE_W-1)					rd_en_w <= 'd0;
	else if(wr_done||i_Conv_req)					rd_en_w <= 'd1;

	if(rd_en_w)										rd_cnt_w <= rd_cnt_w + 'd1;
	else											rd_cnt_w <= 'd0;

	if(i_rstp||rd_addr_w==SIZE_WT-1)				rd_addr_w <= 'd0;
	else if(rd_en_w)								rd_addr_w <= rd_addr_w + 'd1;
end

genvar w;
generate
	for(w=0;w<THREAD;w=w+1)
	begin
		always@(posedge i_sclk)
		begin
			if(i_param_vld[0]&&w==cnt_thread)		wr_en_w[w] <= 'd1;
			else									wr_en_w[w] <= 'd0;
			
			if(i_rstp)								wr_data_w[w] <= 'd0;
			else if(i_param_vld[0]&&w==cnt_thread)	wr_data_w[w] <= i_param;
		end
		
		xpm_memory_sdpram#(
			.ADDR_WIDTH_A            (11                              ),// DECIMAL
			.ADDR_WIDTH_B            (11                              ),// DECIMAL
			.AUTO_SLEEP_TIME         (0                               ),// DECIMAL
			.BYTE_WRITE_WIDTH_A      (60                              ),// DECIMAL
			.CASCADE_HEIGHT          (0                               ),// DECIMAL
			.CLOCKING_MODE           ("common_clock"                  ),// String
			.ECC_MODE                ("no_ecc"                        ),// String
			.MEMORY_INIT_FILE        ("none"                          ),// String
			.MEMORY_INIT_PARAM       ("0"                             ),// String
			.MEMORY_OPTIMIZATION     ("true"                          ),// String
			.MEMORY_PRIMITIVE        ("auto"                          ),// String
			.MEMORY_SIZE             (60*1568                          ),// DECIMAL
			.MESSAGE_CONTROL         (0                               ),// DECIMAL
			.READ_DATA_WIDTH_B       (60                              ),// DECIMAL
			.READ_LATENCY_B          (1                               ),// DECIMAL
			.READ_RESET_VALUE_B      ("0"                             ),// String
			.RST_MODE_A              ("SYNC"                          ),// String
			.RST_MODE_B              ("SYNC"                          ),// String
			.SIM_ASSERT_CHK          (1                               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
			.USE_EMBEDDED_CONSTRAINT (0                               ),// DECIMAL
			.USE_MEM_INIT            (0                               ),// DECIMAL
			.WAKEUP_TIME             ("disable_sleep"                 ),// String
			.WRITE_DATA_WIDTH_A      (60                              ),// DECIMAL
			.WRITE_MODE_B            ("no_change"                     )// String
		)
		xpm_memory_sdpram_L1_b(
			.doutb                   (rd_data_w[w]                    ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
			.addra                   (wr_addr_w                       ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
			.addrb                   (rd_addr_w                       ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
			.clka                    (i_sclk                          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
			.clkb                    (i_sclk                          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
			.dina                    (wr_data_w[w]                    ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
			.ena                     (wr_en_w[w]                      ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
			.enb                     (rd_en_w                         ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
			.injectdbiterra          (1'b0                            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
			.injectsbiterra          (1'b0                            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
			.regceb                  (1'b0                            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
			.rstb                    (i_rstp                          ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
			.sleep                   (1'b0                            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
			.wea                     (wr_en_w[w]                      ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
																		// used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
																		// synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
		);
	end
endgenerate


xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (9                               ),// DECIMAL
	.ADDR_WIDTH_B            (9                               ),// DECIMAL
	.AUTO_SLEEP_TIME         (0                               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (35                              ),// DECIMAL
	.CASCADE_HEIGHT          (0                               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"                  ),// String
	.ECC_MODE                ("no_ecc"                        ),// String
	.MEMORY_INIT_FILE        ("none"                          ),// String
	.MEMORY_INIT_PARAM       ("0"                             ),// String
	.MEMORY_OPTIMIZATION     ("true"                          ),// String
	.MEMORY_PRIMITIVE        ("auto"                          ),// String
	.MEMORY_SIZE             (35*512                          ),// DECIMAL
	.MESSAGE_CONTROL         (0                               ),// DECIMAL
	.READ_DATA_WIDTH_B       (35                              ),// DECIMAL
	.READ_LATENCY_B          (1                               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"                             ),// String
	.RST_MODE_A              ("SYNC"                          ),// String
	.RST_MODE_B              ("SYNC"                          ),// String
	.SIM_ASSERT_CHK          (1                               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0                               ),// DECIMAL
	.USE_MEM_INIT            (0                               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep"                 ),// String
	.WRITE_DATA_WIDTH_A      (35                              ),// DECIMAL
	.WRITE_MODE_B            ("no_change"                     )// String
)
xpm_memory_sdpram_L1_a(
	.doutb                   (rd_data_a                       ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_bn                      ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_bn                      ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk                          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk                          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_param[34:0]                   ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_param_vld[1]                  ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rd_en_bn                        ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0                            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0                            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0                            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp                          ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0                            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (i_param_vld[1]                  ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
											                    // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
											                    // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);
xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (9                               ),// DECIMAL
	.ADDR_WIDTH_B            (9                               ),// DECIMAL
	.AUTO_SLEEP_TIME         (0                               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (35                              ),// DECIMAL
	.CASCADE_HEIGHT          (0                               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"                  ),// String
	.ECC_MODE                ("no_ecc"                        ),// String
	.MEMORY_INIT_FILE        ("none"                          ),// String
	.MEMORY_INIT_PARAM       ("0"                             ),// String
	.MEMORY_OPTIMIZATION     ("true"                          ),// String
	.MEMORY_PRIMITIVE        ("auto"                          ),// String
	.MEMORY_SIZE             (35*512                          ),// DECIMAL
	.MESSAGE_CONTROL         (0                               ),// DECIMAL
	.READ_DATA_WIDTH_B       (35                              ),// DECIMAL
	.READ_LATENCY_B          (1                               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"                             ),// String
	.RST_MODE_A              ("SYNC"                          ),// String
	.RST_MODE_B              ("SYNC"                          ),// String
	.SIM_ASSERT_CHK          (1                               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0                               ),// DECIMAL
	.USE_MEM_INIT            (0                               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep"                 ),// String
	.WRITE_DATA_WIDTH_A      (35                              ),// DECIMAL
	.WRITE_MODE_B            ("no_change"                     )// String
)
xpm_memory_sdpram_L1_b(
	.doutb                   (rd_data_b                       ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_bn                      ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_bn                      ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk                          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk                          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_param[34:0]                   ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_param_vld[2]                  ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rd_en_bn                        ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0                            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0                            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0                            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp                          ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0                            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (i_param_vld[2]                  ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
											                    // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
											                    // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);

endmodule
