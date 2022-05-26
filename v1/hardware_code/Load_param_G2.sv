`timescale 1ns / 1ps

module Load_param_G2#(
	parameter							WIDTH_P    = 60  ,
	parameter							WIDTH_WE   = 16  ,
	parameter							WIDTH_W    = 18  ,
	parameter							WIDTH_A_M0 = 18  ,
	parameter							WIDTH_B_M0 = 34  ,
	parameter							WIDTH_A_M1 = 22  ,
	parameter							WIDTH_B_M1 = 33  ,
	parameter							WIDTH_A_M3 = 21  ,
	parameter							WIDTH_B_M3 = 34  ,
	parameter							WIDTH_W_DS = 20  ,
	parameter							WIDTH_A_DS = 14  ,
	parameter							WIDTH_B_DS = 33  ,
	parameter							WIDTH_A_C0 = 19  ,
	parameter							WIDTH_B_C0 = 34  ,
	parameter							WIDTH_A_C1 = 24  ,
	parameter							WIDTH_B_C1 = 33  ,
	parameter							WIDTH_A_C2 = 24  ,
	parameter							WIDTH_B_C2 = 34  ,
	parameter							WIDTH_A_C3 = 17  ,
	parameter							WIDTH_B_C3 = 34  ,
	parameter							QUANT_W    = 16  ,
	parameter							BATCH      = 4'd8,
	parameter							LEN        = 3  
)(
	input	wire						i_sclk         ,
	input	wire						i_rstp         ,
	
	input	wire[21:0]					i_param_vld    ,
	input	wire[WIDTH_P-1:0]			i_param        ,
	
	input	wire						i_ds_w_req     ,
	output	wire						o_ds_w_vld     ,
	output	wire[WIDTH_W_DS*BATCH-1:0]	o_ds_w         ,
	
	input	wire						i_c0_w_req     ,
	output	wire						o_c0_w_vld     ,
	output	wire[WIDTH_W*BATCH-1:0]		o_c0_w         ,
	output	wire[QUANT_W-1:0]			o_c0_we        ,
	
	input	wire						i_c1_w_req     ,
	output	wire						o_c1_w_vld     ,
	output	wire[WIDTH_W*BATCH-1:0]		o_c1_w         ,
	output	wire[QUANT_W-1:0]			o_c1_we        ,
	
	input	wire						i_c2_w_req     ,
	output	wire						o_c2_w_vld     ,
	output	wire[WIDTH_W*BATCH-1:0]		o_c2_w         ,
	output	wire[QUANT_W-1:0]			o_c2_we        ,
	
	input	wire						i_c3_w_req     ,
	output	wire						o_c3_w_vld     ,
	output	wire[WIDTH_W*BATCH-1:0]		o_c3_w         ,
	output	wire[QUANT_W-1:0]			o_c3_we        ,
	
	input	wire						i_bn_ds_req    ,
	output	wire[WIDTH_A_DS-1:0]		o_ds_bn_a      ,
	output	wire[WIDTH_B_DS-1:0]		o_ds_bn_b      ,
	
	input	wire						i_bn_m0_req    ,
	output	wire[WIDTH_A_M0-1:0]		o_m0_bn_a      ,
	output	wire[WIDTH_B_M0-1:0]		o_m0_bn_b      ,
	
	input	wire						i_bn_m1_req    ,
	output	wire[WIDTH_A_M1-1:0]		o_m1_bn_a      ,
	output	wire[WIDTH_B_M1-1:0]		o_m1_bn_b      ,
	
	input	wire						i_bn_m3_req    ,
	output	wire[WIDTH_A_M3-1:0]		o_m3_bn_a      ,
	output	wire[WIDTH_B_M3-1:0]		o_m3_bn_b      ,
	
	input	wire						i_bn_c0_req    ,
	output	wire[WIDTH_A_C0-1:0]		o_c0_bn_a      ,
	output	wire[WIDTH_B_C0-1:0]		o_c0_bn_b      ,
	
	input	wire						i_bn_c1_req    ,
	output	wire[WIDTH_A_C1-1:0]		o_c1_bn_a      ,
	output	wire[WIDTH_B_C1-1:0]		o_c1_bn_b      ,
	
	input	wire						i_bn_c2_req    ,
	output	wire[WIDTH_A_C2-1:0]		o_c2_bn_a      ,
	output	wire[WIDTH_B_C2-1:0]		o_c2_bn_b      ,
	
	input	wire						i_bn_c3_req    ,
	output	wire[WIDTH_A_C3-1:0]		o_c3_bn_a      ,
	output	wire[WIDTH_B_C3-1:0]		o_c3_bn_b      
);

//----------------------------------------------//
//					PARAM						//
//----------------------------------------------//
parameter	CHANNEL    = 256;
parameter	SIZE_W1    = CHANNEL/BATCH;
parameter	SIZE_W2    = CHANNEL*SIZE_W1/2;
parameter	SIZE_W3    = CHANNEL*SIZE_W1;
parameter	MEM_SIZE_0 = WIDTH_W_DS*CHANNEL*CHANNEL/2;
parameter	MEM_SIZE_1 = WIDTH_W*CHANNEL*CHANNEL/2;
parameter	MEM_SIZE_2 = WIDTH_W*CHANNEL*CHANNEL;
//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
reg [7:0]					wr_addr_bn           ;
reg [15:0]					wr_addr_w            ;
reg 						wr_done              ;

reg [5:0]					weighte_vld_dly      ;
reg [QUANT_W-1:0]			weighte_c0           ;
reg [QUANT_W-1:0]			weighte_c1           ;
reg [QUANT_W-1:0]			weighte_c2           ;
reg [QUANT_W-1:0]			weighte_c3           ;

reg [7:0]					rd_en_bn             ;
reg [7:0]					rd_addr_bn[7:0]      ;
wire[34:0]					rd_data_a[7:0]       ;
wire[34:0]					rd_data_b[7:0]       ;

wire[4:0]					w_req                ;
reg [4:0]					rd_en_w              ;
reg [12:0]					rd_addr_w[4:0]       ;
wire[WIDTH_W_DS*BATCH-1:0]	rd_data_w[4:0]       ;
reg [4:0]					rd_data_vld_w        ;

//----------------------------------------------//
//					CODING						//
//----------------------------------------------//
assign o_ds_w_vld = rd_data_vld_w[0];
assign o_ds_w     = rd_data_w[0]    ;
assign o_c0_w_vld = rd_data_vld_w[1];
assign o_c0_w     = rd_data_w[1]    ;
assign o_c0_we    = weighte_c0      ;
assign o_c1_w_vld = rd_data_vld_w[2];
assign o_c1_w     = rd_data_w[2]    ;
assign o_c1_we    = weighte_c1      ;
assign o_c2_w_vld = rd_data_vld_w[3];
assign o_c2_w     = rd_data_w[3]    ;
assign o_c2_we    = weighte_c2      ;
assign o_c3_w_vld = rd_data_vld_w[4];
assign o_c3_w     = rd_data_w[4]    ;
assign o_c3_we    = weighte_c3      ;
assign o_ds_bn_a  = rd_data_a[0]    ;
assign o_ds_bn_b  = rd_data_b[0]    ;
assign o_m0_bn_a  = rd_data_a[1]    ;
assign o_m0_bn_b  = rd_data_b[1]    ;
assign o_m1_bn_a  = rd_data_a[2]    ;
assign o_m1_bn_b  = rd_data_b[2]    ;
assign o_m3_bn_a  = rd_data_a[3]    ;
assign o_m3_bn_b  = rd_data_b[3]    ;
assign o_c0_bn_a  = rd_data_a[4]    ;
assign o_c0_bn_b  = rd_data_b[4]    ;
assign o_c1_bn_a  = rd_data_a[5]    ;
assign o_c1_bn_b  = rd_data_b[5]    ;
assign o_c2_bn_a  = rd_data_a[6]    ;
assign o_c2_bn_b  = rd_data_b[6]    ;
assign o_c3_bn_a  = rd_data_a[7]    ;
assign o_c3_bn_b  = rd_data_b[7]    ;

assign w_req = {i_c3_w_req,i_c2_w_req,i_c1_w_req,i_c0_w_req,i_ds_w_req};

always @(posedge i_sclk)
begin
	rd_en_bn <= {i_bn_c3_req,i_bn_c2_req,i_bn_c1_req,i_bn_c0_req,i_bn_m3_req,i_bn_m1_req,i_bn_m0_req,i_bn_ds_req};
	
	if(i_rstp)											wr_addr_bn <= 'd0;
	else if(|i_param_vld[20:5])
	begin
		if(wr_addr_bn==CHANNEL-1)						wr_addr_bn <= 'd0;
		else											wr_addr_bn <= wr_addr_bn + 'd1;
	end

	if(i_rstp)											wr_addr_w <= 'd0;
	else if(|i_param_vld[1:0])
	begin
		if(wr_addr_w==CHANNEL*CHANNEL/2-1)				wr_addr_w <= 'd0;
		else											wr_addr_w <= wr_addr_w + 'd1;
	end
	else if(|i_param_vld[4:2])
	begin
		if(wr_addr_w==CHANNEL*CHANNEL-1)				wr_addr_w <= 'd0;
		else											wr_addr_w <= wr_addr_w + 'd1;
	end

	if(i_param_vld[4]&&wr_addr_w==CHANNEL*CHANNEL-1)	wr_done <= 'd1;
	else												wr_done <= 'd0;
end

always @(posedge i_sclk)
begin
	weighte_vld_dly <= {weighte_vld_dly[4:0],i_param_vld[21]};
	
	if(i_rstp)
	begin
		weighte_c0 <= 'd0;
		weighte_c1 <= 'd0;
		weighte_c2 <= 'd0;
		weighte_c3 <= 'd0;
	end
	else
	begin
		if(weighte_vld_dly[3]&&!weighte_vld_dly[4])
		begin
			weighte_c0 <= i_param[QUANT_W-1:0];
			weighte_c1 <= i_param[QUANT_W*2-1:QUANT_W];
		end
		
		if(weighte_vld_dly[4]&&!weighte_vld_dly[5])
		begin
			weighte_c2 <= i_param[QUANT_W-1:0];
			weighte_c3 <= i_param[QUANT_W*2-1:QUANT_W];
		end
	end
end

genvar b;
generate
	for(b=0;b<8;b=b+1)
	begin
		always@(posedge i_sclk)
		begin
			if(i_rstp)							rd_addr_bn[b] <= 'd0;
			else if(rd_en_bn[b])
			begin
				if(rd_addr_bn[b]==CHANNEL-1)	rd_addr_bn[b] <= 'd0;
				else							rd_addr_bn[b] <= rd_addr_bn[b] + 'd1;
			end
		end
	end
endgenerate

genvar w;
generate
	for(w=0;w<5;w=w+1)
	begin
		always@(posedge i_sclk)
		begin
			rd_data_vld_w[w] <= rd_en_w[w];
			
			if(i_rstp||rd_addr_w[w][4:0]==SIZE_W1-1)	rd_en_w[w] <= 'd0;
			else if(wr_done||w_req[w])					rd_en_w[w] <= 'd1;
			
			if(i_rstp)									rd_addr_w[w] <= 'd0;
			else if(w==0||w==1)
			begin
				if(rd_addr_w[w]==SIZE_W2-1)				rd_addr_w[w] <= 'd0;
				else if(rd_en_w[w])						rd_addr_w[w] <= rd_addr_w[w] + 'd1;
			end
			else
			begin
				if(rd_addr_w[w]==SIZE_W3-1)				rd_addr_w[w] <= 'd0;
				else if(rd_en_w[w])						rd_addr_w[w] <= rd_addr_w[w] + 'd1;
			end
		end
	end
endgenerate

xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (8               ),// DECIMAL
	.ADDR_WIDTH_B            (8               ),// DECIMAL
	.AUTO_SLEEP_TIME         (0               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (35              ),// DECIMAL
	.CASCADE_HEIGHT          (0               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"  ),// String
	.ECC_MODE                ("no_ecc"        ),// String
	.MEMORY_INIT_FILE        ("none"          ),// String
	.MEMORY_INIT_PARAM       ("0"             ),// String
	.MEMORY_OPTIMIZATION     ("true"          ),// String
	.MEMORY_PRIMITIVE        ("auto"          ),// String
	.MEMORY_SIZE             (35*256          ),// DECIMAL
	.MESSAGE_CONTROL         (0               ),// DECIMAL
	.READ_DATA_WIDTH_B       (35              ),// DECIMAL
	.READ_LATENCY_B          (1               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"             ),// String
	.RST_MODE_A              ("SYNC"          ),// String
	.RST_MODE_B              ("SYNC"          ),// String
	.SIM_ASSERT_CHK          (1               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0               ),// DECIMAL
	.USE_MEM_INIT            (0               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep" ),// String
	.WRITE_DATA_WIDTH_A      (35              ),// DECIMAL
	.WRITE_MODE_B            ("no_change"     )// String
)
xpm_memory_sdpram_g1_ds_a(
	.doutb                   (rd_data_a[0]    ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_bn      ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_bn[0]   ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_param[34:0]   ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_param_vld[5]  ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rd_en_bn[0]     ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp          ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (i_param_vld[5]  ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
                                                // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
                                                // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);
xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (8               ),// DECIMAL
	.ADDR_WIDTH_B            (8               ),// DECIMAL
	.AUTO_SLEEP_TIME         (0               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (35              ),// DECIMAL
	.CASCADE_HEIGHT          (0               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"  ),// String
	.ECC_MODE                ("no_ecc"        ),// String
	.MEMORY_INIT_FILE        ("none"          ),// String
	.MEMORY_INIT_PARAM       ("0"             ),// String
	.MEMORY_OPTIMIZATION     ("true"          ),// String
	.MEMORY_PRIMITIVE        ("auto"          ),// String
	.MEMORY_SIZE             (35*256          ),// DECIMAL
	.MESSAGE_CONTROL         (0               ),// DECIMAL
	.READ_DATA_WIDTH_B       (35              ),// DECIMAL
	.READ_LATENCY_B          (1               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"             ),// String
	.RST_MODE_A              ("SYNC"          ),// String
	.RST_MODE_B              ("SYNC"          ),// String
	.SIM_ASSERT_CHK          (1               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0               ),// DECIMAL
	.USE_MEM_INIT            (0               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep" ),// String
	.WRITE_DATA_WIDTH_A      (35              ),// DECIMAL
	.WRITE_MODE_B            ("no_change"     )// String
)
xpm_memory_sdpram_g2_ops0_a(
	.doutb                   (rd_data_a[1]    ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_bn      ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_bn[1]   ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_param[34:0]   ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_param_vld[6]  ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rd_en_bn[1]     ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp          ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (i_param_vld[6]  ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
                                                // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
                                                // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);
xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (8               ),// DECIMAL
	.ADDR_WIDTH_B            (8               ),// DECIMAL
	.AUTO_SLEEP_TIME         (0               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (35              ),// DECIMAL
	.CASCADE_HEIGHT          (0               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"  ),// String
	.ECC_MODE                ("no_ecc"        ),// String
	.MEMORY_INIT_FILE        ("none"          ),// String
	.MEMORY_INIT_PARAM       ("0"             ),// String
	.MEMORY_OPTIMIZATION     ("true"          ),// String
	.MEMORY_PRIMITIVE        ("auto"          ),// String
	.MEMORY_SIZE             (35*256          ),// DECIMAL
	.MESSAGE_CONTROL         (0               ),// DECIMAL
	.READ_DATA_WIDTH_B       (35              ),// DECIMAL
	.READ_LATENCY_B          (1               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"             ),// String
	.RST_MODE_A              ("SYNC"          ),// String
	.RST_MODE_B              ("SYNC"          ),// String
	.SIM_ASSERT_CHK          (1               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0               ),// DECIMAL
	.USE_MEM_INIT            (0               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep" ),// String
	.WRITE_DATA_WIDTH_A      (35              ),// DECIMAL
	.WRITE_MODE_B            ("no_change"     )// String
)
xpm_memory_sdpram_g2_ops1_a(
	.doutb                   (rd_data_a[2]    ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_bn      ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_bn[2]   ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_param[34:0]   ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_param_vld[7]  ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rd_en_bn[2]     ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp          ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (i_param_vld[7]  ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
                                                // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
                                                // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);
xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (8               ),// DECIMAL
	.ADDR_WIDTH_B            (8               ),// DECIMAL
	.AUTO_SLEEP_TIME         (0               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (35              ),// DECIMAL
	.CASCADE_HEIGHT          (0               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"  ),// String
	.ECC_MODE                ("no_ecc"        ),// String
	.MEMORY_INIT_FILE        ("none"          ),// String
	.MEMORY_INIT_PARAM       ("0"             ),// String
	.MEMORY_OPTIMIZATION     ("true"          ),// String
	.MEMORY_PRIMITIVE        ("auto"          ),// String
	.MEMORY_SIZE             (35*256          ),// DECIMAL
	.MESSAGE_CONTROL         (0               ),// DECIMAL
	.READ_DATA_WIDTH_B       (35              ),// DECIMAL
	.READ_LATENCY_B          (1               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"             ),// String
	.RST_MODE_A              ("SYNC"          ),// String
	.RST_MODE_B              ("SYNC"          ),// String
	.SIM_ASSERT_CHK          (1               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0               ),// DECIMAL
	.USE_MEM_INIT            (0               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep" ),// String
	.WRITE_DATA_WIDTH_A      (35              ),// DECIMAL
	.WRITE_MODE_B            ("no_change"     )// String
)
xpm_memory_sdpram_g2_ops3_a(
	.doutb                   (rd_data_a[3]    ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_bn      ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_bn[3]   ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_param[34:0]   ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_param_vld[8]  ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rd_en_bn[3]     ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp          ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (i_param_vld[8]  ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
                                                // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
                                                // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);
xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (8               ),// DECIMAL
	.ADDR_WIDTH_B            (8               ),// DECIMAL
	.AUTO_SLEEP_TIME         (0               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (35              ),// DECIMAL
	.CASCADE_HEIGHT          (0               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"  ),// String
	.ECC_MODE                ("no_ecc"        ),// String
	.MEMORY_INIT_FILE        ("none"          ),// String
	.MEMORY_INIT_PARAM       ("0"             ),// String
	.MEMORY_OPTIMIZATION     ("true"          ),// String
	.MEMORY_PRIMITIVE        ("auto"          ),// String
	.MEMORY_SIZE             (35*256          ),// DECIMAL
	.MESSAGE_CONTROL         (0               ),// DECIMAL
	.READ_DATA_WIDTH_B       (35              ),// DECIMAL
	.READ_LATENCY_B          (1               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"             ),// String
	.RST_MODE_A              ("SYNC"          ),// String
	.RST_MODE_B              ("SYNC"          ),// String
	.SIM_ASSERT_CHK          (1               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0               ),// DECIMAL
	.USE_MEM_INIT            (0               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep" ),// String
	.WRITE_DATA_WIDTH_A      (35              ),// DECIMAL
	.WRITE_MODE_B            ("no_change"     )// String
)
xpm_memory_sdpram_g2_c0_a(
	.doutb                   (rd_data_a[4]    ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_bn      ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_bn[4]   ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_param[34:0]   ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_param_vld[9]  ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rd_en_bn[4]     ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp          ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (i_param_vld[9]  ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
                                                // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
                                                // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);
xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (8               ),// DECIMAL
	.ADDR_WIDTH_B            (8               ),// DECIMAL
	.AUTO_SLEEP_TIME         (0               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (35              ),// DECIMAL
	.CASCADE_HEIGHT          (0               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"  ),// String
	.ECC_MODE                ("no_ecc"        ),// String
	.MEMORY_INIT_FILE        ("none"          ),// String
	.MEMORY_INIT_PARAM       ("0"             ),// String
	.MEMORY_OPTIMIZATION     ("true"          ),// String
	.MEMORY_PRIMITIVE        ("auto"          ),// String
	.MEMORY_SIZE             (35*256          ),// DECIMAL
	.MESSAGE_CONTROL         (0               ),// DECIMAL
	.READ_DATA_WIDTH_B       (35              ),// DECIMAL
	.READ_LATENCY_B          (1               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"             ),// String
	.RST_MODE_A              ("SYNC"          ),// String
	.RST_MODE_B              ("SYNC"          ),// String
	.SIM_ASSERT_CHK          (1               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0               ),// DECIMAL
	.USE_MEM_INIT            (0               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep" ),// String
	.WRITE_DATA_WIDTH_A      (35              ),// DECIMAL
	.WRITE_MODE_B            ("no_change"     )// String
)
xpm_memory_sdpram_g2_c1_a(
	.doutb                   (rd_data_a[5]    ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_bn      ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_bn[5]   ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_param[34:0]   ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_param_vld[10] ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rd_en_bn[5]     ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp          ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (i_param_vld[10] ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
                                                // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
                                                // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);
xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (8               ),// DECIMAL
	.ADDR_WIDTH_B            (8               ),// DECIMAL
	.AUTO_SLEEP_TIME         (0               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (35              ),// DECIMAL
	.CASCADE_HEIGHT          (0               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"  ),// String
	.ECC_MODE                ("no_ecc"        ),// String
	.MEMORY_INIT_FILE        ("none"          ),// String
	.MEMORY_INIT_PARAM       ("0"             ),// String
	.MEMORY_OPTIMIZATION     ("true"          ),// String
	.MEMORY_PRIMITIVE        ("auto"          ),// String
	.MEMORY_SIZE             (35*256          ),// DECIMAL
	.MESSAGE_CONTROL         (0               ),// DECIMAL
	.READ_DATA_WIDTH_B       (35              ),// DECIMAL
	.READ_LATENCY_B          (1               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"             ),// String
	.RST_MODE_A              ("SYNC"          ),// String
	.RST_MODE_B              ("SYNC"          ),// String
	.SIM_ASSERT_CHK          (1               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0               ),// DECIMAL
	.USE_MEM_INIT            (0               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep" ),// String
	.WRITE_DATA_WIDTH_A      (35              ),// DECIMAL
	.WRITE_MODE_B            ("no_change"     )// String
)
xpm_memory_sdpram_g2_c2_a(
	.doutb                   (rd_data_a[6]    ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_bn      ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_bn[6]   ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_param[34:0]   ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_param_vld[11] ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rd_en_bn[6]     ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp          ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (i_param_vld[11] ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
                                                // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
                                                // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);
xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (8               ),// DECIMAL
	.ADDR_WIDTH_B            (8               ),// DECIMAL
	.AUTO_SLEEP_TIME         (0               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (35              ),// DECIMAL
	.CASCADE_HEIGHT          (0               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"  ),// String
	.ECC_MODE                ("no_ecc"        ),// String
	.MEMORY_INIT_FILE        ("none"          ),// String
	.MEMORY_INIT_PARAM       ("0"             ),// String
	.MEMORY_OPTIMIZATION     ("true"          ),// String
	.MEMORY_PRIMITIVE        ("auto"          ),// String
	.MEMORY_SIZE             (35*256          ),// DECIMAL
	.MESSAGE_CONTROL         (0               ),// DECIMAL
	.READ_DATA_WIDTH_B       (35              ),// DECIMAL
	.READ_LATENCY_B          (1               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"             ),// String
	.RST_MODE_A              ("SYNC"          ),// String
	.RST_MODE_B              ("SYNC"          ),// String
	.SIM_ASSERT_CHK          (1               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0               ),// DECIMAL
	.USE_MEM_INIT            (0               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep" ),// String
	.WRITE_DATA_WIDTH_A      (35              ),// DECIMAL
	.WRITE_MODE_B            ("no_change"     )// String
)
xpm_memory_sdpram_g2_c3_a(
	.doutb                   (rd_data_a[7]    ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_bn      ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_bn[7]   ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_param[34:0]   ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_param_vld[12] ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rd_en_bn[7]     ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp          ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (i_param_vld[12] ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
                                                // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
                                                // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);
xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (8               ),// DECIMAL
	.ADDR_WIDTH_B            (8               ),// DECIMAL
	.AUTO_SLEEP_TIME         (0               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (35              ),// DECIMAL
	.CASCADE_HEIGHT          (0               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"  ),// String
	.ECC_MODE                ("no_ecc"        ),// String
	.MEMORY_INIT_FILE        ("none"          ),// String
	.MEMORY_INIT_PARAM       ("0"             ),// String
	.MEMORY_OPTIMIZATION     ("true"          ),// String
	.MEMORY_PRIMITIVE        ("auto"          ),// String
	.MEMORY_SIZE             (35*256          ),// DECIMAL
	.MESSAGE_CONTROL         (0               ),// DECIMAL
	.READ_DATA_WIDTH_B       (35              ),// DECIMAL
	.READ_LATENCY_B          (1               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"             ),// String
	.RST_MODE_A              ("SYNC"          ),// String
	.RST_MODE_B              ("SYNC"          ),// String
	.SIM_ASSERT_CHK          (1               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0               ),// DECIMAL
	.USE_MEM_INIT            (0               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep" ),// String
	.WRITE_DATA_WIDTH_A      (35              ),// DECIMAL
	.WRITE_MODE_B            ("no_change"     )// String
)
xpm_memory_sdpram_g2_ds_b(
	.doutb                   (rd_data_b[0]    ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_bn      ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_bn[0]   ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_param[34:0]   ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_param_vld[13] ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rd_en_bn[0]     ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp          ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (i_param_vld[13] ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
                                                // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
                                                // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);
xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (8               ),// DECIMAL
	.ADDR_WIDTH_B            (8               ),// DECIMAL
	.AUTO_SLEEP_TIME         (0               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (35              ),// DECIMAL
	.CASCADE_HEIGHT          (0               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"  ),// String
	.ECC_MODE                ("no_ecc"        ),// String
	.MEMORY_INIT_FILE        ("none"          ),// String
	.MEMORY_INIT_PARAM       ("0"             ),// String
	.MEMORY_OPTIMIZATION     ("true"          ),// String
	.MEMORY_PRIMITIVE        ("auto"          ),// String
	.MEMORY_SIZE             (35*256          ),// DECIMAL
	.MESSAGE_CONTROL         (0               ),// DECIMAL
	.READ_DATA_WIDTH_B       (35              ),// DECIMAL
	.READ_LATENCY_B          (1               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"             ),// String
	.RST_MODE_A              ("SYNC"          ),// String
	.RST_MODE_B              ("SYNC"          ),// String
	.SIM_ASSERT_CHK          (1               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0               ),// DECIMAL
	.USE_MEM_INIT            (0               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep" ),// String
	.WRITE_DATA_WIDTH_A      (35              ),// DECIMAL
	.WRITE_MODE_B            ("no_change"     )// String
)
xpm_memory_sdpram_g2_ops0_b(
	.doutb                   (rd_data_b[1]    ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_bn      ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_bn[1]   ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_param[34:0]   ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_param_vld[14] ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rd_en_bn[1]     ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp          ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (i_param_vld[14] ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
                                                // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
                                                // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);
xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (8               ),// DECIMAL
	.ADDR_WIDTH_B            (8               ),// DECIMAL
	.AUTO_SLEEP_TIME         (0               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (35              ),// DECIMAL
	.CASCADE_HEIGHT          (0               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"  ),// String
	.ECC_MODE                ("no_ecc"        ),// String
	.MEMORY_INIT_FILE        ("none"          ),// String
	.MEMORY_INIT_PARAM       ("0"             ),// String
	.MEMORY_OPTIMIZATION     ("true"          ),// String
	.MEMORY_PRIMITIVE        ("auto"          ),// String
	.MEMORY_SIZE             (35*256          ),// DECIMAL
	.MESSAGE_CONTROL         (0               ),// DECIMAL
	.READ_DATA_WIDTH_B       (35              ),// DECIMAL
	.READ_LATENCY_B          (1               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"             ),// String
	.RST_MODE_A              ("SYNC"          ),// String
	.RST_MODE_B              ("SYNC"          ),// String
	.SIM_ASSERT_CHK          (1               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0               ),// DECIMAL
	.USE_MEM_INIT            (0               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep" ),// String
	.WRITE_DATA_WIDTH_A      (35              ),// DECIMAL
	.WRITE_MODE_B            ("no_change"     )// String
)
xpm_memory_sdpram_g2_ops1_b(
	.doutb                   (rd_data_b[2]    ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_bn      ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_bn[2]   ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_param[34:0]   ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_param_vld[15] ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rd_en_bn[2]     ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp          ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (i_param_vld[15] ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
                                                // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
                                                // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);
xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (8               ),// DECIMAL
	.ADDR_WIDTH_B            (8               ),// DECIMAL
	.AUTO_SLEEP_TIME         (0               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (35              ),// DECIMAL
	.CASCADE_HEIGHT          (0               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"  ),// String
	.ECC_MODE                ("no_ecc"        ),// String
	.MEMORY_INIT_FILE        ("none"          ),// String
	.MEMORY_INIT_PARAM       ("0"             ),// String
	.MEMORY_OPTIMIZATION     ("true"          ),// String
	.MEMORY_PRIMITIVE        ("auto"          ),// String
	.MEMORY_SIZE             (35*256          ),// DECIMAL
	.MESSAGE_CONTROL         (0               ),// DECIMAL
	.READ_DATA_WIDTH_B       (35              ),// DECIMAL
	.READ_LATENCY_B          (1               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"             ),// String
	.RST_MODE_A              ("SYNC"          ),// String
	.RST_MODE_B              ("SYNC"          ),// String
	.SIM_ASSERT_CHK          (1               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0               ),// DECIMAL
	.USE_MEM_INIT            (0               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep" ),// String
	.WRITE_DATA_WIDTH_A      (35              ),// DECIMAL
	.WRITE_MODE_B            ("no_change"     )// String
)
xpm_memory_sdpram_g2_ops3_b(
	.doutb                   (rd_data_b[3]    ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_bn      ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_bn[3]   ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_param[34:0]   ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_param_vld[16] ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rd_en_bn[3]     ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp          ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (i_param_vld[16] ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
                                                // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
                                                // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);
xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (8               ),// DECIMAL
	.ADDR_WIDTH_B            (8               ),// DECIMAL
	.AUTO_SLEEP_TIME         (0               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (35              ),// DECIMAL
	.CASCADE_HEIGHT          (0               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"  ),// String
	.ECC_MODE                ("no_ecc"        ),// String
	.MEMORY_INIT_FILE        ("none"          ),// String
	.MEMORY_INIT_PARAM       ("0"             ),// String
	.MEMORY_OPTIMIZATION     ("true"          ),// String
	.MEMORY_PRIMITIVE        ("auto"          ),// String
	.MEMORY_SIZE             (35*256          ),// DECIMAL
	.MESSAGE_CONTROL         (0               ),// DECIMAL
	.READ_DATA_WIDTH_B       (35              ),// DECIMAL
	.READ_LATENCY_B          (1               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"             ),// String
	.RST_MODE_A              ("SYNC"          ),// String
	.RST_MODE_B              ("SYNC"          ),// String
	.SIM_ASSERT_CHK          (1               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0               ),// DECIMAL
	.USE_MEM_INIT            (0               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep" ),// String
	.WRITE_DATA_WIDTH_A      (35              ),// DECIMAL
	.WRITE_MODE_B            ("no_change"     )// String
)
xpm_memory_sdpram_g2_c0_b(
	.doutb                   (rd_data_b[4]    ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_bn      ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_bn[4]   ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_param[34:0]   ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_param_vld[17] ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rd_en_bn[4]     ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp          ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (i_param_vld[17] ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
                                                // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
                                                // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);
xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (8               ),// DECIMAL
	.ADDR_WIDTH_B            (8               ),// DECIMAL
	.AUTO_SLEEP_TIME         (0               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (35              ),// DECIMAL
	.CASCADE_HEIGHT          (0               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"  ),// String
	.ECC_MODE                ("no_ecc"        ),// String
	.MEMORY_INIT_FILE        ("none"          ),// String
	.MEMORY_INIT_PARAM       ("0"             ),// String
	.MEMORY_OPTIMIZATION     ("true"          ),// String
	.MEMORY_PRIMITIVE        ("auto"          ),// String
	.MEMORY_SIZE             (35*256          ),// DECIMAL
	.MESSAGE_CONTROL         (0               ),// DECIMAL
	.READ_DATA_WIDTH_B       (35              ),// DECIMAL
	.READ_LATENCY_B          (1               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"             ),// String
	.RST_MODE_A              ("SYNC"          ),// String
	.RST_MODE_B              ("SYNC"          ),// String
	.SIM_ASSERT_CHK          (1               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0               ),// DECIMAL
	.USE_MEM_INIT            (0               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep" ),// String
	.WRITE_DATA_WIDTH_A      (35              ),// DECIMAL
	.WRITE_MODE_B            ("no_change"     )// String
)
xpm_memory_sdpram_g2_c1_b(
	.doutb                   (rd_data_b[5]    ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_bn      ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_bn[5]   ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_param[34:0]   ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_param_vld[18] ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rd_en_bn[5]     ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp          ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (i_param_vld[18] ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
                                                // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
                                                // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);
xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (8               ),// DECIMAL
	.ADDR_WIDTH_B            (8               ),// DECIMAL
	.AUTO_SLEEP_TIME         (0               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (35              ),// DECIMAL
	.CASCADE_HEIGHT          (0               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"  ),// String
	.ECC_MODE                ("no_ecc"        ),// String
	.MEMORY_INIT_FILE        ("none"          ),// String
	.MEMORY_INIT_PARAM       ("0"             ),// String
	.MEMORY_OPTIMIZATION     ("true"          ),// String
	.MEMORY_PRIMITIVE        ("auto"          ),// String
	.MEMORY_SIZE             (35*256          ),// DECIMAL
	.MESSAGE_CONTROL         (0               ),// DECIMAL
	.READ_DATA_WIDTH_B       (35              ),// DECIMAL
	.READ_LATENCY_B          (1               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"             ),// String
	.RST_MODE_A              ("SYNC"          ),// String
	.RST_MODE_B              ("SYNC"          ),// String
	.SIM_ASSERT_CHK          (1               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0               ),// DECIMAL
	.USE_MEM_INIT            (0               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep" ),// String
	.WRITE_DATA_WIDTH_A      (35              ),// DECIMAL
	.WRITE_MODE_B            ("no_change"     )// String
)
xpm_memory_sdpram_g2_c2_b(
	.doutb                   (rd_data_b[6]    ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_bn      ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_bn[6]   ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_param[34:0]   ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_param_vld[19] ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rd_en_bn[6]     ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp          ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (i_param_vld[19] ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
                                                // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
                                                // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);
xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (8               ),// DECIMAL
	.ADDR_WIDTH_B            (8               ),// DECIMAL
	.AUTO_SLEEP_TIME         (0               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (35              ),// DECIMAL
	.CASCADE_HEIGHT          (0               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"  ),// String
	.ECC_MODE                ("no_ecc"        ),// String
	.MEMORY_INIT_FILE        ("none"          ),// String
	.MEMORY_INIT_PARAM       ("0"             ),// String
	.MEMORY_OPTIMIZATION     ("true"          ),// String
	.MEMORY_PRIMITIVE        ("auto"          ),// String
	.MEMORY_SIZE             (35*256          ),// DECIMAL
	.MESSAGE_CONTROL         (0               ),// DECIMAL
	.READ_DATA_WIDTH_B       (35              ),// DECIMAL
	.READ_LATENCY_B          (1               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"             ),// String
	.RST_MODE_A              ("SYNC"          ),// String
	.RST_MODE_B              ("SYNC"          ),// String
	.SIM_ASSERT_CHK          (1               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0               ),// DECIMAL
	.USE_MEM_INIT            (0               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep" ),// String
	.WRITE_DATA_WIDTH_A      (35              ),// DECIMAL
	.WRITE_MODE_B            ("no_change"     )// String
)
xpm_memory_sdpram_g2_c3_b(
	.doutb                   (rd_data_b[7]    ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_bn      ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_bn[7]   ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_param[34:0]   ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_param_vld[20] ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rd_en_bn[7]     ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp          ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (i_param_vld[20] ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
                                                // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
                                                // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);
xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (15                                 ),// DECIMAL
	.ADDR_WIDTH_B            (12                                 ),// DECIMAL
	.AUTO_SLEEP_TIME         (0                                  ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (WIDTH_W_DS                         ),// DECIMAL
	.CASCADE_HEIGHT          (0                                  ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"                     ),// String
	.ECC_MODE                ("no_ecc"                           ),// String
	.MEMORY_INIT_FILE        ("none"                             ),// String
	.MEMORY_INIT_PARAM       ("0"                                ),// String
	.MEMORY_OPTIMIZATION     ("true"                             ),// String
	.MEMORY_PRIMITIVE        ("auto"                             ),// String
	.MEMORY_SIZE             (MEM_SIZE_0                         ),// DECIMAL
	.MESSAGE_CONTROL         (0                                  ),// DECIMAL
	.READ_DATA_WIDTH_B       (WIDTH_W_DS*BATCH                   ),// DECIMAL
	.READ_LATENCY_B          (1                                  ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"                                ),// String
	.RST_MODE_A              ("SYNC"                             ),// String
	.RST_MODE_B              ("SYNC"                             ),// String
	.SIM_ASSERT_CHK          (1                                  ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0                                  ),// DECIMAL
	.USE_MEM_INIT            (0                                  ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep"                    ),// String
	.WRITE_DATA_WIDTH_A      (WIDTH_W_DS                         ),// DECIMAL
	.WRITE_MODE_B            ("no_change"                        )// String
)
xpm_memory_sdpram_g2ds(
	.doutb                   (rd_data_w[0][WIDTH_W_DS*BATCH-1:0] ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_w[14:0]                    ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_w[0][11:0]                 ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk                             ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk                             ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_param[WIDTH_W_DS-1:0]            ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_param_vld[0]                     ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rd_en_w[0]                         ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0                               ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0                               ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0                               ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp                             ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0                               ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (i_param_vld[0]                     ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
											                       // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
											                       // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);

xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (15                              ),// DECIMAL
	.ADDR_WIDTH_B            (12                              ),// DECIMAL
	.AUTO_SLEEP_TIME         (0                               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (WIDTH_W                         ),// DECIMAL
	.CASCADE_HEIGHT          (0                               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"                  ),// String
	.ECC_MODE                ("no_ecc"                        ),// String
	.MEMORY_INIT_FILE        ("none"                          ),// String
	.MEMORY_INIT_PARAM       ("0"                             ),// String
	.MEMORY_OPTIMIZATION     ("true"                          ),// String
	.MEMORY_PRIMITIVE        ("auto"                          ),// String
	.MEMORY_SIZE             (MEM_SIZE_1                      ),// DECIMAL
	.MESSAGE_CONTROL         (0                               ),// DECIMAL
	.READ_DATA_WIDTH_B       (WIDTH_W*BATCH                   ),// DECIMAL
	.READ_LATENCY_B          (1                               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"                             ),// String
	.RST_MODE_A              ("SYNC"                          ),// String
	.RST_MODE_B              ("SYNC"                          ),// String
	.SIM_ASSERT_CHK          (1                               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0                               ),// DECIMAL
	.USE_MEM_INIT            (0                               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep"                 ),// String
	.WRITE_DATA_WIDTH_A      (WIDTH_W                         ),// DECIMAL
	.WRITE_MODE_B            ("no_change"                     )// String
)
xpm_memory_sdpram_g1w0(
	.doutb                   (rd_data_w[1][WIDTH_W*BATCH-1:0] ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_w[14:0]                 ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_w[1][11:0]              ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk                          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk                          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_param[WIDTH_W-1:0]            ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_param_vld[1]                  ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rd_en_w[1]                      ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
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
	.ADDR_WIDTH_A            (16                              ),// DECIMAL
	.ADDR_WIDTH_B            (13                              ),// DECIMAL
	.AUTO_SLEEP_TIME         (0                               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (WIDTH_W                         ),// DECIMAL
	.CASCADE_HEIGHT          (0                               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"                  ),// String
	.ECC_MODE                ("no_ecc"                        ),// String
	.MEMORY_INIT_FILE        ("none"                          ),// String
	.MEMORY_INIT_PARAM       ("0"                             ),// String
	.MEMORY_OPTIMIZATION     ("true"                          ),// String
	.MEMORY_PRIMITIVE        ("auto"                          ),// String
	.MEMORY_SIZE             (MEM_SIZE_2                      ),// DECIMAL
	.MESSAGE_CONTROL         (0                               ),// DECIMAL
	.READ_DATA_WIDTH_B       (WIDTH_W*BATCH                   ),// DECIMAL
	.READ_LATENCY_B          (1                               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"                             ),// String
	.RST_MODE_A              ("SYNC"                          ),// String
	.RST_MODE_B              ("SYNC"                          ),// String
	.SIM_ASSERT_CHK          (1                               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0                               ),// DECIMAL
	.USE_MEM_INIT            (0                               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep"                 ),// String
	.WRITE_DATA_WIDTH_A      (WIDTH_W                         ),// DECIMAL
	.WRITE_MODE_B            ("no_change"                     )// String
)
xpm_memory_sdpram_g1w1(
	.doutb                   (rd_data_w[2][WIDTH_W*BATCH-1:0] ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_w                       ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_w[2]                    ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk                          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk                          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_param[WIDTH_W-1:0]            ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_param_vld[2]                  ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rd_en_w[2]                      ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0                            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0                            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0                            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp                          ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0                            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (i_param_vld[2]                  ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
											                    // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
											                    // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);
xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (16                              ),// DECIMAL
	.ADDR_WIDTH_B            (13                              ),// DECIMAL
	.AUTO_SLEEP_TIME         (0                               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (WIDTH_W                         ),// DECIMAL
	.CASCADE_HEIGHT          (0                               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"                  ),// String
	.ECC_MODE                ("no_ecc"                        ),// String
	.MEMORY_INIT_FILE        ("none"                          ),// String
	.MEMORY_INIT_PARAM       ("0"                             ),// String
	.MEMORY_OPTIMIZATION     ("true"                          ),// String
	.MEMORY_PRIMITIVE        ("auto"                          ),// String
	.MEMORY_SIZE             (MEM_SIZE_2                      ),// DECIMAL
	.MESSAGE_CONTROL         (0                               ),// DECIMAL
	.READ_DATA_WIDTH_B       (WIDTH_W*BATCH                   ),// DECIMAL
	.READ_LATENCY_B          (1                               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"                             ),// String
	.RST_MODE_A              ("SYNC"                          ),// String
	.RST_MODE_B              ("SYNC"                          ),// String
	.SIM_ASSERT_CHK          (1                               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0                               ),// DECIMAL
	.USE_MEM_INIT            (0                               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep"                 ),// String
	.WRITE_DATA_WIDTH_A      (WIDTH_W                         ),// DECIMAL
	.WRITE_MODE_B            ("no_change"                     )// String
)
xpm_memory_sdpram_g1w2(
	.doutb                   (rd_data_w[3][WIDTH_W*BATCH-1:0] ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_w                       ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_w[3]                    ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk                          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk                          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_param[WIDTH_W-1:0]            ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_param_vld[3]                  ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rd_en_w[3]                      ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0                            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0                            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0                            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp                          ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0                            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (i_param_vld[3]                  ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
											                    // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
											                    // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);
xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (16                              ),// DECIMAL
	.ADDR_WIDTH_B            (13                              ),// DECIMAL
	.AUTO_SLEEP_TIME         (0                               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (WIDTH_W                         ),// DECIMAL
	.CASCADE_HEIGHT          (0                               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"                  ),// String
	.ECC_MODE                ("no_ecc"                        ),// String
	.MEMORY_INIT_FILE        ("none"                          ),// String
	.MEMORY_INIT_PARAM       ("0"                             ),// String
	.MEMORY_OPTIMIZATION     ("true"                          ),// String
	.MEMORY_PRIMITIVE        ("auto"                          ),// String
	.MEMORY_SIZE             (MEM_SIZE_2                      ),// DECIMAL
	.MESSAGE_CONTROL         (0                               ),// DECIMAL
	.READ_DATA_WIDTH_B       (WIDTH_W*BATCH                   ),// DECIMAL
	.READ_LATENCY_B          (1                               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"                             ),// String
	.RST_MODE_A              ("SYNC"                          ),// String
	.RST_MODE_B              ("SYNC"                          ),// String
	.SIM_ASSERT_CHK          (1                               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0                               ),// DECIMAL
	.USE_MEM_INIT            (0                               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep"                 ),// String
	.WRITE_DATA_WIDTH_A      (WIDTH_W                         ),// DECIMAL
	.WRITE_MODE_B            ("no_change"                     )// String
)
xpm_memory_sdpram_g1w3(
	.doutb                   (rd_data_w[4][WIDTH_W*BATCH-1:0] ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_w                       ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_w[4]                    ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk                          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk                          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_param[WIDTH_W-1:0]            ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_param_vld[4]                  ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rd_en_w[4]                      ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0                            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0                            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0                            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp                          ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0                            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (i_param_vld[4]                  ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
											                    // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
											                    // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);

endmodule
