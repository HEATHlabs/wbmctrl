// =============================================================================
//                         FILE DETAILS
// Project          : mctrl
// Author           : Andy Newton
// File             : wb_mctrl.v
// Title            : WISHBONE Memory Controller
// Dependency       : amba.v
// Version          : 0.1
// Last modified		: 26 Nov 2007
// =============================================================================
//Log:
//Created by Andy on 26 Nov 2007
//Major changes:	
//month,date,year:Line xxx:add/delete/modified:descriptions

/////////////////////////////////////////////////////
// Module interface
/////////////////////////////////////////////////////
//synopsys translate_off
`timescale 1ns / 1ps
//synopsys translate_on

module wb_mctrl(
	clk,rst_n,
	//----------MAIN WB SLV-------------
	wb_adr_i, wb_dat_i, wb_cyc_i, wb_sel_i,
	wb_stb_i, wb_we_i, wb_bte_i, wb_cti_i,
	
	wb_ack_o, wb_err_o, wb_rty_o, wb_dat_o,
	
	cacheable, wprot,
	//----------CONFIG WB SLV------------
	cfg_adr_i, cfg_dat_i, cfg_cyc_i, cfg_stb_i, cfg_we_i,
	
	cfg_ack_o, cfg_dat_o,
	//---------Memory interface---------
	memi_data, memi_brdyn, memi_bexcn, memi_wrn, memi_bwidth,
	memi_sd,
	
	memo_address, memo_data, memo_sddata,	memo_ramsn, memo_ramoen, 
	memo_mben, memo_iosn, memo_romsn, memo_oen, memo_writen, memo_wrn,
	memo_bdrive, memo_vbdrive, memo_svbdrive, memo_read, memo_sa,
	
	sdo_sdcke, sdo_sdcsn, sdo_sdwen, sdo_rasn, sdo_casn, sdo_dqm		
	);
/////////////////////////////////////////////////////
// Parameters
/////////////////////////////////////////////////////
	 parameter romaddr  = 12'h000;
   parameter rommask  = 12'hE00;
   parameter ioaddr  = 12'h200;
   parameter iomask  = 12'hE00;
   parameter ramaddr  = 12'h400;
   parameter rammask  = 12'hC00;
   parameter romasel  = 28;
   parameter sdrasel  = 29;   
	`include "../include/amba.v"
	
/////////////////////////////////////////////////////
// Functions and tasks
/////////////////////////////////////////////////////
//optional

	input clk,rst_n;
	
/////////////////////////////////////////////////////
// CONFIG WISHBONE I/O
/////////////////////////////////////////////////////
	input [31:0]cfg_dat_i;
	input [2:0]cfg_adr_i;
	input cfg_cyc_i,cfg_stb_i,cfg_we_i;
	
	output reg[31:0]cfg_dat_o;
	output reg cfg_ack_o;

/////////////////////////////////////////////////////
// MAIN WISHBONE SLV I/O
/////////////////////////////////////////////////////
	input [31:0]wb_adr_i,wb_dat_i;
	input wb_cyc_i,wb_stb_i,wb_we_i,wprot;
	input [2:0]wb_cti_i;
	input [1:0]wb_bte_i;
	input [3:0]wb_sel_i;
	
	output wire[31:0]wb_dat_o;
	output wire wb_ack_o,wb_err_o,wb_rty_o;
	output wire cacheable;
/////////////////////////////////////////////////////
// MEMORY I/O
/////////////////////////////////////////////////////
   input[31:0] memi_data; 
   input memi_brdyn; 
   input memi_bexcn; 
   input[3:0] memi_wrn; 
   input[1:0] memi_bwidth; 
   input[63:0] memi_sd; 
   output[31:0] memo_address; 
   wire[31:0] memo_address;
   output[31:0] memo_data; 
   wire[31:0] memo_data;
   output[63:0] memo_sddata; 
   wire[63:0] memo_sddata;
   output[7:0] memo_ramsn; 
   wire[7:0] memo_ramsn;
   output[7:0] memo_ramoen; 
   wire[7:0] memo_ramoen;
   output[3:0] memo_mben; 
   wire[3:0] memo_mben;
   output memo_iosn; 
   wire memo_iosn;
   output[7:0] memo_romsn; 
   wire[7:0] memo_romsn;
   output memo_oen; 
   wire memo_oen;
   output memo_writen; 
   wire memo_writen;
   output[3:0] memo_wrn; 
   wire[3:0] memo_wrn;
   output[3:0] memo_bdrive; 
   wire[3:0] memo_bdrive;
   output[31:0] memo_vbdrive; 
   wire[31:0] memo_vbdrive;
   output[63:0] memo_svbdrive; 
   wire[63:0] memo_svbdrive;
   output memo_read; 
   wire memo_read;
   output[14:0] memo_sa; 
   wire[14:0] memo_sa;
   output[1:0] sdo_sdcke; 
   wire[1:0] sdo_sdcke;
   output[1:0] sdo_sdcsn; 
   wire[1:0] sdo_sdcsn;
   output sdo_sdwen; 
   wire sdo_sdwen;
   output sdo_rasn; 
   wire sdo_rasn;
   output sdo_casn; 
   wire sdo_casn;
   output[7:0] sdo_dqm; 
   wire[7:0] sdo_dqm;
   
/////////////////////////////////////////////////////
// Internal nets and registers 
/////////////////////////////////////////////////////
   reg[0:NAPBSLV - 1] apbi_psel; 
   reg apbi_penable; 
   reg[31:0] apbi_paddr; 
   reg apbi_pwrite; 
   reg[31:0] apbi_pwdata;
   reg [0:2] hmbsel;
   
   wire[31:0] apbo_prdata;
    
   wire[1:0] ahbso_hresp;
   wire[31:0] ahbso_hrdata;
   wire ahbso_hready; 

   reg[0:NAHBAMR - 1] ahbsi_hmbsel;
   wire[0:NAHBSLV - 1] ahbsi_hsel; 
   wire[31:0] ahbsi_haddr; 
   wire ahbsi_hwrite; 
   wire[1:0] ahbsi_htrans; 
   wire[2:0] ahbsi_hsize; 
   wire[2:0] ahbsi_hburst; 
   wire[31:0] ahbsi_hwdata; 
	 wire[31:0] memi_data_ok, memo_data_ok;
	 
/////////////////////////////////////////////////////
// Instances
/////////////////////////////////////////////////////
   ahb2wb ahb2wb(
   	.clk		(clk),
   	.rst_n	(rst_n),
   	.ahbsi_hsel		(ahbsi_hsel),
   	.ahbsi_haddr	(ahbsi_haddr),
   	.ahbsi_hwrite	(ahbsi_hwrite), 
   	.ahbsi_htrans	(ahbsi_htrans), 
   	.ahbsi_hsize	(ahbsi_hsize),
		.ahbsi_hburst	(ahbsi_hburst),	
		.ahbsi_hwdata	(ahbsi_hwdata),

		.ahbso_hready	(ahbso_hready),	
		.ahbso_hresp	(ahbso_hresp), 
		.ahbso_hrdata	(ahbso_hrdata),
		
		.wb_adr_i		(wb_adr_i), 
		.wb_dat_i		(wb_dat_i), 
		.wb_cyc_i		(wb_cyc_i), 
		.wb_sel_i		(wb_sel_i),
		.wb_stb_i		(wb_stb_i), 
		.wb_we_i		(wb_we_i), 
		.wb_bte_i		(wb_bte_i), 
		.wb_cti_i		(wb_cti_i),
	
		.wb_ack_o		(wb_ack_o), 
		.wb_err_o		(wb_err_o), 
		.wb_rty_o		(wb_rty_o), 
		.wb_dat_o		(wb_dat_o)
   );
   
   mctrl #(
   	.romasel	(romasel),
   	.sdrasel	(sdrasel)
   )mctrl(
   //inputs
   .clk(clk),
   .rst(rst_n),
   .apbi_psel(apbi_psel), 
   .apbi_penable(apbi_penable), 
   .apbi_paddr(apbi_paddr), 
   .apbi_pwrite(apbi_pwrite), 
   .apbi_pwdata(apbi_pwdata), 
   .ahbsi_hsel(ahbsi_hsel), 
   .ahbsi_haddr(ahbsi_haddr), 
   .ahbsi_hwrite(ahbsi_hwrite), 
   .ahbsi_htrans(ahbsi_htrans), 
   .ahbsi_hsize(ahbsi_hsize), 
   .ahbsi_hburst(ahbsi_hburst), 
   .ahbsi_hwdata(ahbsi_hwdata), 
   .ahbsi_hready(ahbso_hready), 
   .ahbsi_hmbsel(ahbsi_hmbsel), 
   .memi_data(memi_data_ok), 
   .memi_brdyn(memi_brdyn), 
   .memi_bexcn(memi_bexcn), 
   .memi_wrn(memi_wrn), 
   .memi_bwidth(memi_bwidth), 
   .memi_sd(memi_sd), 
   .wpo_wprothit(wprot),    
   //outputs
   .memo_address(memo_address),
   .memo_data(memo_data_ok),
   .memo_sddata(memo_sddata),
   .memo_ramsn(memo_ramsn),
   .memo_ramoen(memo_ramoen),
   .memo_mben(memo_mben),
   .memo_iosn(memo_iosn),
   .memo_romsn(memo_romsn),
   .memo_oen(memo_oen),
   .memo_writen(memo_writen),
   .memo_wrn(memo_wrn),
   .memo_bdrive(memo_bdrive),
   .memo_vbdrive(memo_vbdrive),
   .memo_svbdrive(memo_svbdrive),
   .memo_read(memo_read),
   .memo_sa(memo_sa),
   .ahbso_hready(ahbso_hready),
   .ahbso_hresp(ahbso_hresp),
   .ahbso_hrdata(ahbso_hrdata),
   .ahbso_hcache(cacheable),
   .apbo_prdata(apbo_prdata),
   .sdo_sdcke(sdo_sdcke),
   .sdo_sdcsn(sdo_sdcsn),
   .sdo_sdwen(sdo_sdwen),
   .sdo_rasn(sdo_rasn),
   .sdo_casn(sdo_casn),
   .sdo_dqm(sdo_dqm)
   );

/////////////////////////////////////////////////////
// Sequential logic
/////////////////////////////////////////////////////
	always@(posedge clk)
	begin
		if(apbi_penable)
			apbi_penable<=1'b0;
		else if(cfg_cyc_i && cfg_stb_i)
			apbi_penable<=1'b1;
		else
			apbi_penable<=1'b0;
	end

/////////////////////////////////////////////////////
// Combinational logic
/////////////////////////////////////////////////////
	assign memi_data_ok = {memi_data[7:0],memi_data[15:8],memi_data[23:16],memi_data[31:24]};
	assign memo_data 		= {memo_data_ok[7:0],memo_data_ok[15:8],memo_data_ok[23:16],memo_data_ok[31:24]};
	
	always@(*)
	begin
		apbi_psel=cfg_cyc_i;
		apbi_paddr={28'b0,cfg_adr_i,2'b0};
		apbi_pwdata=cfg_dat_i;
		apbi_pwrite=cfg_we_i;

		cfg_ack_o=apbi_penable;
		cfg_dat_o=apbo_prdata;	
		ahbsi_hmbsel={NAHBAMR{1'b0}};
		hmbsel=3'b0;
		if((wb_adr_i[31:20] & rommask)==romaddr)
			hmbsel[mctrl_rom]=1'b1;
		if((wb_adr_i[31:20] & rammask)==ramaddr)
			hmbsel[mctrl_ram]=1'b1;
		if((wb_adr_i[31:20] & iomask)==ioaddr)
			hmbsel[mctrl_io]=1'b1;					
		ahbsi_hmbsel[0:2]=hmbsel;
	end
/////////////////////////////////////////////////////
// Initials
/////////////////////////////////////////////////////
//optional

endmodule