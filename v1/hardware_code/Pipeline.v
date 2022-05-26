`timescale 1ns / 1ps

module Pipeline#(
	parameter					DELAY   = 4'd0,
	parameter					GAP     = 6'd0,
	parameter					SIZE    = 56  ,
	parameter					CHANNEL = 64  ,
	parameter					PADWAIT = 234*3
)(
	input	wire				i_sclk ,
	input	wire				i_vsync,
	input	wire				i_hsync,
	
	output	wire				o_rdreq,
	output	reg 				o_vsync,
	output	wire				o_hsync,
	output	wire				o_reuse,
	output	reg 				o_valid
);

//----------------------------------------------//
//					PARAM						//
//----------------------------------------------//
parameter	COL = SIZE*CHANNEL;
//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
reg [7:0]			cnt_r;

reg [2:0]			state;
reg 				rd_en;
reg 				rd_en_dly;
// reg [DELAY+1:0]		rdreq;
reg [7:0]			rdcnt;

reg [5:0]			cnt_g;
reg [11:0]			cnt_p;
reg [15:0]			cnt_w;

reg 				reuse;
reg [GAP+1:0]		reuse_dly;
reg 				tail;
reg 				tail_dly;
//----------------------------------------------//
//					CODING						//
//----------------------------------------------//
assign o_rdreq = rd_en_dly;
assign o_hsync = cnt_r>0 ? i_hsync|tail:'d0;
assign o_reuse = cnt_r>0 ? i_hsync|tail|reuse_dly[GAP]:'d0;

always@(posedge i_sclk)
begin
	if(i_vsync)							cnt_r <= 'd0;
	else if(i_hsync)					cnt_r <= cnt_r + 'd1;
	
	if(rd_en)							rdcnt <= rdcnt + 'd1;
	else								rdcnt <= 'd0;
	
	if(rdcnt==SIZE-1&&cnt_p<CHANNEL)	cnt_p <= cnt_p + 'd1;
	else if(i_hsync||tail)				cnt_p <= 'd0;
	
	if(state=='d4)						cnt_w <= cnt_w + 'd1;
	else								cnt_w <= 'd0;
	
	if(state=='d3)						cnt_g <= cnt_g + 'd1;
	else								cnt_g <= 'd0;
end

always@(posedge i_sclk)
begin
	rd_en_dly <= rd_en;
	reuse_dly <= {reuse_dly[GAP:0],reuse};
	
	if((state==2||state==6)&&cnt_p<CHANNEL)	reuse <= 'd1;
	else									reuse <= 'd0;
	
	if(cnt_w==PADWAIT-1)					tail <= 'd1;
	else									tail <= 'd0;
	
	if(i_vsync)								tail_dly <= 'd0;
	else if(tail)							tail_dly <= 'd1;
end

always@(posedge i_sclk)
begin
	if(i_hsync&&state==0)	o_vsync <= 'd1;
	else					o_vsync <= 'd0;
	
	o_valid <= o_rdreq;
end

always@(posedge i_sclk)
begin
	if(i_vsync)
	begin
		state <= 'd0;
		rd_en <= 'd0;
	end
	else
	begin
	case(state)
	'd0:
		begin
			if(i_hsync)				state <= 'd1;
			else					state <= state;
		end
	'd1:
		begin
			if(i_hsync||!rd_en&&cnt_p>0&&cnt_p<CHANNEL)
			begin
				rd_en <= 'd1;
			end
			else if(rdcnt==SIZE-1)
			begin
				rd_en <= 'd0;
				state <= 'd2;
			end
		end
	'd2:
		begin
			if(cnt_p==CHANNEL)
			begin
				if(cnt_r==SIZE)		state <= 'd4;
				else				state <= 'd1;
			end
			else					state <= 'd3;
		end
	'd3:
		begin
			if(cnt_g==GAP)
			begin
				if(cnt_r==SIZE&&tail_dly)	state <= 'd5;
				else						state <= 'd1;
			end
			else							state <= state;
		end
	'd4:
		begin
			if(cnt_w==PADWAIT-1)	state <= 'd5;
			else					state <= state;
		end
	'd5:
		begin
			if(rdcnt==SIZE-1)
			begin
				rd_en <= 'd0;
				state <= 'd6;
			end
			else
			begin
				rd_en <= 'd1;
			end
		end
	'd6:
		begin
			if(cnt_p==CHANNEL)		state <= 'd0;
			else					state <= 'd3;
		end
	default:state <= 'd0;
	endcase
	end
end

endmodule
