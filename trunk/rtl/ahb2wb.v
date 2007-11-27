// =============================================================================
//                         FILE DETAILS
// Project          : mctrl
// Author           : Andy Newton
// File             : ahb2wb.v
// Title            : AHB to WISHBONE
// Dependency       : amba.v
// Version          : 0.1
// Last modified		: 25 Nov 2007
// =============================================================================
//Log:
//Created by Andy on 25 Nov 2007
//Major changes:	
//month,date,year:Line xxx:add/delete/modified:descriptions

/////////////////////////////////////////////////////
// Module interface
/////////////////////////////////////////////////////
//synopsys translate_off
`timescale 1ns / 1ps
//synopsys translate_on

module ahb2wb(
	clk,rst_n,
	//----------AHB-------------
	ahbsi_hsel, ahbsi_haddr, ahbsi_hwrite, ahbsi_htrans, ahbsi_hsize,
	ahbsi_hburst,	ahbsi_hwdata,	
	
	ahbso_hready,	ahbso_hresp, ahbso_hrdata,
	//----------WB------------
	wb_adr_i, wb_dat_i, wb_cyc_i, wb_sel_i,
	wb_stb_i, wb_we_i, wb_bte_i, wb_cti_i,
	
	wb_ack_o, wb_err_o, wb_rty_o, wb_dat_o
	);
/////////////////////////////////////////////////////
// Parameters
/////////////////////////////////////////////////////
	`include "../include/amba.v"
	`include "../include/wishbone.v"
	`include "../include/fun.v"
	
	parameter idle=0;
	parameter busy=1;

/////////////////////////////////////////////////////
// Functions and tasks
/////////////////////////////////////////////////////
//optional

	input clk,rst_n;
	
/////////////////////////////////////////////////////
// AHB I/O
/////////////////////////////////////////////////////
	input ahbso_hready;
	input [1:0]ahbso_hresp;
	input [31:0]ahbso_hrdata;
	output reg ahbsi_hsel,ahbsi_hwrite;
	output reg[31:0]ahbsi_haddr,ahbsi_hwdata;
	output reg[1:0]ahbsi_htrans;
	output reg[2:0]ahbsi_hsize,ahbsi_hburst;
	

/////////////////////////////////////////////////////
// WISHBONE I/O
/////////////////////////////////////////////////////
	input [31:0]wb_adr_i,wb_dat_i;
	input wb_cyc_i,wb_stb_i,wb_we_i;
	input [2:0]wb_cti_i;
	input [1:0]wb_bte_i;
	input [3:0]wb_sel_i;
	
	output reg[31:0]wb_dat_o;
	output reg wb_ack_o,wb_err_o,wb_rty_o;

/////////////////////////////////////////////////////
// Internal nets and registers 
/////////////////////////////////////////////////////
	reg sm,decode_err;
	reg [1:0]sel2adr;
	reg [31:0]adr_a,adr_u,adr_4,adr_8,adr_16;
	reg [WB_LBURST_MSB:0]ahbsi_haddr_r;
	reg [2:0]ahbsi_hsize_r;
	
/////////////////////////////////////////////////////
// Instances
/////////////////////////////////////////////////////
//optional

/////////////////////////////////////////////////////
// Sequential logic
/////////////////////////////////////////////////////
	always@(posedge clk)
		if(!rst_n)
		begin
			sm<=idle;
			ahbsi_hsize_r<=3'bx;
		end
		else
		begin
			if((sm==busy && (wb_cti_i==WBCTI_CLASSIC || wb_cti_i==WBCTI_ENDBURST) && ahbso_hready) || decode_err)
				sm<=idle;
			else if(wb_cyc_i && (sm==busy || wb_stb_i) && !decode_err)
				sm<=busy;
				
			if(sm==idle)
				ahbsi_hsize_r<=ahbsi_hsize;
				
			if(ahbso_hready && (ahbsi_htrans==HTRANS_NONSEQ || ahbsi_htrans==HTRANS_SEQ))
				ahbsi_haddr_r<=ahbsi_haddr[WB_LBURST_MSB:0];
		end

/////////////////////////////////////////////////////
// Combinational logic
/////////////////////////////////////////////////////
	always@(*)
	begin
		decode_err=wb_sel_i==4'b1110 || wb_sel_i==4'b1101 || wb_sel_i==4'b1011 || wb_sel_i==4'b0111 || 
								wb_sel_i==4'b0110 || wb_sel_i==4'b1001 || wb_sel_i==4'b1010 || wb_sel_i==4'b0101 ||
								(wb_sel_i==4'b1111 && wb_adr_i[1:0]!=2'b0) || (wb_sel_i==4'b1100 && wb_adr_i[0]!=1'b0) ||
								(wb_sel_i==4'b0011 && wb_adr_i[0]!=1'b0);
								
		//synopsys translate_off
		if(detect_x(wb_adr_i,32))
			decode_err=1'b0;
		//synopsys translate_on
						
		case(wb_sel_i)
			4'b1111,4'b0011,4'b0001:	
												sel2adr=2'b00;
			4'b1100,4'b0100:	sel2adr=2'b10;
			4'b0010:					sel2adr=2'b01;
			4'b1000:					sel2adr=2'b11;
			default:					sel2adr=2'b00;
		endcase
		
		case(wb_sel_i)
			4'b1111:	ahbsi_hsize=HSIZE_WORD;
			4'b0011,4'b1100:
								ahbsi_hsize=HSIZE_HWORD;
			default:	ahbsi_hsize=HSIZE_BYTE;
		endcase
			
		adr_a={wb_adr_i[31:2],sel2adr};
		
		case(ahbsi_hsize_r)
			HSIZE_BYTE:		adr_u={wb_adr_i[31:WB_LBURST_MSB+1],ahbsi_haddr_r[WB_LBURST_MSB:0]+1'b1};
			HSIZE_HWORD:	adr_u={wb_adr_i[31:WB_LBURST_MSB+1],ahbsi_haddr_r[WB_LBURST_MSB:1]+1'b1,1'b0};
			HSIZE_WORD:		adr_u={wb_adr_i[31:WB_LBURST_MSB+1],ahbsi_haddr_r[WB_LBURST_MSB:2]+1'b1,2'b0};
			default:			adr_u={wb_adr_i[31:WB_LBURST_MSB+1],ahbsi_haddr_r[WB_LBURST_MSB:2]+1'b1,2'b0};
		endcase
		
		case(ahbsi_hsize_r)
			HSIZE_BYTE:		adr_4={wb_adr_i[31:2],ahbsi_haddr_r[1:0]+1'b1};
			HSIZE_HWORD:	adr_4={wb_adr_i[31:3],ahbsi_haddr_r[2:1]+1'b1,1'b0};
			HSIZE_WORD:		adr_4={wb_adr_i[31:4],ahbsi_haddr_r[3:2]+1'b1,2'b0};
			default:			adr_4={wb_adr_i[31:4],ahbsi_haddr_r[3:2]+1'b1,2'b0};
		endcase

		case(ahbsi_hsize_r)
			HSIZE_BYTE:		adr_8={wb_adr_i[31:3],ahbsi_haddr_r[2:0]+1'b1};
			HSIZE_HWORD:	adr_8={wb_adr_i[31:4],ahbsi_haddr_r[3:1]+1'b1,1'b0};
			HSIZE_WORD:		adr_8={wb_adr_i[31:5],ahbsi_haddr_r[4:2]+1'b1,2'b0};
			default:			adr_8={wb_adr_i[31:5],ahbsi_haddr_r[4:2]+1'b1,2'b0};
		endcase
		
		case(ahbsi_hsize_r)
			HSIZE_BYTE:		adr_16={wb_adr_i[31:4],ahbsi_haddr_r[3:0]+1'b1};
			HSIZE_HWORD:	adr_16={wb_adr_i[31:5],ahbsi_haddr_r[4:1]+1'b1,1'b0};
			HSIZE_WORD:		adr_16={wb_adr_i[31:6],ahbsi_haddr_r[5:2]+1'b1,2'b0};
			default:			adr_16={wb_adr_i[31:6],ahbsi_haddr_r[5:2]+1'b1,2'b0};
		endcase						
		
		if(sm==idle)
			ahbsi_haddr=adr_a;
		else
		begin
			if(wb_cti_i!=WBCTI_INCRBURST)
				ahbsi_haddr=adr_a;
			else
				case(wb_bte_i)
					WBBTE_LINEAR:		ahbsi_haddr=adr_u;
					WBBTE_WRAP4:		ahbsi_haddr=adr_4;
					WBBTE_WRAP8:		ahbsi_haddr=adr_8;
					WBBTE_WRAP16:		ahbsi_haddr=adr_16;
					default:				ahbsi_haddr=adr_u;
				endcase
		end
				
		ahbsi_hsel=1'b1;//wb_cyc_i;
		ahbsi_hwrite=wb_we_i;
		ahbsi_hwdata=wb_dat_i;
		
		wb_ack_o=(sm!=idle) && ahbso_hready && (ahbso_hresp==HRESP_OKAY);
		wb_err_o=((sm!=idle) && ahbso_hready && (ahbso_hresp==HRESP_ERROR)) || decode_err;
		wb_rty_o=(sm!=idle) && ahbso_hready && (ahbso_hresp==HRESP_RETRY || ahbso_hresp==HRESP_SPLIT);
		wb_dat_o=ahbso_hrdata;
		
		if(wb_cti_i==WBCTI_CLASSIC)
			ahbsi_hburst=HBURST_SINGLE;
		else
			case(wb_bte_i)
				WBBTE_LINEAR:		ahbsi_hburst=HBURST_INCR;
				WBBTE_WRAP4	:		ahbsi_hburst=HBURST_WRAP4;
				WBBTE_WRAP8	:		ahbsi_hburst=HBURST_WRAP8;
				WBBTE_WRAP16:		ahbsi_hburst=HBURST_WRAP16;
				default			:		ahbsi_hburst=HBURST_SINGLE;
			endcase

		if(sm==idle)
		begin
			if(!wb_stb_i)
				ahbsi_htrans=HTRANS_IDLE;
			else if(wb_cyc_i)
				ahbsi_htrans=HTRANS_NONSEQ;
			else
				ahbsi_htrans=HTRANS_IDLE;
		end
		else
		begin
			if(!wb_stb_i)
				ahbsi_htrans=HTRANS_BUSY;	
			else if(wb_cti_i==WBCTI_CLASSIC || wb_cti_i==WBCTI_ENDBURST)
				ahbsi_htrans=HTRANS_IDLE;
			else
				ahbsi_htrans=HTRANS_SEQ;
		end
	end
/////////////////////////////////////////////////////
// Initials
/////////////////////////////////////////////////////
//optional

endmodule