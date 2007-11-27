
`timescale 1ns / 1ps
module tb_wb2mctrl(
);
	`include "../include/amba.v"
	`include "../include/wishbone.v"
	parameter dt=2;
	 parameter rom = 0; 
   parameter io = 1; 
   parameter ram = 2;
	reg clk,rst;
	//-----------------------
   reg[0:NAPBSLV - 1] apbi_psel; 
   reg apbi_penable; 
   reg[31:0] apbi_paddr; 
   reg apbi_pwrite; 
   reg[31:0] apbi_pwdata; 
   wire[0:NAHBSLV - 1] ahbsi_hsel; 
   wire[31:0] ahbsi_haddr; 
   wire ahbsi_hwrite; 
   wire[1:0] ahbsi_htrans; 
   wire[2:0] ahbsi_hsize; 
   wire[2:0] ahbsi_hburst; 
   wire[31:0] ahbsi_hwdata; 
   wire ahbsi_hready; 
   wire[0:NAHBAMR - 1] ahbsi_hmbsel; 
   wire memi_brdyn; 
   wire memi_bexcn; 
   wire[3:0] memi_wrn; 
   wire[1:0] memi_bwidth; 
   wire[63:0] memi_sd; 
   wire wpo_wprothit;          
	//-----------------------
   wire[31:0] memo_address;
   wire[31:0] memo_data;
   wire[63:0] memo_sddata;
   wire[7:0] memo_ramsn;
   wire[7:0] memo_ramoen;
   wire[3:0] memo_mben;
   wire memo_iosn;
   wire[7:0] memo_romsn;
   wire memo_oen;
   wire memo_writen;
   wire[3:0] memo_wrn;
   wire[3:0] memo_bdrive;
   wire[31:0] memo_vbdrive;
   wire[63:0] memo_svbdrive;
   wire memo_read;
   wire[14:0] memo_sa;
   wire ahbso_hready;
   wire[1:0] ahbso_hresp;
   wire[31:0] ahbso_hrdata;
   wire ahbso_hcache;
   wire[31:0] apbo_prdata;
   wire[1:0] sdo_sdcke;
   wire[1:0] sdo_sdcsn;
   wire sdo_sdwen;
   wire sdo_rasn;
   wire sdo_casn;
   wire[7:0] sdo_dqm;
   //-----------------------------------
   genvar i;
   wire [31:0]mem_databus;
   wire [31:0]mem_address;
   wire sdmem_casn,sdmem_rasn,sdmem_wen,sdmem_csn,sdmem_cke;
   wire [3:0]sdmem_dqm;
   reg [31:0]wb_dat_i,wb_adr_i;
   reg wb_cyc_i,wb_stb_i,wb_we_i;
   reg [1:0]wb_bte_i;
   reg [2:0]wb_cti_i;
   reg [3:0]wb_sel_i;
   wire [31:0]wb_dat_o;
   wire wb_ack_o,wb_err_o,wb_rty_o;
   event wb_finish;
   
   ahb2wb ahb2wb(
   	.clk		(clk),
   	.rst_n	(rst),
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
   
   mctrl mctrl(
   //inputs
   .clk(clk),
   .rst(rst),
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
   .ahbsi_hready(ahbsi_hready), 
   .ahbsi_hmbsel(ahbsi_hmbsel), 
   .memi_data(mem_databus), 
   .memi_brdyn(memi_brdyn), 
   .memi_bexcn(memi_bexcn), 
   .memi_wrn(memi_wrn), 
   .memi_bwidth(memi_bwidth), 
   .memi_sd(memi_sd), 
   .wpo_wprothit(wpo_wprothit),    
   //outputs
   .memo_address(memo_address),
   .memo_data(memo_data),
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
   .ahbso_hcache(ahbso_hcache),
   .apbo_prdata(apbo_prdata),
   .sdo_sdcke(sdo_sdcke),
   .sdo_sdcsn(sdo_sdcsn),
   .sdo_sdwen(sdo_sdwen),
   .sdo_rasn(sdo_rasn),
   .sdo_casn(sdo_casn),
   .sdo_dqm(sdo_dqm)
   );
   
   mt48lc2m32b2 sdram(
   	.Dq		(mem_databus),
   	.Addr	(mem_address[12:2]),
   	.Ba		(mem_address[16:15]),
   	.Clk	(clk),
   	.Cke	(sdmem_cke),
   	.Cs_n	(sdmem_csn),
   	.Ras_n	(sdmem_rasn),
   	.Cas_n	(sdmem_casn),
   	.We_n		(sdmem_wen),
   	.Dqm		(sdmem_dqm)
   );
   
  generate
  	for(i=0;i<32;i=i+1)
  	begin
  		assign #dt mem_databus[i]=memo_vbdrive[i]?1'bz:memo_data[i];
  	end
	endgenerate  
	
   always #5 clk=!clk;
   assign #dt mem_address=memo_address;
   assign #dt {sdmem_casn,sdmem_rasn,sdmem_wen,sdmem_csn,sdmem_cke}
   				={sdo_casn,sdo_rasn,sdo_sdwen,sdo_sdcsn[0],sdo_sdcke[0]};
   assign #dt sdmem_dqm=sdo_dqm[3:0];  	
	assign ahbsi_hready=ahbso_hready;
	assign ahbsi_hmbsel=ram;
  //-----test tasks-----------------
	
	always@(posedge clk)
	begin
		if(wb_ack_o || wb_err_o || wb_rty_o)
			->wb_finish;
	end
	
	task init_bench;
	begin
		wb_cyc_i=0;
		wb_stb_i=0;
		apbi_psel={NAPBSLV{1'b1}};
		apbi_penable=0;
	end
	endtask
	
	task wb_1tx;
	input [31:0]addr,wdata;
	input we,cyc,stb;
	input [1:0]bte;
	input [2:0]cti;
	input [3:0]sel;
	begin
		wb_dat_i<=wdata;
		wb_adr_i<=addr;
		wb_cyc_i<=cyc;
		wb_stb_i<=stb;
		wb_we_i<=we;
		wb_bte_i<=bte;
		wb_cti_i<=cti;
		wb_sel_i<=sel;
		@(posedge clk);
		if(!(wb_ack_o || wb_err_o || wb_rty_o))
			@(wb_finish);
	end
	endtask
	
	task wb_1tx_nowait;
	input [31:0]addr,wdata;
	input we,cyc,stb;
	input [1:0]bte;
	input [2:0]cti;
	input [3:0]sel;
	begin
		wb_dat_i<=wdata;
		wb_adr_i<=addr;
		wb_cyc_i<=cyc;
		wb_stb_i<=stb;
		wb_we_i<=we;
		wb_bte_i<=bte;
		wb_cti_i<=cti;
		wb_sel_i<=sel;
		@(posedge clk);
	end
	endtask
	
	task apb_1tx;
	input [31:0]addr,wdata;
	input write;
	output [31:0]rdata;
	begin
		@(posedge clk)
			apbi_pwrite<=write;
			apbi_paddr<=addr;
			apbi_pwdata<=wdata;
		@(posedge clk)			
			apbi_penable<=1'b1;
		@(posedge clk)
			apbi_penable<=1'b0;
			apbi_pwrite<=1'b0;
		rdata=apbo_prdata;
	end
	endtask
	
  initial
  begin:bench
  	reg [31:0]rdata;
  	init_bench;
  	clk=0;
  	rst=1;
  	#10
  	rst=0;
  	#20
  	rst=1;
  	apb_1tx(32'h0,32'b00_0_0_0_0010_1_0000000_1_0_00_0001_0001,1'b1,rdata);
  	apb_1tx(32'h4,32'b1_0_011_1_001_00_00_0_000_1_0_1100_0_0_0_10_00_00,1'b1,rdata);
  	#700;
  	@(posedge clk);
  	//single read write test
		wb_1tx(32'h20000000,32'd0,1'b1,1'b1,1'b1,WBBTE_LINEAR,WBCTI_CLASSIC,4'b1111);
		wb_1tx_nowait(32'bx,32'bx,1'b0,1'b0,1'b0,WBBTE_LINEAR,WBCTI_CLASSIC,4'b1111);
		wb_1tx(32'h20000004,32'd1,1'b1,1'b1,1'b1,WBBTE_LINEAR,WBCTI_CLASSIC,4'b1111);
		wb_1tx_nowait(32'bx,32'bx,1'b0,1'b0,1'b0,WBBTE_LINEAR,WBCTI_CLASSIC,4'b1111);
		wb_1tx(32'h20000008,32'd2,1'b1,1'b1,1'b1,WBBTE_LINEAR,WBCTI_CLASSIC,4'b1111);
		wb_1tx_nowait(32'bx,32'bx,1'b0,1'b0,1'b0,WBBTE_LINEAR,WBCTI_CLASSIC,4'b1111);
		wb_1tx(32'h20000000,32'bx,1'b0,1'b1,1'b1,WBBTE_LINEAR,WBCTI_CLASSIC,4'b1111);
		$display("TIME %t,WB Read %d",$time,wb_dat_o);
		wb_1tx_nowait(32'bx,32'bx,1'b0,1'b0,1'b0,WBBTE_LINEAR,WBCTI_CLASSIC,4'b1111);
		//linear burst read write test
		wb_1tx(32'h20000000,32'd0,1'b1,1'b1,1'b1,WBBTE_LINEAR,WBCTI_INCRBURST,4'b1111);
		wb_1tx(32'h20000004,32'd1,1'b1,1'b1,1'b1,WBBTE_LINEAR,WBCTI_INCRBURST,4'b1111);
		wb_1tx(32'h20000008,32'd2,1'b1,1'b1,1'b1,WBBTE_LINEAR,WBCTI_INCRBURST,4'b1111);
		wb_1tx(32'h2000000c,32'd3,1'b1,1'b1,1'b1,WBBTE_LINEAR,WBCTI_INCRBURST,4'b1111);
		wb_1tx(32'h20000010,32'd4,1'b1,1'b1,1'b1,WBBTE_LINEAR,WBCTI_ENDBURST,4'b1111);
		wb_1tx_nowait(32'bx,32'bx,1'b0,1'b0,1'b0,WBBTE_LINEAR,WBCTI_CLASSIC,4'b1111);
		
		wb_1tx(32'h20000000,32'bx,1'b0,1'b1,1'b1,WBBTE_LINEAR,WBCTI_INCRBURST,4'b1111);
		$display("TIME %t,WB Read %d",$time,wb_dat_o);
		wb_1tx(32'h20000004,32'bx,1'b0,1'b1,1'b1,WBBTE_LINEAR,WBCTI_INCRBURST,4'b1111);
		$display("TIME %t,WB Read %d",$time,wb_dat_o);
		wb_1tx(32'h20000008,32'bx,1'b0,1'b1,1'b1,WBBTE_LINEAR,WBCTI_INCRBURST,4'b1111);
		$display("TIME %t,WB Read %d",$time,wb_dat_o);
		wb_1tx(32'h2000000c,32'bx,1'b0,1'b1,1'b1,WBBTE_LINEAR,WBCTI_INCRBURST,4'b1111);
		$display("TIME %t,WB Read %d",$time,wb_dat_o);
		wb_1tx(32'h20000010,32'bx,1'b0,1'b1,1'b1,WBBTE_LINEAR,WBCTI_ENDBURST,4'b1111);
		$display("TIME %t,WB Read %d",$time,wb_dat_o);
		wb_1tx_nowait(32'bx,32'bx,1'b0,1'b0,1'b0,WBBTE_LINEAR,WBCTI_CLASSIC,4'b1111);
  end
endmodule