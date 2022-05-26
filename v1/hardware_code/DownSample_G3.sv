`timescale 1ns / 1ps

module DownSample_G3#(
	parameter						DELAY   = 4'd4,
	parameter						GAP     = 4'd0,
	parameter						BATCH   = 4'd2,
	parameter						WIDTH_D = 27  ,
	parameter						WIDTH_W = 20  ,
	parameter						WIDTH_O = 27  ,
	parameter						CHANNEL = 128 ,
	parameter						QUANT_W = 16  ,
	parameter						SIZE    = 28  ,
	parameter						PADWAIT = 21  
)(
	input	wire					i_sclk       ,
	input	wire					i_vsync      ,
	input	wire					i_hsync      ,
	input	wire					i_reuse      ,
	input	wire					i_valid      ,
	input	wire[WIDTH_D-1:0]		i_tdata      ,
	input	wire					i_weight_vld ,
	input	wire[WIDTH_W*BATCH-1:0]	i_weight     ,
	
	output	wire					o_vsync      ,
	output	wire					o_hsync      ,
	output	wire					o_reuse      ,
	output	wire					o_valid      ,
	output	wire[WIDTH_O-1:0]		o_tdata      
);

//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
parameter	WIDTH_M = WIDTH_D + WIDTH_W-1;
parameter	WIDTH_S = WIDTH_D + WIDTH_W + 6;//42
//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
reg [15:0]										vsync_dly             ;
reg [15:0]										hsync_dly             ;
reg [1:0]										reuse_dly             ;
reg [1:0]										valid_dly             ;
wire											vsync_p               ;
wire											hsync_p               ;
reg [WIDTH_W*CHANNEL-1:0]						weight                ;
reg [WIDTH_W*CHANNEL-1:0]						weight_r              ;
(* use_dsp="yes" *)reg  signed[WIDTH_M-1:0]		mult_r[CHANNEL-1:0]   ;
reg  signed[WIDTH_S-1:0]						sum_r[CHANNEL-1:0]    ;
reg [4:0]										cnt_d                 ;
reg [8:0]										cnt_c                 ;

wire											wr_en                 ;
wire[WIDTH_S-1:0]								wr_data[CHANNEL-1:0]  ;
reg [2:0]										wr_addr               ;
wire											rd_en                 ;
reg [2:0]										rd_addr               ;
wire signed[WIDTH_S-1:0]						rd_data[CHANNEL-1:0]  ;
wire signed[WIDTH_S-1:0]						rd_data_r1            ;
wire signed[WIDTH_S-1:0]						rd_data_r2            ;

reg 											wr_end                ;
reg [2:0]										wr_wait_en            ;
reg [12:0]										wr_wait               ;
reg 											rd_end                ;
reg 											rd_last               ;

reg 											rd_en_b               ;
reg [2:0]										rd_cnt_b              ;
reg [8:0]										rd_cnt_r              ;
reg [11:0]										rd_addr_b             ;
reg 											rd_vld_b              ;
wire[WIDTH_O-1:0]								rd_data_b             ;

reg [11:0]										rd_addr_o             ;
wire[WIDTH_O-1:0]								rd_data_o             ;

wire											p_rdreq               ;
wire											p_vsync               ;
wire											p_hsync               ;
wire											p_reuse               ;
wire											p_valid               ;

reg 											hsync_o               ;
reg 											reuse_o               ;
reg 											valid_o               ;
reg [WIDTH_O-1:0]								tdata_o               ; 

//----------------------------------------------//
//					CODING						//
//----------------------------------------------//
// assign o_vsync = p_vsync;
assign o_vsync = i_vsync;
assign o_hsync = hsync_o;
assign o_reuse = reuse_o;
assign o_valid = valid_o;
assign o_tdata = tdata_o;

assign vsync_p = i_vsync;
assign hsync_p = DELAY=='d0 ? i_hsync:hsync_dly[DELAY-1];

assign wr_en = valid_dly[1]|rd_last;
assign rd_en = i_valid|rd_en_b;

always@(posedge i_sclk)
begin
	vsync_dly  <= {vsync_dly[14:0],i_vsync};
	hsync_dly  <= {hsync_dly[14:0],i_hsync};
	reuse_dly  <= {reuse_dly[0:0],i_reuse};
	valid_dly  <= {valid_dly[0:0],i_valid};
end

always@(posedge i_sclk)
begin
	if(i_vsync)				weight <= 'd0;
	else if(i_weight_vld)	weight <= {i_weight,weight[WIDTH_W*CHANNEL-1:WIDTH_W*BATCH]};

	if(i_vsync)				weight_r <= 'd0;
	else if(i_reuse)		weight_r <= weight;
	
	if(reuse_dly[1])		cnt_d <= 'd0;
	else if(valid_dly[1])	cnt_d <= cnt_d + 'd1;

	if(hsync_dly[1])		cnt_c <= 'd0;
	else if(reuse_dly[1])	cnt_c <= cnt_c + 'd1;
	
	if(rd_en)				rd_addr <= rd_addr + 'd1;
	else					rd_addr <= 'd0;
	
	if(wr_en)				wr_addr <= wr_addr + 'd1;
	else					wr_addr <= 'd0;
end

assign rd_data_r1 = rd_data[rd_cnt_r][WIDTH_S-1] ? (0-rd_data[rd_cnt_r]):rd_data[rd_cnt_r];
assign rd_data_r2 = rd_data_r1[WIDTH_S-1:QUANT_W] + rd_data_r1[QUANT_W-1];
assign rd_data_b = rd_vld_b ? (rd_data[rd_cnt_r][WIDTH_S-1] ? (0-rd_data_r2):rd_data_r2):'d0;

always@(posedge i_sclk)
begin
	rd_vld_b <= rd_en_b;
	wr_wait_en[1] <= wr_wait_en[0];
	wr_wait_en[2] <= ~wr_wait_en[0]&(wr_wait_en[1]);
	
	if(cnt_c==CHANNEL/2-1&&cnt_d==SIZE-1&&valid_dly[1])	wr_end <= 'd1;
	else												wr_end <= 'd0;
	
	if(hsync_dly[0]||wr_wait==6912)						wr_wait_en[0] <= 'd0;
	else if(wr_end)										wr_wait_en[0] <= 'd1;
	
	if(wr_wait_en[0])									wr_wait <= wr_wait + 'd1;
	else												wr_wait <= 'd0;
	
	if(rd_cnt_r<CHANNEL-1&&rd_cnt_b==SIZE-1)			rd_end <= 'd1;
	else 												rd_end <= 'd0;
	
	if(wr_wait_en[2]||rd_end)							rd_en_b <= 'd1;
	else if(i_vsync||rd_cnt_b==SIZE-1)					rd_en_b <= 'd0;
	
	if(rd_en_b)											rd_cnt_b <= rd_cnt_b + 'd1;
	else												rd_cnt_b <= 'd0;
	
	if(i_hsync)											rd_cnt_r <= 'd0;
	else if(!rd_en_b&&rd_vld_b)							rd_cnt_r <= rd_cnt_r + 'd1;
	
	if(rd_cnt_r==CHANNEL-1&&rd_vld_b)					rd_last <= 'd1;
	else												rd_last <= 'd0;
	
	if(i_hsync)											rd_addr_b <= 'd0;
	else if(rd_vld_b)									rd_addr_b <= rd_addr_b + 'd1;
	
	if(i_hsync||p_hsync)								rd_addr_o <= 'd0;
	else if(p_rdreq)									rd_addr_o <= rd_addr_o + 'd1;
	
end

always@(posedge i_sclk)
begin
	hsync_o <= p_hsync;
    reuse_o <= p_reuse;
	valid_o <= p_valid;
	
	if(p_valid)	tdata_o <= rd_data_o;
	else		tdata_o <= 'd0;
end

Pipeline#(
	.GAP          (GAP     ),
	.DELAY        (4'd0    ),
	.SIZE		  (SIZE    ),
	.CHANNEL      (CHANNEL ),
	.PADWAIT      (PADWAIT )
)Pipeline_recover(
	.i_sclk       (i_sclk  ),
	.i_vsync   	  (vsync_p ),
	.i_hsync   	  (hsync_p ),
	.o_rdreq      (p_rdreq ),
	.o_vsync      (p_vsync ),
	.o_hsync      (p_hsync ),
	.o_reuse      (p_reuse ),
	.o_valid      (p_valid )
);

genvar c;
generate
	for (c=0; c<CHANNEL; c=c+1)
	begin
		assign wr_data[c] = rd_last ? 'd0: sum_r[c];
		
		always@(posedge i_sclk)
		begin
			if(i_vsync)				mult_r[c] <= 'd0;
			else if(i_valid)		mult_r[c] <= $signed(i_tdata)*$signed(weight_r[(c+1)*WIDTH_W-1:c*WIDTH_W]);
			
			if(i_vsync)				sum_r[c] <= 'd0;
			else if(valid_dly[0])	sum_r[c] <= $signed(mult_r[c])+$signed(rd_data[c]);
		end
		
		xpm_memory_sdpram#(
			.ADDR_WIDTH_A            (3               ),// DECIMAL
			.ADDR_WIDTH_B            (3               ),// DECIMAL
			.AUTO_SLEEP_TIME         (0               ),// DECIMAL
			.BYTE_WRITE_WIDTH_A      (WIDTH_S         ),// DECIMAL
			.CASCADE_HEIGHT          (0               ),// DECIMAL
			.CLOCKING_MODE           ("common_clock"  ),// String
			.ECC_MODE                ("no_ecc"        ),// String
			.MEMORY_INIT_FILE        ("none"          ),// String
			.MEMORY_INIT_PARAM       ("0"             ),// String
			.MEMORY_OPTIMIZATION     ("true"          ),// String
			.MEMORY_PRIMITIVE        ("auto"          ),// String
			.MEMORY_SIZE             (WIDTH_S*SIZE    ),// DECIMAL
			.MESSAGE_CONTROL         (0               ),// DECIMAL
			.READ_DATA_WIDTH_B       (WIDTH_S         ),// DECIMAL
			.READ_LATENCY_B          (1               ),// DECIMAL
			.READ_RESET_VALUE_B      ("0"             ),// String
			.RST_MODE_A              ("SYNC"          ),// String
			.RST_MODE_B              ("SYNC"          ),// String
			.SIM_ASSERT_CHK          (1               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
			.USE_EMBEDDED_CONSTRAINT (0               ),// DECIMAL
			.USE_MEM_INIT            (0               ),// DECIMAL
			.WAKEUP_TIME             ("disable_sleep" ),// String
			.WRITE_DATA_WIDTH_A      (WIDTH_S         ),// DECIMAL
			.WRITE_MODE_B            ("no_change"     )// String
		)
		xpm_memory_sdpram_1(
			.doutb                   (rd_data[c]      ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
			.addra                   (wr_addr         ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
			.addrb                   (rd_addr         ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
			.clka                    (i_sclk          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
			.clkb                    (i_sclk          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
			.dina                    (wr_data[c]      ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
			.ena                     (wr_en           ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
			.enb                     (rd_en           ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
			.injectdbiterra          (1'b0            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
			.injectsbiterra          (1'b0            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
			.regceb                  (1'b0            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
			.rstb                    (i_vsync         ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
			.sleep                   (1'b0            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
			.wea                     (wr_en           ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
													    // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
													    // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
		);
	end
endgenerate

xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (12              ),// DECIMAL
	.ADDR_WIDTH_B            (12              ),// DECIMAL
	.AUTO_SLEEP_TIME         (0               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (WIDTH_O         ),// DECIMAL
	.CASCADE_HEIGHT          (0               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"  ),// String
	.ECC_MODE                ("no_ecc"        ),// String
	.MEMORY_INIT_FILE        ("none"          ),// String
	.MEMORY_INIT_PARAM       ("0"             ),// String
	.MEMORY_OPTIMIZATION     ("true"          ),// String
	.MEMORY_PRIMITIVE        ("auto"          ),// String
	.MEMORY_SIZE             (WIDTH_O*3584    ),// DECIMAL
	.MESSAGE_CONTROL         (0               ),// DECIMAL
	.READ_DATA_WIDTH_B       (WIDTH_O         ),// DECIMAL
	.READ_LATENCY_B          (1               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"             ),// String
	.RST_MODE_A              ("SYNC"          ),// String
	.RST_MODE_B              ("SYNC"          ),// String
	.SIM_ASSERT_CHK          (1               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0               ),// DECIMAL
	.USE_MEM_INIT            (0               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep" ),// String
	.WRITE_DATA_WIDTH_A      (WIDTH_O         ),// DECIMAL
	.WRITE_MODE_B            ("no_change"     )// String
)
xpm_memory_sdpram_2(
	.doutb                   (rd_data_o       ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (rd_addr_b       ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr_o       ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (rd_data_b       ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (rd_vld_b        ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (p_rdreq         ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0            ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0            ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0            ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_vsync         ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0            ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (rd_vld_b        ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
											    // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
											    // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);

endmodule
