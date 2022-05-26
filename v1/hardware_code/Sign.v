
module Sign#(
	parameter					WIDTH = 28
)(
	input	wire[WIDTH-1:0]		i_tdata ,
	output	wire[1:0]			o_tdata 
);

assign o_tdata = i_tdata==0 ? 'd0:(i_tdata[WIDTH-1] ? 2'b11:2'b01);

endmodule
