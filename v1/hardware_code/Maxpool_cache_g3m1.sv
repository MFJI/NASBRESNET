`timescale 1ns / 1ps

module Maxpool_cache_g3m1#(
	parameter							WIDTH_D = 27  ,
	parameter							SIZE    = 14  ,
	parameter							CHANNEL = 256 ,
	parameter							GAP     = 4'd0,
	parameter							PADWAIT = 21
)(
	input	wire						i_sclk      ,
	input	wire						i_vsync     ,
	input	wire						i_hsync     ,
	input	wire						i_reuse     ,
	input	wire						i_valid     ,
	input	wire[WIDTH_D-1:0]			i_tdata     ,
	
	output	reg 						o_vsync     ,
	output	reg 						o_hsync     ,
	output	reg 						o_reuse     ,
	output	reg 						o_valid     ,
	output	reg [WIDTH_D-1:0]			o_tdata     
);

//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
wire[WIDTH_D-1:0]					p3_tdata_r ;

wire								p2_rdreq   ;
wire								p2_vsync   ;
wire								p2_hsync   ;
wire								p2_reuse   ;
wire								p2_valid   ;
wire[75:0]							p2_rddat   ;
wire[WIDTH_D-1:0]					p2_rddat_r ;
wire								p2_full    ;
wire								p2_empty   ;

wire								p1_rdreq   ;
wire								p1_vsync   ;
wire								p1_hsync   ;
wire								p1_reuse   ;
wire								p1_valid   ;
wire[75:0]							p1_rddat   ;
wire[WIDTH_D-1:0]					p1_rddat_r ;
wire								p1_full    ;
wire								p1_empty   ;

reg [7:0]							p1_vsync_d   ;
reg [7:0]							p1_hsync_d   ;
reg [7:0]							p1_reuse_d   ;
reg [7:0]							p1_valid_d   ;
reg [WIDTH_D*8-1:0]					p1_rddat_r_d ;

//----------------------------------------------//
//					CODING						//
//----------------------------------------------//
assign p3_tdata_r = i_valid  ? i_tdata :'d0;
assign p2_rddat_r = p2_valid ? p2_rddat:'d0;
assign p1_rddat_r = p1_valid ? p1_rddat:'d0;

always@(posedge i_sclk)
begin
	p1_vsync_d   <= {p1_vsync_d[6:0],p1_vsync};
	p1_hsync_d   <= {p1_hsync_d[6:0],p1_hsync};
	p1_reuse_d   <= {p1_reuse_d[6:0],p1_reuse};
	p1_valid_d   <= {p1_valid_d[6:0],p1_valid};
	p1_rddat_r_d <= {p1_rddat_r_d[WIDTH_D*7-1:0],p1_rddat_r};
end

always@(posedge i_sclk)
begin
	o_vsync <= i_vsync;
	o_vsync <= p1_vsync_d[7];
	o_hsync <= p1_hsync_d[7];
	o_reuse <= p1_reuse_d[7];
	o_valid <= p1_valid_d[7];
	o_tdata <= p1_rddat_r_d[WIDTH_D*8-1:WIDTH_D*7];
end

//----------------------------------------------//
//				PIPELING PADDING				//
//----------------------------------------------//
Pipeline#(
	.GAP          (GAP            ),
	.SIZE		  (SIZE           ),
	.CHANNEL      (CHANNEL        ),
	.PADWAIT      (PADWAIT        )
)Pipeline_R2(
	.i_sclk    	  (i_sclk         ),
	.i_vsync   	  (i_vsync        ),
	.i_hsync   	  (i_hsync        ),
	.o_rdreq      (p2_rdreq       ),
	.o_vsync      (p2_vsync       ),
	.o_hsync      (p2_hsync       ),
	.o_reuse      (p2_reuse       ),
	.o_valid      (p2_valid       )
);
Pipeline#(
	.GAP          (GAP            ),
	.SIZE		  (SIZE           ),
	.CHANNEL      (CHANNEL        ),
	.PADWAIT      (PADWAIT        )
)Pipeline_R1(
	.i_sclk    	  (i_sclk         ),
	.i_vsync   	  (i_vsync        ),
	.i_hsync   	  (p2_hsync       ),
	.o_rdreq      (p1_rdreq       ),
	.o_vsync      (p1_vsync       ),
	.o_hsync      (p1_hsync       ),
	.o_reuse      (p1_reuse       ),
	.o_valid      (p1_valid       )
);

fifo_din_G31 fifo_din_G31_R2(
	.clk	      (i_sclk         ),  // input wire clk
	.rst	      (i_vsync        ),  // input wire rst
	.din	      ({3'd0,i_tdata} ),  // input wire [75 : 0] din
	.wr_en	      (i_valid        ),  // input wire wr_en
	.rd_en	      (p2_rdreq       ),  // input wire rd_en
	.dout	      (p2_rddat       ),  // output wire [75 : 0] dout
	.full	      (p2_full        ),  // output wire full
	.empty	      (p2_empty       )   // output wire empty
);
fifo_din_G31 fifo_din_G31_R1(
	.clk	      (i_sclk         ),  // input wire clk
	.rst	      (i_vsync        ),  // input wire rst
	.din	      (p2_rddat       ),  // input wire [75 : 0] din
	.wr_en	      (p2_valid       ),  // input wire wr_en
	.rd_en	      (p1_rdreq       ),  // input wire rd_en
	.dout	      (p1_rddat       ),  // output wire [75 : 0] dout
	.full	      (p1_full        ),  // output wire full
	.empty	      (p1_empty       )   // output wire empty
);

endmodule
