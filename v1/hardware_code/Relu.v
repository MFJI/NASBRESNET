
module Relu#(
	parameter							WIDTH = 28
)(
	input	wire[WIDTH-1:0]				i_tdata ,
	output	wire[WIDTH-2:0]				o_tdata 
);

assign o_tdata = i_tdata[WIDTH-1] ? 'd0:i_tdata;

endmodule
