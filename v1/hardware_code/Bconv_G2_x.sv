`timescale 1ns / 1ps

module Bconv_G2_x#(
	parameter							DELAY   = 4'd4,
	parameter							GAP     = 4'd0,
	parameter							BATCH   = 4'd2,
	parameter							WIDTH_D = 2   ,
	parameter							WIDTH_C = 11  ,
	parameter							WIDTH_O = 26  ,
	parameter							QUANT_W = 16  ,
	parameter							CHANNEL = 128 ,
	parameter							SIZE    = 28  ,
	parameter							LEN     = 3   ,
	parameter							PADWAIT = 28  ,
	parameter							WIDTH_W = WIDTH_D*LEN*LEN
)(
	input	wire						i_sclk       ,

	input	wire						i_vsync      ,
	input	wire						i_hsync      ,
	input	wire						i_reuse      ,
	input	wire						i_valid      ,
	input	wire[WIDTH_D*LEN-1:0]		i_tdata      ,
	input	wire						i_weight_vld ,
	input	wire[WIDTH_W*BATCH-1:0]		i_weight     ,
	input	wire[QUANT_W-1:0]			i_weight_e   ,
	
	output	wire						o_vsync      ,
	output	wire						o_hsync      ,
	output	wire						o_reuse      ,
	output	wire						o_valid      ,
	output	wire[WIDTH_O-1:0]			o_tdata      
);

//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
reg [4:0]									vsync_dly               ;
reg [4:0]									hsync_dly               ;
reg [4:0]									reuse_dly               ;
reg [4:0]									valid_dly               ;
wire										vsync_p                 ;
wire										hsync_p                 ;
reg signed[QUANT_W:0]						weight_e                ;
reg [WIDTH_D*CHANNEL-1:0]					weight  [LEN*LEN-1:0]   ;
reg [WIDTH_D*CHANNEL-1:0]					weight_r[LEN*LEN-1:0]   ;
reg [WIDTH_D-1:0]							data_r[LEN*LEN-1:0]     ;
reg [WIDTH_D*CHANNEL-1:0]					mult_r[LEN*LEN-1:0]     ;
reg [WIDTH_C*CHANNEL-1:0]					sum_r                   ;

reg [7:0]									cnt_c                   ;

wire										wr_en                   ;
wire[WIDTH_C*CHANNEL-1:0]					wr_data                 ;
reg [3:0]									wr_addr                 ;
wire										rd_en                   ;
reg [3:0]									rd_addr                 ;
wire[WIDTH_C*CHANNEL-1:0]					rd_data                 ;

reg 										wr_end                  ;
reg 										rd_end                  ;
reg 										rd_last                 ;

reg 										rd_en_b                 ;
reg [3:0]									rd_cnt_b                ;
reg [7:0]									rd_cnt_r                ;
reg 										rd_vld_b                ;
wire[WIDTH_C-1:0]							rd_data_b               ;
wire signed[WIDTH_C-1:0]					rd_data_b_r[CHANNEL-1:0];

wire										b_rdreq                 ;
wire										b_vsync                 ;
wire										b_hsync                 ;
wire										b_reuse                 ;
wire										b_valid                 ;
wire signed[WIDTH_C-1:0]					b_data                  ;
wire										b_full,b_empty          ;

reg 										hsync_o                 ;
reg 										reuse_o                 ;
reg 										valid_o                 ;
(* use_dsp="yes" *)	reg signed[WIDTH_O-1:0]	tdata_o                 ;

//----------------------------------------------//
//					CODING						//
//----------------------------------------------//
// assign o_vsync = b_vsync;
assign o_vsync = i_vsync;
assign o_hsync = hsync_o; 
assign o_reuse = reuse_o; 
assign o_valid = valid_o; 
assign o_tdata = tdata_o; 

assign vsync_p = i_vsync;
assign hsync_p = DELAY=='d0 ? i_hsync:hsync_dly[DELAY-1];

assign rd_en   = valid_dly[1]|rd_en_b;
assign wr_en   = rd_last ? 1'b1:valid_dly[3];
assign wr_data = rd_last ? 0:sum_r;

always@(posedge i_sclk)
begin
	vsync_dly <= {vsync_dly[3:0],i_vsync};
	hsync_dly <= {hsync_dly[3:0],i_hsync};
	reuse_dly <= {reuse_dly[3:0],i_reuse};
	valid_dly <= {valid_dly[3:0],i_valid};
	weight_e  <= i_weight_e;
end

always@(posedge i_sclk)
begin
	data_r[0] <= data_r[1];
	data_r[1] <= data_r[2];
	data_r[3] <= data_r[4];
	data_r[4] <= data_r[5];
	data_r[6] <= data_r[7];
	data_r[7] <= data_r[8];
	
	if(i_valid)
	begin
		data_r[2] <= i_tdata[WIDTH_D*1-1:WIDTH_D*0];
		data_r[5] <= i_tdata[WIDTH_D*2-1:WIDTH_D*1];
		data_r[8] <= i_tdata[WIDTH_D*3-1:WIDTH_D*2];
	end
	else
	begin
		data_r[2] <= 'd0;
		data_r[5] <= 'd0;
		data_r[8] <= 'd0;
	end
end

always@(posedge i_sclk)
begin
	if(hsync_dly[3])		cnt_c <= 'd0;
	else if(reuse_dly[3])	cnt_c <= cnt_c + 'd1;

	if(wr_en)				wr_addr <= wr_addr + 'd1;
	else					wr_addr <= 'd0;
	
	if(rd_en)				rd_addr <= rd_addr + 'd1;
	else					rd_addr <= 'd0;
end

assign rd_data_b = rd_vld_b ? rd_data_b_r[rd_cnt_r]:'d0;

always@(posedge i_sclk)
begin
	rd_vld_b <= rd_en_b;
	
	if(cnt_c==CHANNEL-1&&valid_dly[3]&&!valid_dly[2])	wr_end <= 'd1;
	else												wr_end <= 'd0;
	
	if(rd_cnt_r<CHANNEL-1&&rd_cnt_b==SIZE-1)			rd_end <= 'd1;
	else 												rd_end <= 'd0;
	
	if(wr_end||rd_end)									rd_en_b <= 'd1;
	else if(i_vsync||rd_cnt_b==SIZE-1)					rd_en_b <= 'd0;
	
	if(rd_en_b)											rd_cnt_b <= rd_cnt_b + 'd1;
	else												rd_cnt_b <= 'd0;
	
	if(i_hsync)											rd_cnt_r <= 'd0;
	else if(!rd_en_b&&rd_vld_b)							rd_cnt_r <= rd_cnt_r + 'd1;
	
	if(rd_cnt_r==CHANNEL-1&&rd_en_b)					rd_last <= 'd1;
	else												rd_last <= 'd0;
end

always@(posedge i_sclk)
begin
	hsync_o <= b_hsync;
	reuse_o <= b_reuse;
	valid_o <= b_valid;
	//relu
	if(b_data[WIDTH_C-1])	tdata_o <= 'd0;
	else					tdata_o <= b_data*weight_e;
end

genvar w;
generate
	for (w=0; w<(LEN*LEN); w=w+1)
	begin
		always@(posedge i_sclk)
		begin
			if(i_vsync)				weight[w] <= 'd0;
			else if(i_weight_vld)	weight[w] <= {i_weight[(w+1)*WIDTH_D+WIDTH_W*7-1:w*WIDTH_D+WIDTH_W*7],
												  i_weight[(w+1)*WIDTH_D+WIDTH_W*6-1:w*WIDTH_D+WIDTH_W*6],
												  i_weight[(w+1)*WIDTH_D+WIDTH_W*5-1:w*WIDTH_D+WIDTH_W*5],
												  i_weight[(w+1)*WIDTH_D+WIDTH_W*4-1:w*WIDTH_D+WIDTH_W*4],
												  i_weight[(w+1)*WIDTH_D+WIDTH_W*3-1:w*WIDTH_D+WIDTH_W*3],
												  i_weight[(w+1)*WIDTH_D+WIDTH_W*2-1:w*WIDTH_D+WIDTH_W*2],
												  i_weight[(w+1)*WIDTH_D+WIDTH_W*1-1:w*WIDTH_D+WIDTH_W*1],
			                                      i_weight[(w+1)*WIDTH_D-1:w*WIDTH_D],
												  weight[w][WIDTH_D*CHANNEL-1:WIDTH_D*8]};

			if(i_vsync)				weight_r[w] <= 'd0;
			else if(i_reuse)		weight_r[w] <= weight[w];
		end
	end
endgenerate

genvar c,m;
generate
	for (c=0; c<CHANNEL; c=c+1)
	begin

		for (m=0; m<(LEN*LEN); m=m+1)
		begin
			always@(posedge i_sclk)
			begin
				if(weight_r[m][c*WIDTH_D]==0||data_r[m][WIDTH_D-2:0]==0)	mult_r[m][(c+1)*WIDTH_D-1:c*WIDTH_D] <= 2'b00;
				else if(weight_r[m][(c+1)*WIDTH_D-1]^data_r[m][WIDTH_D-1])	mult_r[m][(c+1)*WIDTH_D-1:c*WIDTH_D] <= 2'b11;
				else														mult_r[m][(c+1)*WIDTH_D-1:c*WIDTH_D] <= 2'b01;
			end
		end
		
		always@(posedge i_sclk)
		begin
			if(valid_dly[2])
			begin
				sum_r[WIDTH_C*(c+1)-1:WIDTH_C*c] <= $signed(mult_r[0][(c+1)*WIDTH_D-1:c*WIDTH_D])
												  + $signed(mult_r[1][(c+1)*WIDTH_D-1:c*WIDTH_D])
												  + $signed(mult_r[2][(c+1)*WIDTH_D-1:c*WIDTH_D])
												  + $signed(mult_r[3][(c+1)*WIDTH_D-1:c*WIDTH_D])
												  + $signed(mult_r[4][(c+1)*WIDTH_D-1:c*WIDTH_D])
												  + $signed(mult_r[5][(c+1)*WIDTH_D-1:c*WIDTH_D])
												  + $signed(mult_r[6][(c+1)*WIDTH_D-1:c*WIDTH_D])
												  + $signed(mult_r[7][(c+1)*WIDTH_D-1:c*WIDTH_D])
												  + $signed(mult_r[8][(c+1)*WIDTH_D-1:c*WIDTH_D])
												  + $signed(rd_data[WIDTH_C*(c+1)-1:WIDTH_C*c]);
			end
		end
		
		assign rd_data_b_r[c] = rd_vld_b ? rd_data[WIDTH_C*(c+1)-1:WIDTH_C*c]:'d0;
	end
endgenerate


xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (4               ),// DECIMAL
	.ADDR_WIDTH_B            (4               ),// DECIMAL
	.AUTO_SLEEP_TIME         (0               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (11*256          ),// DECIMAL
	.CASCADE_HEIGHT          (0               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"  ),// String
	.ECC_MODE                ("no_ecc"        ),// String
	.MEMORY_INIT_FILE        ("none"          ),// String
	.MEMORY_INIT_PARAM       ("0"             ),// String
	.MEMORY_OPTIMIZATION     ("true"          ),// String
	.MEMORY_PRIMITIVE        ("auto"          ),// String
	.MEMORY_SIZE             (11*256*14       ),// DECIMAL
	.MESSAGE_CONTROL         (0               ),// DECIMAL
	.READ_DATA_WIDTH_B       (11*256          ),// DECIMAL
	.READ_LATENCY_B          (1               ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"             ),// String
	.RST_MODE_A              ("SYNC"          ),// String
	.RST_MODE_B              ("SYNC"          ),// String
	.SIM_ASSERT_CHK          (1               ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0               ),// DECIMAL
	.USE_MEM_INIT            (0               ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep" ),// String
	.WRITE_DATA_WIDTH_A      (11*256          ),// DECIMAL
	.WRITE_MODE_B            ("no_change"     )// String
)
xpm_memory_sdpram_1(
	.doutb                   (rd_data         ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wr_addr         ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr         ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk          ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk          ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (wr_data         ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
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

Pipeline#(
	.GAP          (GAP                                 ),
	.SIZE         (SIZE                                ),
	.CHANNEL      (CHANNEL                             ),
	.PADWAIT      (PADWAIT                             )
)Pipeline_recover(
	.i_sclk       (i_sclk                              ),
	.i_vsync      (vsync_p                             ),
	.i_hsync      (hsync_p                             ),
	.o_rdreq      (b_rdreq                             ),
	.o_vsync      (b_vsync                             ),
	.o_hsync      (b_hsync                             ),
	.o_reuse      (b_reuse                             ),
	.o_valid      (b_valid                             )
);


fifo_bconv fifo_bconv_inst(
	.clk	      (i_sclk         ),  // input wire clk
	.rst	      (i_vsync        ),  // input wire rst
	.din	      (rd_data_b      ),  // input wire [10 : 0] din
	.wr_en	      (rd_vld_b       ),  // input wire wr_en
	.rd_en	      (b_rdreq        ),  // input wire rd_en
	.dout	      (b_data         ),  // output wire [10 : 0] dout
	.full	      (b_full         ),  // output wire full
	.empty	      (b_empty        )   // output wire empty
);

endmodule
