
module Reuse_Data_L1#(
	parameter							WIDTH   = 8  ,
	parameter							CHANNEL = 1  ,
	parameter							SIZE    = 224,
	parameter							REUSE   = 32 ,
	parameter							LEN     = 7  ,
	parameter							PAD     = 3  ,
	parameter							STEP    = 2
)(
	input	wire						i_sclk ,
	
	input	wire						i_vsync,
	input	wire						i_hsync,
	input	wire						i_valid,
	input	wire[WIDTH*LEN-1:0]			i_tdata,
	
	output	reg 						o_wrvld,
	output	reg [WIDTH*LEN*LEN-1:0]		o_wrdat,
	output	reg [6:0]					o_wrcnt,
	output	reg 						o_rdreq,
	output	reg [6:0]					o_rdcnt,
	
	output	reg 						o_vsync,
	output	reg 						o_hsync,
	output	reg 						o_reuse,
	output	reg 						o_valid
);

//----------------------------------------------//
//					PARAM						//
//----------------------------------------------//
parameter	SIZE_W = SIZE/STEP;
parameter	RDRDY  = SIZE_W*CHANNEL/STEP;
//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
reg 						hsync_dly;
reg [PAD+1:0]				valid_dly;

reg [7:0]					cnt_r;
reg [1:0]					cnt_rs;
reg [1:0]					cnt_cs;

reg 						wrvld;
reg [6:0]					wrcnt;
reg [WIDTH*LEN*LEN-1:0]		wrdat;
reg 						wrhsy;

reg [3:0]					state;
reg 						rdreq;
reg [6:0]					rdcnt;
reg 						rdhsy;
reg [6:0]					cnt_p;
//----------------------------------------------//
//					CODING						//
//----------------------------------------------//
always@(posedge i_sclk)
begin
	o_wrvld <= wrvld;
	o_wrdat <= wrdat;
	o_wrcnt <= wrcnt;
	o_rdreq <= rdreq;
	o_rdcnt <= rdcnt;
	o_vsync <= i_vsync;
	o_hsync <= wrhsy;
	o_reuse <= wrhsy|rdhsy;
	o_valid <= o_rdreq;
end

always@(posedge i_sclk)
begin
	if(i_vsync)					cnt_r <= 'd0;
	else if(hsync_dly)			cnt_r <= cnt_r + 'd1;
	
	if(i_vsync)					cnt_rs <= 'd0;
	else if(hsync_dly&&cnt_r>=PAD&&cnt_r<SIZE+PAD)
	begin
		if(cnt_rs==STEP-1)		cnt_rs <= 'd0;
		else					cnt_rs <= cnt_rs + 'd1;
	end
	
	if(valid_dly[PAD-2]&&cnt_rs==STEP-1)
	begin
		if(cnt_cs==STEP-1)		cnt_cs <= 'd0;
		else					cnt_cs <= cnt_cs + 'd1;
	end
	else						cnt_cs <= 'd0;
end

always@(posedge i_sclk)
begin
	hsync_dly <= i_hsync;
	valid_dly <= {valid_dly[PAD:0],i_valid};
	
	if(cnt_cs==STEP-1)				wrvld <= 'd1;
	else							wrvld <= 'd0;
	
	if(i_hsync)						wrcnt <= 'd0;
	else if(wrvld)					wrcnt <= wrcnt + 'd1;
	
	if(wrcnt==RDRDY-1)				wrhsy <= wrvld;
	else							wrhsy <= 'd0;
	
	if(rdreq)						rdcnt <= rdcnt + 'd1;
	else							rdcnt <= 'd0;
	
	if(state=='d0)					cnt_p <= 'd0;
	else if(state=='d2)				cnt_p <= cnt_p + 'd1;
	
	if(state=='d2&&cnt_p<REUSE-1)	rdhsy <= 'd1;
	else							rdhsy <= 'd0;
end

genvar p;
generate
	for (p=0; p<LEN; p=p+1)
	begin
		always@(posedge i_sclk)
		begin
			if(cnt_rs==STEP-1&&(i_valid||valid_dly[PAD-2]))
				wrdat[WIDTH*LEN*(p+1)-1:WIDTH*LEN*p] <= {i_tdata[WIDTH*(p+1)-1:WIDTH*p],wrdat[WIDTH*LEN*(p+1)-1:WIDTH*LEN*p+WIDTH]};
			else
				wrdat[WIDTH*LEN*(p+1)-1:WIDTH*LEN*p] <= 'd0;
		end
	end
endgenerate


always@(posedge i_sclk)
begin
	if(i_vsync)
	begin
		state <= 'd0;
		rdreq <= 'd0;
	end
	else
	begin
	case(state)
	'd0:
		begin
			if(wrhsy)			state <= 'd1;
			else				state <= state;
		end
	'd1:
		begin
			if(rdcnt==SIZE_W-1)
			begin
				rdreq <= 'd0;
				state <= 'd2;
			end
			else
			begin
				rdreq <= 'd1;
			end
		end
	'd2:
		begin
			state <= 'd3;
		end
	'd3:
		begin
			if(cnt_p==REUSE)	state <= 'd0;
			else				state <= 'd1;
		end
	
	default:state <= 'd0;
	endcase
	end
end

endmodule
