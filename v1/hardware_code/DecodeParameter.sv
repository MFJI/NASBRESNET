`timescale 1ns / 1ps

module DecodeParameter#(
	parameter					WIDTH_P = 32,
	parameter					WIDTH_O = 10
)(
	input	wire				i_sclk          ,
	input	wire				i_rstp          ,

	output	wire				o_ready         ,
	input	wire				i_valid         ,
	input	wire[WIDTH_P-1:0]	i_tdata         ,

	output	reg [84:0]			o_param_vld     ,
	output	reg [59:0]			o_param         ,

	input	wire				i_predict_vld   ,
	input	wire[9:0]			i_predict       ,

	input	wire				i_ready         ,
	output	wire				o_valid         ,
	output	wire[WIDTH_O-1:0]	o_tdata         
);

//----------------------------------------------//
//					PARAMETER					//
//----------------------------------------------//
parameter	LEN_CONV_L1     = 7*7*64            ;
parameter	LEN_BNB_L1      = 64                ;
parameter	LEN_BNB_DS_G0   = 64                ;
parameter	LEN_BNB_OPS0_G0 = 64                ;
parameter	LEN_BNB0_G0     = 64                ;
parameter	LEN_BNB1_G0     = 64                ;
parameter	LEN_BNB2_G0     = 64                ;
parameter	LEN_BNB3_G0     = 64                ;
parameter	LEN_BNB_DS_G1   = 128               ;
parameter	LEN_BNB_OPS0_G1 = 128               ;
parameter	LEN_BNB_OPS3_G1 = 128               ;
parameter	LEN_BNB0_G1     = 128               ;
parameter	LEN_BNB1_G1     = 128               ;
parameter	LEN_BNB2_G1     = 128               ;
parameter	LEN_BNB3_G1     = 128               ;
parameter	LEN_BNB_DS_G2   = 256               ;
parameter	LEN_BNB_OPS0_G2 = 256               ;
parameter	LEN_BNB_OPS1_G2 = 256               ;
parameter	LEN_BNB_OPS3_G2 = 256               ;
parameter	LEN_BNB0_G2     = 256               ;
parameter	LEN_BNB1_G2     = 256               ;
parameter	LEN_BNB2_G2     = 256               ;
parameter	LEN_BNB3_G2     = 256               ;
parameter	LEN_BNB_DS_G3   = 512               ;
parameter	LEN_BNB_OPS0_G3 = 512               ;
parameter	LEN_BNB_OPS1_G3 = 512               ;
parameter	LEN_BNB_OPS2_G3 = 512               ;
parameter	LEN_BNB0_G3     = 512               ;
parameter	LEN_BNB1_G3     = 512               ;
parameter	LEN_BNB2_G3     = 512               ;
parameter	LEN_BNB3_G3     = 512               ;
parameter	LEN_BNA_L1      = 64                ;
parameter	LEN_BNA_DS_G0   = 64                ;
parameter	LEN_BNA_OPS0_G0 = 64                ;
parameter	LEN_BNA0_G0     = 64                ;
parameter	LEN_BNA1_G0     = 64                ;
parameter	LEN_BNA2_G0     = 64                ;
parameter	LEN_BNA3_G0     = 64                ;
parameter	LEN_BNA_DS_G1   = 128               ;
parameter	LEN_BNA_OPS0_G1 = 128               ;
parameter	LEN_BNA_OPS3_G1 = 128               ;
parameter	LEN_BNA0_G1     = 128               ;
parameter	LEN_BNA1_G1     = 128               ;
parameter	LEN_BNA2_G1     = 128               ;
parameter	LEN_BNA3_G1     = 128               ;
parameter	LEN_BNA_DS_G2   = 256               ;
parameter	LEN_BNA_OPS0_G2 = 256               ;
parameter	LEN_BNA_OPS1_G2 = 256               ;
parameter	LEN_BNA_OPS3_G2 = 256               ;
parameter	LEN_BNA0_G2     = 256               ;
parameter	LEN_BNA1_G2     = 256               ;
parameter	LEN_BNA2_G2     = 256               ;
parameter	LEN_BNA3_G2     = 256               ;
parameter	LEN_BNA_DS_G3   = 512               ;
parameter	LEN_BNA_OPS0_G3 = 512               ;
parameter	LEN_BNA_OPS1_G3 = 512               ;
parameter	LEN_BNA_OPS2_G3 = 512               ;
parameter	LEN_BNA0_G3     = 512               ;
parameter	LEN_BNA1_G3     = 512               ;
parameter	LEN_BNA2_G3     = 512               ;
parameter	LEN_BNA3_G3     = 512               ;
parameter	LEN_DS_W_G0     = 64*64             ;
parameter	LEN_BCONV0_G0   = 64*64             ;
parameter	LEN_BCONV1_G0   = 64*64             ;
parameter	LEN_BCONV2_G0   = 64*64             ;
parameter	LEN_BCONV3_G0   = 64*64             ;
parameter	LEN_DS_W_G1     = 64*128            ;
parameter	LEN_BCONV0_G1   = 64*128            ;
parameter	LEN_BCONV1_G1   = 128*128           ;
parameter	LEN_BCONV2_G1   = 128*128           ;
parameter	LEN_BCONV3_G1   = 128*128           ;
parameter	LEN_DS_W_G2     = 128*256           ;
parameter	LEN_BCONV0_G2   = 128*256           ;
parameter	LEN_BCONV1_G2   = 256*256           ;
parameter	LEN_BCONV2_G2   = 256*256           ;
parameter	LEN_BCONV3_G2   = 256*256           ;
parameter	LEN_DS_W_G3     = 256*512           ;
parameter	LEN_BCONV0_G3   = 256*512           ;
parameter	LEN_BCONV1_G3   = 512*512           ;
parameter	LEN_BCONV2_G3   = 512*512           ;
parameter	LEN_BCONV3_G3   = 512*512           ;
parameter	LEN_FC_W        = 512*1000          ;
parameter	LEN_FC_B        = 1000              ;
parameter	LEN_WEIGHT_E    = 8                 ;
parameter	LEN_IMAGE       = 224*224           ;

parameter	LEN_BNA         = 468               ;
parameter	LEN_BNB         = LEN_BNA*2 + 392   ;
parameter	LEN_CW          = 87764             ;
parameter	LEN_TOTAL       = 124291            ;

//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
reg 								wr_rdy      ;
reg 								wr_vld      ;
reg [WIDTH_P-1:0]					wr_para     ;
reg 								wr_vld_d1   ;

reg [6:0]							state       ;
reg [6:0]							state_d1    ;

reg 								data_8_vld  ;
reg [63:0]							data_8      ;
reg 								data_4_vld  ;
reg [31:0]							data_4      ;

reg [84:0]							param_vld   ;
reg [23:0]							param_cnt   ;
reg [59:0]							param       ;

reg 								rd_vld      ;
reg [WIDTH_O-1:0]					rd_data     ;
//----------------------------------------------//
//					CODING						//
//----------------------------------------------//
assign o_ready = wr_rdy;
assign o_valid = rd_vld;
assign o_tdata = rd_data;

always@(posedge i_sclk)
begin
	if(i_rstp||o_valid&&i_ready)	rd_vld <= 'd0;
	else if(i_predict_vld)			rd_vld <= 'd1;
	
	if(i_rstp)						rd_data <= 'd0;
	else if(i_predict_vld)			rd_data <= i_predict;
end

always@(posedge i_sclk)
begin
	wr_vld    <= i_valid&o_ready;
	wr_vld_d1 <= wr_vld;
	data_8    <= {data_8[31:0],wr_para};
	data_4    <= wr_para;
	
	if(i_rstp||state==84&&param_cnt==LEN_IMAGE-3)	wr_rdy <= 'd0;
	else if(state==0||i_predict_vld)				wr_rdy <= 'd1;

	if(i_rstp)										wr_para <= 'd0;
	else if(i_valid&o_ready)						wr_para <= i_tdata;

	if(wr_vld_d1&&state_d1<='d30)					data_8_vld <= ~data_8_vld;
	else											data_8_vld <= 'd0;
	
	if(state>'d30)									data_4_vld <= wr_vld;
	else											data_4_vld <= 'd0;
end

always @(posedge i_sclk)
begin
	state_d1 <= state;
	
	if(data_8_vld)	param <= data_8;
	else			param <= data_4;
	
	if(i_rstp||state_d1==30&&state==31)		param_cnt <= 'd0;
	else if(|param_vld)
	begin
		if(state==state_d1+1)				param_cnt <= 'd0;
		else								param_cnt <= param_cnt + 'd1;
	end
	
	if(state_d1<='d30)
	begin
		if(data_8_vld)	param_vld[state_d1] <= 'd1;
		else			param_vld <= 'd0;
	end
	else if(data_4_vld)
	begin
		param_vld[state_d1-1] <= 'd0;
		param_vld[state_d1] <= 'd1;
	end
	else				param_vld <= 'd0;
end

always @(posedge i_sclk)
begin
	o_param_vld[ 2: 0] <= {param_vld[ 1: 1],param_vld[31:31],param_vld[ 0: 0]};
	o_param_vld[19: 3] <= {param_vld[ 7: 2],param_vld[37:32],param_vld[65:61]};
	o_param_vld[38:20] <= {param_vld[14: 8],param_vld[44:38],param_vld[70:66]};
	o_param_vld[59:39] <= {param_vld[22:15],param_vld[52:45],param_vld[75:71]};
	o_param_vld[80:60] <= {param_vld[30:23],param_vld[60:53],param_vld[80:76]};
	o_param_vld[84:81] <= param_vld[84:81];//{image,weight_e,fc_b,fc_w}
	o_param            <= param;
end

always @(posedge i_sclk)
begin
	if(i_rstp)	state <= 'd0;
	else
	begin
		case(state)
		'd0:
			begin
				if(data_8_vld&&param_cnt==LEN_CONV_L1-1)		state <= state + 'd1;
				else											state <= state;
			end
		'd1:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB_L1-1)			state <= state + 'd1;
				else											state <= state;
			end
		'd2:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB_DS_G0-1)		state <= state + 'd1;
				else											state <= state;
			end
		'd3:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB_OPS0_G0-1)	state <= state + 'd1;
				else											state <= state;
			end
		'd4:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB0_G0-1)		state <= state + 'd1;
				else											state <= state;
			end
		'd5:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB1_G0-1)		state <= state + 'd1;
				else											state <= state;
			end
		'd6:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB2_G0-1)		state <= state + 'd1;
				else											state <= state;
			end
		'd7:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB3_G0-1)		state <= state + 'd1;
				else											state <= state;
			end
		'd8:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB_DS_G1-1)		state <= state + 'd1;
				else											state <= state;
			end
		'd9:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB_OPS0_G1-1)	state <= state + 'd1;
				else											state <= state;
			end
		'd10:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB_OPS3_G1-1)	state <= state + 'd1;
				else											state <= state;
			end
		'd11:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB0_G1-1)		state <= state + 'd1;
				else											state <= state;
			end
		'd12:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB1_G1-1)		state <= state + 'd1;
				else											state <= state;
			end
		'd13:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB2_G1-1)		state <= state + 'd1;
				else											state <= state;
			end
		'd14:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB3_G1-1)		state <= state + 'd1;
				else											state <= state;
			end
		'd15:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB_DS_G2-1)		state <= state + 'd1;
				else											state <= state;
			end
		'd16:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB_OPS0_G2-1)	state <= state + 'd1;
				else											state <= state;
			end
		'd17:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB_OPS1_G2-1)	state <= state + 'd1;
				else											state <= state;
			end
		'd18:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB_OPS3_G2-1)	state <= state + 'd1;
				else											state <= state;
			end
		'd19:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB0_G2-1)		state <= state + 'd1;
				else											state <= state;
			end
		'd20:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB1_G2-1)		state <= state + 'd1;
				else											state <= state;
			end
		'd21:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB2_G2-1)		state <= state + 'd1;
				else											state <= state;
			end
		'd22:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB3_G2-1)		state <= state + 'd1;
				else											state <= state;
			end
		'd23:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB_DS_G3-1)		state <= state + 'd1;
				else											state <= state;
			end
		'd24:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB_OPS0_G3-1)	state <= state + 'd1;
				else											state <= state;
			end
		'd25:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB_OPS1_G3-1)	state <= state + 'd1;
				else											state <= state;
			end
		'd26:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB_OPS2_G3-1)	state <= state + 'd1;
				else											state <= state;
			end
		'd27:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB0_G3-1)		state <= state + 'd1;
				else											state <= state;
			end
		'd28:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB1_G3-1)		state <= state + 'd1;
				else											state <= state;
			end
		'd29:
			begin
				if(data_8_vld&&param_cnt==LEN_BNB2_G3-1)		state <= state + 'd1;
				else											state <= state;
			end
		'd30:
			begin
				if(param_vld[state]&&param_cnt==LEN_BNB3_G3-2)	state <= state + 'd1;
				else											state <= state;
			end
		'd31:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA_L1-2)			state <= state + 'd1;
				else											state <= state;
			end
		'd32:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA_DS_G0-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd33:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA_OPS0_G0-2)	state <= state + 'd1;
				else											state <= state;
			end
		'd34:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA0_G0-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd35:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA1_G0-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd36:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA2_G0-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd37:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA3_G0-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd38:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA_DS_G1-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd39:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA_OPS0_G1-2)	state <= state + 'd1;
				else											state <= state;
			end
		'd40:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA_OPS3_G1-2)	state <= state + 'd1;
				else											state <= state;
			end
		'd41:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA0_G1-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd42:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA1_G1-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd43:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA2_G1-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd44:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA3_G1-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd45:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA_DS_G2-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd46:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA_OPS0_G2-2)	state <= state + 'd1;
				else											state <= state;
			end
		'd47:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA_OPS1_G2-2)	state <= state + 'd1;
				else											state <= state;
			end
		'd48:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA_OPS3_G2-2)	state <= state + 'd1;
				else											state <= state;
			end
		'd49:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA0_G2-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd50:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA1_G2-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd51:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA2_G2-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd52:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA3_G2-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd53:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA_DS_G3-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd54:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA_OPS0_G3-2)	state <= state + 'd1;
				else											state <= state;
			end
		'd55:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA_OPS1_G3-2)	state <= state + 'd1;
				else											state <= state;
			end
		'd56:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA_OPS2_G3-2)	state <= state + 'd1;
				else											state <= state;
			end
		'd57:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA0_G3-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd58:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA1_G3-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd59:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA2_G3-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd60:
			begin
				if(data_4_vld&&param_cnt==LEN_BNA3_G3-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd61:
			begin
				if(data_4_vld&&param_cnt==LEN_DS_W_G0-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd62:
			begin
				if(data_4_vld&&param_cnt==LEN_BCONV0_G0-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd63:
			begin
				if(data_4_vld&&param_cnt==LEN_BCONV1_G0-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd64:
			begin
				if(data_4_vld&&param_cnt==LEN_BCONV2_G0-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd65:
			begin
				if(data_4_vld&&param_cnt==LEN_BCONV3_G0-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd66:
			begin
				if(data_4_vld&&param_cnt==LEN_DS_W_G1-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd67:
			begin
				if(data_4_vld&&param_cnt==LEN_BCONV0_G1-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd68:
			begin
				if(data_4_vld&&param_cnt==LEN_BCONV1_G1-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd69:
			begin
				if(data_4_vld&&param_cnt==LEN_BCONV2_G1-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd70:
			begin
				if(data_4_vld&&param_cnt==LEN_BCONV3_G1-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd71:
			begin
				if(data_4_vld&&param_cnt==LEN_DS_W_G2-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd72:
			begin
				if(data_4_vld&&param_cnt==LEN_BCONV0_G2-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd73:
			begin
				if(data_4_vld&&param_cnt==LEN_BCONV1_G2-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd74:
			begin
				if(data_4_vld&&param_cnt==LEN_BCONV2_G2-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd75:
			begin
				if(data_4_vld&&param_cnt==LEN_BCONV3_G2-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd76:
			begin
				if(data_4_vld&&param_cnt==LEN_DS_W_G3-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd77:
			begin
				if(data_4_vld&&param_cnt==LEN_BCONV0_G3-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd78:
			begin
				if(data_4_vld&&param_cnt==LEN_BCONV1_G3-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd79:
			begin
				if(data_4_vld&&param_cnt==LEN_BCONV2_G3-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd80:
			begin
				if(data_4_vld&&param_cnt==LEN_BCONV3_G3-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd81:
			begin
				if(data_4_vld&&param_cnt==LEN_FC_W-2)			state <= state + 'd1;
				else											state <= state;
			end
		'd82:
			begin
				if(data_4_vld&&param_cnt==LEN_FC_B-2)			state <= state + 'd1;
				else											state <= state;
			end
		'd83:
			begin
				if(data_4_vld&&param_cnt==LEN_WEIGHT_E-2)		state <= state + 'd1;
				else											state <= state;
			end
		'd84:
			begin
				if(data_4_vld&&param_cnt==LEN_IMAGE-2)			state <= state + 'd1;
				else											state <= state;
			end
		'd85:
			begin
				if(i_predict_vld)								state <= state - 'd1;
				else											state <= state;
			end
		
		endcase
	end
end

endmodule
