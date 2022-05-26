
module Reshape_MaxPool_L1#(
	parameter							WIDTH_D  = 27 ,
	parameter							WIDTH_A  = 10 ,
	parameter							SIZE     = 112,
	parameter							CHANNEL  = 32 ,
	parameter							THREAD   = 2  ,
	parameter							LEN      = 3  ,
	parameter							PAD      = 3  ,
	parameter							STEP     = 2  
)(
	input	wire						i_sclk ,
	
	input	wire						i_vsync,
	input	wire						i_hsync,
	input	wire						i_valid,
	input	wire[WIDTH_D*THREAD-1:0]	i_tdata,
	
	output	reg 						o_wrvld,
	output	reg [WIDTH_D*THREAD-1:0]	o_wrdat,
	output	reg [WIDTH_A-1:0]			o_wrcnt,
	output	reg 						o_rdreq,
	output	reg [WIDTH_A-1:0]			o_rdcnt,
	input	wire[WIDTH_D*THREAD-1:0]	i_rddat,
	
	output	reg 						o_vsync,
	output	reg 						o_hsync,
	output	reg 						o_reuse,
	output	reg 						o_valid,
	output	reg [WIDTH_D-1:0]			o_tdata
);

//----------------------------------------------//
//					PARAM						//
//----------------------------------------------//
parameter	SIZE_W = SIZE/STEP;
parameter	SIZE_R = SIZE_W*CHANNEL;
parameter	RDRDY  = SIZE_W*CHANNEL/STEP - 8;
//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
reg [7:0]					cnt_r;
reg [1:0]					cnt_rs;
reg [1:0]					cnt_cs;

reg [WIDTH_D*THREAD-1:0]	tdata;
reg 						wrvld;
reg [WIDTH_A-1:0]			wrcnt;
reg [WIDTH_D*THREAD-1:0]	wrdat;
reg 						wrhsy;
reg 						wrhsy_d1;

reg [3:0]					state,state_d1;
reg 						rdreq;
reg 						rdreq_o_d1;
reg [5:0]					rdcnt_1;
reg [WIDTH_A-1:0]			rdcnt_2;
reg [2:0]					rdcnt_t;
reg [5:0]					rdcnt_c;
reg [2:0]					rdcnt_t_d1,rdcnt_t_d2,rdcnt_t_d3;
reg 						rdhsy;
reg 						rdhsy_d1;
reg 						rdvld;
reg [WIDTH_D*THREAD-1:0]	rddat;

reg 						vsync;
reg 						hsync;
reg 						reuse;
//----------------------------------------------//
//					CODING						//
//----------------------------------------------//
always@(posedge i_sclk)
begin
	if(i_vsync)					cnt_r <= 'd0;
	else if(i_hsync)			cnt_r <= cnt_r + 'd1;
	
	if(i_vsync)					cnt_rs <= 'd0;
	else if(i_hsync)
	begin
		if(cnt_rs==STEP-1)		cnt_rs <= 'd0;
		else					cnt_rs <= cnt_rs + 'd1;
	end
	
	if(i_valid&&cnt_rs==STEP-1)
	begin
		if(cnt_cs==STEP-1)		cnt_cs <= 'd0;
		else					cnt_cs <= cnt_cs + 'd1;
	end
	else						cnt_cs <= 'd0;
end

always@(posedge i_sclk)
begin
	tdata <= i_tdata;
	wrdat <= tdata;
	
	if(cnt_cs==STEP-1&&cnt_r<SIZE)				wrvld <= 'd1;
	else										wrvld <= 'd0;
	
	if(i_hsync)									wrcnt <= 'd0;
	else if(wrvld)								wrcnt <= wrcnt + 'd1;
	
	if(i_vsync||state_d1=='d0&&state=='d1)		wrhsy <= 'd0;
	else if(wrvld&&wrcnt==RDRDY-1)				wrhsy <= 'd1;
end

always@(posedge i_sclk)
begin
	if(state=='d0||rdcnt_t==THREAD)				rdcnt_t <= 'd0;
	else if(rdcnt_1==SIZE_W-1)					rdcnt_t <= rdcnt_t + 'd1;
	
	if(state=='d0||rdcnt_c==CHANNEL)			rdcnt_c <= 'd0;
	else if(rdcnt_t==THREAD)					rdcnt_c <= rdcnt_c + 'd1;
	
	if(rdreq)									rdcnt_1 <= rdcnt_1 + 'd1;
	else										rdcnt_1 <= 'd0;
	
	if(state=='d0||rdcnt_c==CHANNEL)			rdcnt_2 <= 'd0;
	else if(rdcnt_t==THREAD)					rdcnt_2 <= rdcnt_2 + SIZE_W;
	
	if(state=='d2)
	begin
		if(rdcnt_t==THREAD&&rdcnt_c==CHANNEL-1)	rdhsy <= 'd0;
		else									rdhsy <= 'd1;
	end
	else										rdhsy <= 'd0;
	
end

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
			if(wrhsy)				state <= 'd1;
			else					state <= state;
		end
	'd1:
		begin
			if(rdcnt_1==SIZE_W-1)
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
			if(rdcnt_t==THREAD)		state <= 'd4;
			else					state <= 'd3;
		end
	'd3:
		begin
			state <= 'd1;
		end
	'd4:
		begin
			if(rdcnt_c==CHANNEL)	state <= 'd0;
			else					state <= 'd1;
		end
	
	default:state <= 'd0;
	endcase
	end
end

always@(posedge i_sclk)
begin
	state_d1   <= state;
	wrhsy_d1   <= wrhsy;
	rdhsy_d1   <= rdhsy;
	
	rdreq_o_d1 <= o_rdreq;
	rddat      <= i_rddat;
	rdcnt_t_d1 <= rdcnt_t;
	rdcnt_t_d2 <= rdcnt_t_d1;
	rdcnt_t_d3 <= rdcnt_t_d2;
	
	vsync      <= i_vsync;
	hsync      <= (state==1)&&(state_d1==0);
	reuse      <= (state==1)&&(state_d1==0)|rdhsy_d1;
	rdvld      <= rdreq_o_d1;
end

always@(posedge i_sclk)
begin
	o_wrvld <= wrvld;
	o_wrdat <= wrdat;
	o_wrcnt <= wrcnt;
	o_rdreq <= rdreq;
	o_rdcnt <= rdcnt_1 + rdcnt_2;
end

always@(posedge i_sclk)
begin
	o_vsync <= vsync;
	o_hsync <= hsync;
	o_reuse <= reuse;
	o_valid <= rdvld;
	
	if(i_vsync)	o_tdata <= 'd0;
	else if(rdvld)
	begin
		case(rdcnt_t_d3)
		'd0:     o_tdata <= rddat[WIDTH_D*1-1:0        ];
		'd1:     o_tdata <= rddat[WIDTH_D*2-1:WIDTH_D*1];
		default: o_tdata <= 'd0;
	endcase
	end
end

endmodule
