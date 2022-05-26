`timescale 1ns / 1ps

module Group_33#(
	parameter						WIDTH_D = 27  ,
	parameter						SIZE    = 28  ,
	parameter						CHANNEL = 128 ,
	parameter						LEN     = 3   ,
	parameter						GAP     = 4'd0,
	parameter						PADWAIT = 21
)(
	input	wire					i_sclk        ,
	input	wire					i_vsync       ,
	input	wire					i_hsync       ,
	input	wire					i_reuse       ,
	input	wire					i_valid       ,
	input	wire[WIDTH_D-1:0]		i_tdata       ,

	output	reg 					o_vsync_c     ,
	output	reg 					o_hsync_c     ,
	output	reg 					o_reuse_c     ,
	output	reg 					o_valid_c     ,
	output	reg [2*LEN-1:0]			o_tdata_c     
);

//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
wire[1:0]							p3_rddat      ;
wire[1:0]							p3_rddat_r    ;

wire								p2_rdreq      ;
wire								p2_vsync      ;
wire								p2_hsync      ;
wire								p2_reuse      ;
wire								p2_valid      ;
wire[1:0]							p2_rddat      ;
wire[1:0]							p2_rddat_r    ;
wire								p2_full       ;
wire								p2_empty      ;

wire								p1_rdreq      ;
wire								p1_vsync      ;
wire								p1_hsync      ;
wire								p1_reuse      ;
wire								p1_valid      ;
wire[1:0]							p1_rddat      ;
wire[1:0]							p1_rddat_r    ;
wire								p1_full       ;
wire								p1_empty      ;
//----------------------------------------------//
//					CODING						//
//----------------------------------------------//
assign p3_rddat_r = i_valid  ? p3_rddat:'d0;
assign p2_rddat_r = p2_valid ? p2_rddat:'d0;
assign p1_rddat_r = p1_valid ? p1_rddat:'d0;

always@(posedge i_sclk)
begin
	o_vsync_c <= i_vsync;
	o_hsync_c <= p2_hsync;
	o_reuse_c <= p2_reuse;
	o_valid_c <= p2_valid;
	o_tdata_c <= {p3_rddat_r,p2_rddat_r,p1_rddat_r};
end
//----------------------------------------------//
//					SIGN						//
//----------------------------------------------//
Sign#(
	.WIDTH        (WIDTH_D        )
)Sign_3(
	.i_tdata      (i_tdata        ),
	.o_tdata      (p3_rddat       )
);
//----------------------------------------------//
//				PIPELING PADDING				//
//----------------------------------------------//
Pipeline#(
	.GAP          (GAP            ),
	.SIZE		  (SIZE           ),
	.CHANNEL      (CHANNEL        ),
	.PADWAIT      (PADWAIT        )
)Pipeline_R3(
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
)Pipeline_R2(
	.i_sclk    	  (i_sclk         ),
	.i_vsync   	  (i_vsync        ),
	.i_hsync   	  (p2_hsync       ),
	.o_rdreq      (p1_rdreq       ),
	.o_vsync      (p1_vsync       ),
	.o_hsync      (p1_hsync       ),
	.o_reuse      (p1_reuse       ),
	.o_valid      (p1_valid       )
);

fifo_bdata fifo_bdata_R2(
	.clk	      (i_sclk         ),  // input wire clk
	.rst	      (i_vsync        ),  // input wire rst
	.din	      (p3_rddat       ),  // input wire [1 : 0] din
	.wr_en	      (i_valid        ),  // input wire wr_en
	.rd_en	      (p2_rdreq       ),  // input wire rd_en
	.dout	      (p2_rddat       ),  // output wire [1 : 0] doutt
	.full	      (p2_full        ),  // output wire full
	.empty	      (p2_empty       )   // output wire empty
);
fifo_bdata fifo_bdata_R1(
	.clk	      (i_sclk         ),  // input wire clk
	.rst	      (i_vsync        ),  // input wire rst
	.din	      (p2_rddat       ),  // input wire [1 : 0] din
	.wr_en	      (p2_valid       ),  // input wire wr_en
	.rd_en	      (p1_rdreq       ),  // input wire rd_en
	.dout	      (p1_rddat       ),  // output wire [1 : 0] dout
	.full	      (p1_full        ),  // output wire full
	.empty	      (p1_empty       )   // output wire empty
);

endmodule
