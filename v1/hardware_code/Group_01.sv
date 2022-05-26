`timescale 1ns / 1ps

module Group_01#(
	parameter						WIDTH_D = 27,
	parameter						SIZE    = 56,
	parameter						CHANNEL = 64,
	parameter						LEN     = 3 ,
	parameter						PADWAIT = 21
)(
	input	wire					i_sclk      ,
	input	wire					i_vsync     ,
	input	wire					i_hsync     ,
	input	wire					i_reuse     ,
	input	wire					i_valid     ,
	input	wire[WIDTH_D-1:0]		i_tdata     ,
	
	output	reg 					o_vsync_cm  ,
	output	reg 					o_hsync_cm  ,
	output	reg 					o_reuse_cm  ,
	output	reg 					o_valid_cm  ,
	output	reg [2*LEN-1:0]			o_tdata_cm  ,
	
	output	reg 					o_vsync_g12 ,
	output	reg 					o_hsync_g12 ,
	output	reg 					o_reuse_g12 ,
	output	reg 					o_valid_g12 ,
	output	reg [WIDTH_D-1:0]		o_tdata_g12 ,
	
	output	reg 					o_vsync_g13 ,
	output	reg 					o_hsync_g13 ,
	output	reg 					o_reuse_g13 ,
	output	reg 					o_valid_g13 ,
	output	reg [WIDTH_D-1:0]		o_tdata_g13 ,
	
	output	reg 					o_vsync_g14 ,
	output	reg 					o_hsync_g14 ,
	output	reg 					o_reuse_g14 ,
	output	reg 					o_valid_g14 ,
	output	reg [WIDTH_D-1:0]		o_tdata_g14 
);

//----------------------------------------------//
//					SIGNALS						//
//----------------------------------------------//
wire[WIDTH_D-1:0]					p7_tdata_r  ;
wire[1:0]							s7_tdata_r  ;
wire[1:0]							s6_tdata_r  ;
wire[1:0]							s5_tdata_r  ;

wire								p6_rdreq    ;
wire								p6_vsync    ;
wire								p6_hsync    ;
wire								p6_reuse    ;
wire								p6_valid    ;
wire[WIDTH_D-1:0]					p6_rddat    ;
wire[WIDTH_D-1:0]					p6_rddat_r  ;
wire								p6_full     ;
wire								p6_empty    ;

wire								p5_rdreq    ;
wire								p5_vsync    ;
wire								p5_hsync    ;
wire								p5_reuse    ;
wire								p5_valid    ;
wire[WIDTH_D-1:0]					p5_rddat    ;
wire[WIDTH_D-1:0]					p5_rddat_r  ;
wire								p5_full     ;
wire								p5_empty    ;

wire								p4_rdreq    ;
wire								p4_vsync    ;
wire								p4_hsync    ;
wire								p4_reuse    ;
wire								p4_valid    ;
wire[WIDTH_D-1:0]					p4_rddat    ;
wire[WIDTH_D-1:0]					p4_rddat_r  ;
wire								p4_full     ;
wire								p4_empty    ;

wire								p3_rdreq    ;
wire								p3_vsync    ;
wire								p3_hsync    ;
wire								p3_reuse    ;
wire								p3_valid    ;
wire[WIDTH_D-1:0]					p3_rddat    ;
wire[WIDTH_D-1:0]					p3_rddat_r  ;
wire								p3_full     ;
wire								p3_empty    ;

wire								p2_rdreq    ;
wire								p2_vsync    ;
wire								p2_hsync    ;
wire								p2_reuse    ;
wire								p2_valid    ;
wire[WIDTH_D-1:0]					p2_rddat    ;
wire[WIDTH_D-1:0]					p2_rddat_r  ;
wire								p2_full     ;
wire								p2_empty    ;

wire								p1_rdreq    ;
wire								p1_vsync    ;
wire								p1_hsync    ;
wire								p1_reuse    ;
wire								p1_valid    ;
wire[WIDTH_D-1:0]					p1_rddat    ;
wire[WIDTH_D-1:0]					p1_rddat_r  ;
wire								p1_full     ;
wire								p1_empty    ;

reg [3:0]							p5_vsync_d  ;
reg [3:0]							p5_hsync_d  ;
reg [3:0]							p5_reuse_d  ;
reg [3:0]							p5_valid_d  ;
reg [WIDTH_D*4-1:0]					p5_rddat_r_d;

reg [9:0]							p3_vsync_d  ;
reg [9:0]							p3_hsync_d  ;
reg [9:0]							p3_reuse_d  ;
reg [9:0]							p3_valid_d  ;
reg [WIDTH_D*10-1:0]				p3_rddat_r_d;

reg [15:0]							p1_vsync_d  ;
reg [15:0]							p1_hsync_d  ;
reg [15:0]							p1_reuse_d  ;
reg [15:0]							p1_valid_d  ;
reg [WIDTH_D*16-1:0]				p1_rddat_r_d;

//----------------------------------------------//
//					CODING						//
//----------------------------------------------//
assign p7_tdata_r = i_valid  ? i_tdata :'d0;
assign p6_rddat_r = p6_valid ? p6_rddat:'d0;
assign p5_rddat_r = p5_valid ? p5_rddat:'d0;
assign p4_rddat_r = p4_valid ? p4_rddat:'d0;
assign p3_rddat_r = p3_valid ? p3_rddat:'d0;
assign p2_rddat_r = p2_valid ? p2_rddat:'d0;
assign p1_rddat_r = p1_valid ? p1_rddat:'d0;

always@(posedge i_sclk)
begin
	p5_vsync_d   <= {p5_vsync_d[2:0],p5_vsync};
	p5_hsync_d   <= {p5_hsync_d[2:0],p5_hsync};
	p5_reuse_d   <= {p5_reuse_d[2:0],p5_reuse};
	p5_valid_d   <= {p5_valid_d[2:0],p5_valid};
	p5_rddat_r_d <= {p5_rddat_r_d[WIDTH_D*3-1:0],p5_rddat_r};
	p3_vsync_d   <= {p3_vsync_d[8:0],p3_vsync};
	p3_hsync_d   <= {p3_hsync_d[8:0],p3_hsync};
	p3_reuse_d   <= {p3_reuse_d[8:0],p3_reuse};
	p3_valid_d   <= {p3_valid_d[8:0],p3_valid};
	p3_rddat_r_d <= {p3_rddat_r_d[WIDTH_D*9-1:0],p3_rddat_r};
	p1_vsync_d   <= {p1_vsync_d[14:0],p1_vsync};
	p1_hsync_d   <= {p1_hsync_d[14:0],p1_hsync};
	p1_reuse_d   <= {p1_reuse_d[14:0],p1_reuse};
	p1_valid_d   <= {p1_valid_d[14:0],p1_valid};
	p1_rddat_r_d <= {p1_rddat_r_d[WIDTH_D*15-1:0],p1_rddat_r};
end

always@(posedge i_sclk)
begin
	o_vsync_cm  <= i_vsync;
	o_hsync_cm  <= p6_hsync;
	o_reuse_cm  <= p6_reuse;
	o_valid_cm  <= p6_valid;
	o_tdata_cm  <= {s7_tdata_r,s6_tdata_r,s5_tdata_r};
	
	o_vsync_g12 <= i_vsync;
	o_hsync_g12 <= p5_hsync_d[3];
	o_reuse_g12 <= p5_reuse_d[3];
	o_valid_g12 <= p5_valid_d[3];
	o_tdata_g12 <= p5_rddat_r_d[WIDTH_D*4-1:WIDTH_D*3];
	
	o_vsync_g13 <= i_vsync;
	o_hsync_g13 <= p3_hsync_d[9];
	o_reuse_g13 <= p3_reuse_d[9];
	o_valid_g13 <= p3_valid_d[9];
	o_tdata_g13 <= p3_rddat_r_d[WIDTH_D*10-1:WIDTH_D*9];
	
	o_vsync_g14 <= i_vsync;
	o_hsync_g14 <= p1_hsync_d[15];
	o_reuse_g14 <= p1_reuse_d[15];
	o_valid_g14 <= p1_valid_d[15];
	o_tdata_g14 <= p1_rddat_r_d[WIDTH_D*16-1:WIDTH_D*15];
end

//----------------------------------------------//
//					SIGN						//
//----------------------------------------------//
Sign#(
	.WIDTH        (WIDTH_D        )
)Sign_7(
	.i_tdata      (p7_tdata_r     ),
	.o_tdata      (s7_tdata_r     )
);
Sign#(
	.WIDTH        (WIDTH_D        )
)Sign_6(
	.i_tdata      (p6_rddat_r     ),
	.o_tdata      (s6_tdata_r     )
);
Sign#(
	.WIDTH        (WIDTH_D        )
)Sign_5(
	.i_tdata      (p5_rddat_r     ),
	.o_tdata      (s5_tdata_r     )
);
//----------------------------------------------//
//				PIPELING PADDING				//
//----------------------------------------------//
Pipeline#(
	.SIZE		  (SIZE           ),
	.CHANNEL      (CHANNEL        ),
	.PADWAIT      (PADWAIT        )
)Pipeline_R6(
	.i_sclk    	  (i_sclk         ),
	.i_vsync   	  (i_vsync        ),
	.i_hsync   	  (i_hsync        ),
	.o_rdreq      (p6_rdreq       ),
	.o_vsync      (p6_vsync       ),
	.o_hsync      (p6_hsync       ),
	.o_reuse      (p6_reuse       ),
	.o_valid      (p6_valid       )
);
Pipeline#(
	.SIZE		  (SIZE           ),
	.CHANNEL      (CHANNEL        ),
	.PADWAIT      (PADWAIT        )
)Pipeline_R5(
	.i_sclk    	  (i_sclk         ),
	.i_vsync   	  (i_vsync        ),
	.i_hsync   	  (p6_hsync       ),
	.o_rdreq      (p5_rdreq       ),
	.o_vsync      (p5_vsync       ),
	.o_hsync      (p5_hsync       ),
	.o_reuse      (p5_reuse       ),
	.o_valid      (p5_valid       )
);
Pipeline#(
	.SIZE		  (SIZE           ),
	.CHANNEL      (CHANNEL        ),
	.PADWAIT      (PADWAIT        )
)Pipeline_R4(
	.i_sclk    	  (i_sclk         ),
	.i_vsync   	  (i_vsync        ),
	.i_hsync   	  (p5_hsync       ),
	.o_rdreq      (p4_rdreq       ),
	.o_vsync      (p4_vsync       ),
	.o_hsync      (p4_hsync       ),
	.o_reuse      (p4_reuse       ),
	.o_valid      (p4_valid       )
);
Pipeline#(
	.SIZE		  (SIZE           ),
	.CHANNEL      (CHANNEL        ),
	.PADWAIT      (PADWAIT        )
)Pipeline_R3(
	.i_sclk    	  (i_sclk         ),
	.i_vsync   	  (i_vsync        ),
	.i_hsync   	  (p4_hsync       ),
	.o_rdreq      (p3_rdreq       ),
	.o_vsync      (p3_vsync       ),
	.o_hsync      (p3_hsync       ),
	.o_reuse      (p3_reuse       ),
	.o_valid      (p3_valid       )
);
Pipeline#(
	.SIZE		  (SIZE           ),
	.CHANNEL      (CHANNEL        ),
	.PADWAIT      (PADWAIT        )
)Pipeline_R2(
	.i_sclk    	  (i_sclk         ),
	.i_vsync   	  (i_vsync        ),
	.i_hsync   	  (p3_hsync       ),
	.o_rdreq      (p2_rdreq       ),
	.o_vsync      (p2_vsync       ),
	.o_hsync      (p2_hsync       ),
	.o_reuse      (p2_reuse       ),
	.o_valid      (p2_valid       )
);
Pipeline#(
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

fifo_din_G0 fifo_din_G0_R6(
	.clk	      (i_sclk         ),  // input wire clk
	.rst	      (i_vsync        ),  // input wire rst
//	.din	      ({1'b0,i_tdata} ),  // input wire [35 : 0] din
    .din	      (i_tdata        ),
	.wr_en	      (i_valid        ),  // input wire wr_en
	.rd_en	      (p6_rdreq       ),  // input wire rd_en
	.dout	      (p6_rddat       ),  // output wire [35 : 0] dout
	.full	      (p6_full        ),  // output wire full
	.empty	      (p6_empty       )   // output wire empty
);
fifo_din_G0 fifo_din_G0_R5(
	.clk	      (i_sclk         ),  // input wire clk
	.rst	      (i_vsync        ),  // input wire rst
	.din	      (p6_rddat       ),  // input wire [35 : 0] din
	.wr_en	      (p6_valid       ),  // input wire wr_en
	.rd_en	      (p5_rdreq       ),  // input wire rd_en
	.dout	      (p5_rddat       ),  // output wire [35 : 0] dout
	.full	      (p5_full        ),  // output wire full
	.empty	      (p5_empty       )   // output wire empty
);
fifo_din_G0 fifo_din_G0_R4(
	.clk	      (i_sclk         ),  // input wire clk
	.rst	      (i_vsync        ),  // input wire rst
	.din	      (p5_rddat       ),  // input wire [35 : 0] din
	.wr_en	      (p5_valid       ),  // input wire wr_en
	.rd_en	      (p4_rdreq       ),  // input wire rd_en
	.dout	      (p4_rddat       ),  // output wire [35 : 0] dout
	.full	      (p4_full        ),  // output wire full
	.empty	      (p4_empty       )   // output wire empty
);
fifo_din_G0 fifo_din_G0_R3(
	.clk	      (i_sclk         ),  // input wire clk
	.rst	      (i_vsync        ),  // input wire rst
	.din	      (p4_rddat       ),  // input wire [35 : 0] din
	.wr_en	      (p4_valid       ),  // input wire wr_en
	.rd_en	      (p3_rdreq       ),  // input wire rd_en
	.dout	      (p3_rddat       ),  // output wire [35 : 0] dout
	.full	      (p3_full        ),  // output wire full
	.empty	      (p3_empty       )   // output wire empty
);
fifo_din_G0 fifo_din_G0_R2(
	.clk	      (i_sclk         ),  // input wire clk
	.rst	      (i_vsync        ),  // input wire rst
	.din	      (p3_rddat       ),  // input wire [35 : 0] din
	.wr_en	      (p3_valid       ),  // input wire wr_en
	.rd_en	      (p2_rdreq       ),  // input wire rd_en
	.dout	      (p2_rddat       ),  // output wire [35 : 0] dout
	.full	      (p2_full        ),  // output wire full
	.empty	      (p2_empty       )   // output wire empty
);
fifo_din_G0 fifo_din_G0_R1(
	.clk	      (i_sclk         ),  // input wire clk
	.rst	      (i_vsync        ),  // input wire rst
	.din	      (p2_rddat       ),  // input wire [35 : 0] din
	.wr_en	      (p2_valid       ),  // input wire wr_en
	.rd_en	      (p1_rdreq       ),  // input wire rd_en
	.dout	      (p1_rddat       ),  // output wire [35 : 0] dout
	.full	      (p1_full        ),  // output wire full
	.empty	      (p1_empty       )   // output wire empty
);

endmodule
