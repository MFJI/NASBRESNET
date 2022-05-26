`timescale 1ns / 1ps

module AvgPool#(
	parameter					WIDTH_D = 27        ,
	parameter					QUANT_W = 128       ,
	parameter					SIZE_I  = 512       ,
	parameter					SIZE_O  = 1000      
)(
	input	wire				i_sclk              ,
	input	wire				i_vsync             ,
	input	wire				i_hsync             ,
	input	wire				i_reuse             ,
	input	wire				i_valid             ,
	input	wire[WIDTH_D-1:0]	i_tdata             ,

	output	wire				o_vsync             ,
	output	wire				o_valid             ,
	output	wire[WIDTH_D-1:0]	o_tdata             
);

//----------------------------------------------//
//					PARAMETER					//
//----------------------------------------------//
parameter	WIDTH_S = WIDTH_D + 6;
parameter	LEN     = 3'd7;
parameter	NUM     = 6'd49;
//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
reg 							clear_vld           ;
reg [8:0]						clear_cnt           ;

reg [2:0]						cnt_r               ;
reg [8:0]						cnt_c               ;
reg 							sum_c_vld           ;
reg  signed[WIDTH_S-1:0]		sum_c               ;
reg 							sum_done            ;
reg 							sum_req             ;
reg 							sum_done_d1         ;

reg 							wrreq               ;
reg [8:0]						wrcnt               ;
reg  signed[WIDTH_S-1:0]		wrdat               ;
wire							rdreq               ;
reg [8:0]						rdcnt               ;
wire signed[WIDTH_S-1:0]		rddat               ;
wire signed[WIDTH_S-1:0]		rddat_abs           ;
reg [WIDTH_S+2:0]				rddat_PoN           ;
reg [WIDTH_S+1:0]				rddat_vld           ;

wire[WIDTH_S+1:0]				div_vld             ;
wire[WIDTH_S-2:0]				div_int[WIDTH_S+1:0];
wire[5:0]						div_fac[WIDTH_S+1:0];
reg [6:0]						div_cnt             ;

reg 							vsync               ;
reg 							valid               ;
reg [WIDTH_D-2:0]				tdata               ;
//----------------------------------------------//
//					CODING						//
//----------------------------------------------//
assign o_vsync   = vsync;
assign o_valid   = valid;
assign o_tdata   = rddat_PoN[WIDTH_S+2] ? (0-tdata):tdata;

assign rdreq     = i_reuse|sum_req;
assign rddat_abs = rddat[WIDTH_S-1] ? (0-rddat):rddat;

always@(posedge i_sclk)
begin
	if(i_vsync)						clear_vld <= 'd1;
	else if(clear_cnt==SIZE_I-1)	clear_vld <= 'd0;
	
	if(clear_vld)					clear_cnt <= clear_cnt + 'd1;
	else							clear_cnt <= 'd0;
end

always@(posedge i_sclk)
begin
	if(i_vsync||sum_done)					cnt_r <= 'd0;
	else if(i_hsync)						cnt_r <= cnt_r + 'd1;

	if(i_hsync)								cnt_c <= 'd0;
	else if(i_reuse)						cnt_c <= cnt_c + 'd1;

	if(cnt_c==SIZE_I-1&&cnt_r==LEN&&wrreq)	sum_done <= 'd1;
	else									sum_done <= 'd0;
end

always@(posedge i_sclk)
begin
	sum_c_vld <= i_valid;
	
	if(i_reuse)				sum_c <= 'd0;
	else if(i_valid)		sum_c <= sum_c + $signed(i_tdata);

	if(!i_valid&&sum_c_vld)
	begin
		wrreq <= 'd1;
		wrdat <= sum_c + rddat;
	end
	else
	begin
		wrdat <= wrdat;
		wrreq <= 'd0;
		if(clear_vld)		wrreq <= 'd1;
		else				wrreq <= 'd0;
		
		if(clear_vld)		wrdat <= 'd0;
		else				wrdat <= wrdat;
	end
end

always@(posedge i_sclk)
begin
	sum_done_d1 <= sum_done;
	rddat_PoN   <= {rddat_PoN[WIDTH_S+1:0],rddat[WIDTH_S-1]};
	
	if(i_vsync||wrcnt==SIZE_I)				wrcnt <= 'd0;
	else if(wrreq)							wrcnt <= wrcnt + 'd1;
	
	if(i_vsync||rdcnt==SIZE_I)				rdcnt <= 'd0;
	else if(rdreq)							rdcnt <= rdcnt + 'd1;
	
	if(i_vsync||sum_done)					sum_req <= 'd1;
	else if(rdcnt==SIZE_I-1)				sum_req <= 'd0;
	
	if(sum_done_d1||rddat_vld[WIDTH_S+1])	rddat_vld <= 'd1;
	else if(sum_req)						rddat_vld <= rddat_vld << 1;
	else									rddat_vld <= 'd0;
end

always@(posedge i_sclk)
begin
	if(|div_vld)
	begin
		if(div_cnt==WIDTH_S+1)	div_cnt <= 'd0;
		else					div_cnt <= div_cnt + 'd1;
	end
	else						div_cnt <= 'd0;
end

always@(posedge i_sclk)
begin
	vsync <= i_vsync;
	valid <= |div_vld;
	
	if(div_vld[div_cnt]&&div_fac[div_cnt]>(NUM>>1))	tdata <= div_int[div_cnt] + 'd1;
	else											tdata <= div_int[div_cnt];
end

genvar i;
generate
	for(i=0;i<WIDTH_S+2;i=i+1)
	begin
		divider_DIY#(
			.W_N           (WIDTH_S-1              ), 
			.W_D           (6                      )  
		)divider_DIY_inst(
			.i_sclk        (i_sclk                 ),
			.i_rstp        (i_vsync                ),
			.i_div_valid   (rddat_vld[i]           ), 
			.i_numerator   (rddat_abs[WIDTH_S-2:0] ),  
			.i_denominator (NUM                    ), 
			.o_div_valid   (div_vld[i]             ), 
			.o_quotient    (div_int[i]             ), 
			.o_remainder   (div_fac[i]             )  
		);
	end
endgenerate

xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (9               ),// DECIMAL
	.ADDR_WIDTH_B            (9               ),// DECIMAL
	.AUTO_SLEEP_TIME         (0               ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (WIDTH_S         ),// DECIMAL
	.CASCADE_HEIGHT          (0               ),// DECIMAL
	.CLOCKING_MODE           ("common_clock"  ),// String
	.ECC_MODE                ("no_ecc"        ),// String
	.MEMORY_INIT_FILE        ("none"          ),// String
	.MEMORY_INIT_PARAM       ("0"             ),// String
	.MEMORY_OPTIMIZATION     ("true"          ),// String
	.MEMORY_PRIMITIVE        ("auto"          ),// String
	.MEMORY_SIZE             (WIDTH_S*SIZE_I  ),// DECIMAL
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
xpm_memory_sdpram_avgpool(
	.doutb                   (rddat            ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.addra                   (wrcnt            ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rdcnt            ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk           ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk           ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (wrdat            ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (wrreq            ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rdreq            ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (1'b0             ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (1'b0             ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (1'b0             ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_vsync          ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (1'b0             ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (wrreq            ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
                                                 // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
                                                 // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);

endmodule
