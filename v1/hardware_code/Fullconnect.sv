`timescale 1ns / 1ps

module Fullconnect#(
	parameter						WIDTH_D = 27  , //WIDTH OF INPUT DATA
	parameter						WIDTH_P = 60  , //WIDTH OF PARAMETERS
	parameter						WIDTH_W = 20  , //WIDTH OF WEIGHT
	parameter						WIDTH_B = 20  , //WIDTH OF BIAS
	parameter						QUANT_W = 16  ,
	parameter						SIZE_I  = 512 , //INPUT_CHANNEL
	parameter						SIZE_O  = 1000  //OUTPUT_CHANNEL
)(
	input	wire					i_sclk        ,
	input	wire					i_rstp        ,
	
	input	wire					i_vsync       ,
	input	wire					i_valid       ,
	input	wire[WIDTH_D-1:0]		i_tdata       ,
	input	wire[1:0]				i_param_vld   ,
	input	wire[WIDTH_P-1:0]		i_param       ,
	
	output	wire					o_predict_vld ,
	output	wire[9:0]				o_predict    
);

//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
reg [9:0]											wr_addr_b         ;
reg [9:0]											rd_addr_b         ;
wire signed[WIDTH_B-1:0]							rd_data_b         ;
reg 												rd_vld_b          ;

reg [9:0]											para_w_cnt        ;
reg 												wr_en_w           ;
reg [WIDTH_W*SIZE_O-1:0]							wr_data_w         ;
reg [8:0]											wr_addr_w         ;
reg [8:0]											rd_addr_w         ;
wire[WIDTH_W*SIZE_O-1:0]							rd_data_w         ;
reg 												rd_vld_w          ;

wire												fc_w_req          ;
reg  signed[WIDTH_D-1:0]							tdata             ;

reg 												mult_d_vld        ;
(* use_dsp="yes" *)	reg signed[WIDTH_D+WIDTH_W-1:0]	mult_d[SIZE_O-1:0];
reg 												sum_d_vld         ;
reg  signed[WIDTH_D+WIDTH_W+11:0]					sum_d[SIZE_O-1:0] ;
reg 												sum_d_end         ;

reg 												fc_b_req          ;
reg 												fc_vld            ;
reg  signed[WIDTH_D+WIDTH_W+12:0]					fc_dat            ;
reg [9:0]											fc_cnt            ;

reg  signed[WIDTH_D+WIDTH_W+11:0]					max               ;
reg 												max_end           ;
reg [9:0]											cnt_m             ;

//----------------------------------------------//
//					CODING						//
//----------------------------------------------//
assign o_predict_vld = max_end;
assign o_predict     = cnt_m;

assign fc_w_req = i_valid;

always @(posedge i_sclk)
begin
	tdata      <= i_tdata;
	rd_vld_w   <= fc_w_req;
	mult_d_vld <= rd_vld_w;
	sum_d_vld  <= mult_d_vld;
	sum_d_end  <= !mult_d_vld&&sum_d_vld;
	
	if(i_rstp)						para_w_cnt <= 'd0;
	else if(i_param_vld[0])
	begin
		if(para_w_cnt==SIZE_O-1)	para_w_cnt <= 'd0;
		else						para_w_cnt <= para_w_cnt + 'd1;
	end

	if(i_rstp)						wr_data_w <= 'd0;
	else if(i_param_vld[0])			wr_data_w <= {i_param[WIDTH_W-1:0],wr_data_w[WIDTH_W*SIZE_O-1:WIDTH_W]};
	
	if(para_w_cnt==SIZE_O-1)		wr_en_w <= 'd1;
	else							wr_en_w <= 'd0;
	
	if(i_rstp||wr_addr_w==SIZE_O)	wr_addr_w <= 'd0;
	else if(wr_en_w)				wr_addr_w <= wr_addr_w + 'd1;
	
	if(i_rstp||rd_addr_w==SIZE_I)	rd_addr_w <= 'd0;
	else if(fc_w_req)				rd_addr_w <= rd_addr_w + 'd1;
	
	if(i_rstp)						wr_addr_b <= 'd0;
	else if(i_param_vld[1])
	begin
		if(wr_addr_b==SIZE_O-1)		wr_addr_b <= 'd0;
		else						wr_addr_b <= wr_addr_b + 'd1;
	end
	
end

always @(posedge i_sclk)
begin
	rd_vld_b <= fc_b_req;
	fc_vld   <= rd_vld_b;
	
	if(i_vsync||rd_addr_b==SIZE_O-1)	fc_b_req <= 'd0;
	else if(sum_d_end)					fc_b_req <= 'd1;
	
	if(i_rstp||rd_addr_b==SIZE_O)		rd_addr_b <= 'd0;
	else if(fc_b_req)					rd_addr_b <= rd_addr_b + 'd1;
	
	if(rd_vld_b)						fc_dat <= rd_data_b + sum_d[rd_addr_b-1];
	else								fc_dat <= 'd0;
	
	if(fc_vld)							fc_cnt <= fc_cnt + 'd1;
	else								fc_cnt <= 'd0;
end

always@(posedge i_sclk)
begin
	if(i_vsync)
	begin
		cnt_m <= 'd0;
		max   <= {1'b1,{WIDTH_D+WIDTH_W+11{1'b0}}};
	end
	else if(fc_vld)
	begin
		if(fc_dat>=max)
		begin
			cnt_m <= fc_cnt;
			max   <= fc_dat;
		end
	end
	
	if(fc_cnt==SIZE_O)	max_end <= 'd1;
	else				max_end <= 'd0;
end

genvar w;
generate
	for(w=0;w<SIZE_O;w=w+1)
	begin
		always @(posedge i_sclk)
		begin
			if(rd_vld_w)			mult_d[w] <= $signed(rd_data_w[WIDTH_W*(w+1)-1:WIDTH_W*w])*tdata;
			else					mult_d[w] <= 'd0;
			
			if(i_vsync)				sum_d[w] <= 'd0;
			else if(mult_d_vld)		sum_d[w] <= sum_d[w] + mult_d[w];
		end
	end
endgenerate

xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (10                   ),// DECIMAL
	.ADDR_WIDTH_B            (10                   ),// DECIMAL
	.AUTO_SLEEP_TIME         (0                    ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (WIDTH_B              ),// DECIMAL
	.CASCADE_HEIGHT          (0                    ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"       ),// String
	.ECC_MODE                ("no_ecc"             ),// String
	.MEMORY_INIT_FILE        ("none"               ),// String
	.MEMORY_INIT_PARAM       ("0"                  ),// String
	.MEMORY_OPTIMIZATION     ("true"               ),// String
	.MEMORY_PRIMITIVE        ("auto"               ),// String
	.MEMORY_SIZE             (WIDTH_B*SIZE_O       ),// DECIMAL
	.MESSAGE_CONTROL         (0                    ),// DECIMAL
	.READ_DATA_WIDTH_B       (WIDTH_B              ),// DECIMAL
	.READ_LATENCY_B          (1                    ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"                  ),// String
	.RST_MODE_A              ("SYNC"               ),// String
	.RST_MODE_B              ("SYNC"               ),// String
	.SIM_ASSERT_CHK          (1                    ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0                    ),// DECIMAL
	.USE_MEM_INIT            (0                    ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep"      ),// String
	.WRITE_DATA_WIDTH_A      (WIDTH_B              ),// DECIMAL
	.WRITE_MODE_B            ("no_change"          )// String
)
xpm_memory_sdpram_fc_b(
	.doutb                   (rd_data_b            ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_b            ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_b            ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk               ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk               ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_param[WIDTH_B-1:0] ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_param_vld[1]       ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (fc_b_req             ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0                 ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0                 ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0                 ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp               ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0                 ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (i_param_vld[1]       ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
											         // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
											         // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);

xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (9                    ),// DECIMAL
	.ADDR_WIDTH_B            (9                    ),// DECIMAL
	.AUTO_SLEEP_TIME         (0                    ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (WIDTH_W*SIZE_O       ),// DECIMAL
	.CASCADE_HEIGHT          (0                    ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"       ),// String
	.ECC_MODE                ("no_ecc"             ),// String
	.MEMORY_INIT_FILE        ("none"               ),// String
	.MEMORY_INIT_PARAM       ("0"                  ),// String
	.MEMORY_OPTIMIZATION     ("true"               ),// String
	.MEMORY_PRIMITIVE        ("auto"               ),// String
	.MEMORY_SIZE             (WIDTH_W*SIZE_O*SIZE_I),// DECIMAL
	.MESSAGE_CONTROL         (0                    ),// DECIMAL
	.READ_DATA_WIDTH_B       (WIDTH_W*SIZE_O       ),// DECIMAL
	.READ_LATENCY_B          (1                    ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"                  ),// String
	.RST_MODE_A              ("SYNC"               ),// String
	.RST_MODE_B              ("SYNC"               ),// String
	.SIM_ASSERT_CHK          (1                    ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0                    ),// DECIMAL
	.USE_MEM_INIT            (0                    ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep"      ),// String
	.WRITE_DATA_WIDTH_A      (WIDTH_W*SIZE_O       ),// DECIMAL
	.WRITE_MODE_B            ("no_change"          )// String
)
xpm_memory_sdpram_fc_w(
	.doutb                   (rd_data_w            ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr_w            ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_w            ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk               ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk               ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (wr_data_w            ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (wr_en_w              ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (fc_w_req             ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0                 ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0                 ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0                 ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp               ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0                 ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (wr_en_w              ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
											         // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
											         // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);

endmodule
