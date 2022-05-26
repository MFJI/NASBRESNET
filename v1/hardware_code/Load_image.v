`timescale 1ns / 1ps

module Load_image#(
	parameter					WIDTH_D = 24 ,//8*3
	parameter					SIZE    = 224
)(
	input	wire				i_sclk       ,
	input	wire				i_rstp       ,

	input	wire				i_image_vld  ,
	input	wire[WIDTH_D-1:0]	i_image      ,

	output	wire				o_vsync      ,
	output	wire				o_hsync      ,
	output	wire				o_valid      ,
	output	wire[WIDTH_D-1:0]	o_tdata      
);

//----------------------------------------------//
//					PARAMETER					//
//----------------------------------------------//
parameter	MEM_WIDTH  = WIDTH_D;
parameter	MEM_SIZE   = MEM_WIDTH*65536;//2097152
parameter	IMG_ROW    = 224;
parameter	IMG_COL    = 224;
parameter	IMG_SIZE   = IMG_ROW*IMG_COL;//50176
parameter	VESA_WAIT  = IMG_COL*7+60;
parameter	READ_BEGIN = {IMG_COL[7:0],1'd0};
//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
wire					dbiterrb       ;
wire					sbiterrb       ;
wire					injectdbiterra ;
wire					injectsbiterra ;
wire					regceb         ;
wire        			sleep          ;
reg [15:0]				wr_addr        ;
reg [4:0]				rd_flag        ;

reg [3:0]				state          ;
reg [3:0]				state_d1       ;
reg [7:0]				cnt_col        ;
reg [7:0]				cnt_row        ;
reg [11:0]				cnt_wait       ;
reg [7:0]				cnt_frame      ;

reg 					rd_en          ;
reg [15:0]				rd_addr        ;

reg 					hsy            ;
reg 					rd_data_vld    ;
wire[MEM_WIDTH-1:0]		rd_data        ;

reg [1:0]				rstp_dly       ;
reg 					rstp_down      ;
reg 					first_done     ;
reg 					vsync          ;
reg 					hsync          ;
reg 					valid          ;
reg [WIDTH_D-1:0]		tdata          ;
//----------------------------------------------//
//					CODING						//
//----------------------------------------------//
assign o_vsync        = vsync;
assign o_hsync        = hsync;
assign o_valid        = valid;
assign o_tdata        = tdata;

assign injectdbiterra = 1'b0;
assign injectsbiterra = 1'b0;
assign regceb         = 1'b0;
assign sleep          = 1'b0;

always @(posedge i_sclk)
begin
	rstp_dly     <= {rstp_dly[0:0],i_rstp};
	rstp_down    <= !rstp_dly[0]&&rstp_dly[1];
	rd_data_vld  <= rd_en;
	rd_flag[4:1] <= rd_flag[3:0];
	
	if(i_rstp||state=='d7)	wr_addr <= 'd0;
	else if(i_image_vld)	wr_addr <= wr_addr + 'd1;
	
	if(wr_addr==READ_BEGIN)	rd_flag[0] <= 'd1;
	else					rd_flag[0] <= 'd0;
	
	if(rd_en)				cnt_col <= cnt_col + 'd1;
	else					cnt_col <= 'd0;
	
	if(i_rstp||state=='d7)	cnt_row <= 'd0;
	else if(state=='d2)		cnt_row <= cnt_row + 'd1;
	
	if(state=='d4)			cnt_wait <= cnt_wait + 'd1;
	else					cnt_wait <= 'd0;
	
	if(i_rstp)				cnt_frame <= 'd0;
	else if(state=='d7)		cnt_frame <= cnt_frame + 'd1;
	
	if(i_rstp||state=='d7)	rd_addr <= 'd0;
	else if(rd_en)			rd_addr <= rd_addr + 'd1;
	
	if(i_rstp)				first_done <= 'd0;
	else if(rd_flag[1])		first_done <= 'd1;
end

always @(posedge i_sclk)
begin
	state_d1 <= state                          ;
	vsync    <= rstp_down|first_done&rd_flag[0];
	hsync    <= hsy                            ;
	valid    <= rd_data_vld                    ;
	tdata    <= rd_data                        ;
	
	if(state==2&&cnt_row<3||state==5)	hsy <= 'd1;
	else								hsy <= rd_flag[3];
end

always@(posedge i_sclk)
begin
	if(i_rstp)
	begin
		state <= 'd0;
	end
	else
	begin
	case(state)
	'd0:
		begin
			rd_en <= 'd0;
			if(rd_flag[4])				state <= 'd1;
			else						state <= state;
		end
	'd1:
		begin
			if(cnt_col==IMG_COL-1)
			begin
				rd_en <= 'd0;
				state <= 'd2;
			end
			else
			begin
				rd_en <= 'd1;
				state <= state;
			end
		end
	'd2:
		begin
			if(cnt_row==IMG_ROW-1)		state <= 'd7;
			else if(cnt_row<3)			state <= 'd3;
			else						state <= 'd4;
		end
	'd3:
		begin
			state <= 'd1;
		end
	'd4:
		begin
			if(cnt_wait==VESA_WAIT)		state <= 'd5;
			else						state <= state;
		end
	'd5:
		begin
			state <= 'd6;
		end
	'd6:
		begin
			state <= 'd1;
		end
	'd7:
		begin
			state <= 'd0;
		end
	default:state  <= 'd0;
	endcase
	end
end

xpm_memory_sdpram#(
	.ADDR_WIDTH_A            (16             ),// DECIMAL
	.ADDR_WIDTH_B            (16             ),// DECIMAL
	.AUTO_SLEEP_TIME         (0              ),// DECIMAL
	.BYTE_WRITE_WIDTH_A      (MEM_WIDTH      ),// DECIMAL
	.CASCADE_HEIGHT          (0              ),// DECIMAL
	.CLOCKING_MODE           ("common_clock" ),// String
	.ECC_MODE                ("no_ecc"       ),// String
	.MEMORY_INIT_FILE        ("none"         ),// String
	.MEMORY_INIT_PARAM       ("0"            ),// String
	.MEMORY_OPTIMIZATION     ("true"         ),// String
	.MEMORY_PRIMITIVE        ("auto"         ),// String
	.MEMORY_SIZE             (MEM_SIZE       ),// DECIMAL
	.MESSAGE_CONTROL         (0              ),// DECIMAL
	.READ_DATA_WIDTH_B       (MEM_WIDTH      ),// DECIMAL
	.READ_LATENCY_B          (1              ),// DECIMAL
	.READ_RESET_VALUE_B      ("0"            ),// String
	.RST_MODE_A              ("SYNC"         ),// String
	.RST_MODE_B              ("SYNC"         ),// String
	.SIM_ASSERT_CHK          (1              ),// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.USE_EMBEDDED_CONSTRAINT (0              ),// DECIMAL
	.USE_MEM_INIT            (0              ),// DECIMAL
	.WAKEUP_TIME             ("disable_sleep"),// String
	.WRITE_DATA_WIDTH_A      (MEM_WIDTH      ),// DECIMAL
	.WRITE_MODE_B            ("write_first"  )// String
)
xpm_memory_sdpram_inst (
	.dbiterrb                (dbiterrb       ),// 1-bit output: Status signal to indicate double bit error occurrence on the data output of port B.
	.doutb                   (rd_data        ),// READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.sbiterrb                (sbiterrb       ),// 1-bit output: Status signal to indicate single bit error occurrence on the data output of port B.
	.addra                   (wr_addr        ),// ADDR_WIDTH_A-bit input: Address for port A write operations.
	.addrb                   (rd_addr        ),// ADDR_WIDTH_B-bit input: Address for port B read operations.
	.clka                    (i_sclk         ),// 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
	.clkb                    (i_sclk         ),// 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
	.dina                    (i_image        ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.ena                     (i_image_vld    ),// 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
	.enb                     (rd_en          ),// 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
	.injectdbiterra          (injectdbiterra ),// 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.injectsbiterra          (injectsbiterra ),// 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
	.regceb                  (regceb         ),// 1-bit input: Clock Enable for the last register stage on the output data path.
	.rstb                    (i_rstp         ),// 1-bit input: Reset signal for the final port B output register stage. Synchronously resets output port doutb to the value specified by  parameter READ_RESET_VALUE_B.
	.sleep                   (sleep          ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea                     (i_image_vld    ) // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are
											   // used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to
											   // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);

endmodule
