
`timescale 1ns / 1ps
module tb_mctrl(
);
	`include "../include/amba.v"
	parameter dt=2;

	reg clk,rst;
	//-----------------------
   reg[0:NAPBSLV - 1] apbi_psel; 
   reg apbi_penable; 
   reg[31:0] apbi_paddr; 
   reg apbi_pwrite; 
   reg[31:0] apbi_pwdata; 
   reg[0:NAHBSLV - 1] ahbsi_hsel; 
   reg[31:0] ahbsi_haddr,ahbsn_haddr; 
   reg ahbsi_hwrite,ahbsn_hwrite; 
   reg[1:0] ahbsi_htrans,ahbsn_htrans; 
   reg[2:0] ahbsi_hsize,ahbsn_hsize; 
   reg[2:0] ahbsi_hburst,ahbsn_hburst; 
   reg[31:0] ahbsi_hwdata,ahbsn_hwdata; 
   wire ahbsi_hready; 
   reg[0:NAHBAMR - 1] ahbsi_hmbsel,ahbsn_hmbsel; 
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
   reg ahb_busy,new_ahb_trans;
   reg [31:0]ahb_rdata;
   event ahb_finish;
   
   always #5 clk=!clk;
   
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

   assign #dt mem_address=memo_address;
   assign #dt {sdmem_casn,sdmem_rasn,sdmem_wen,sdmem_csn,sdmem_cke}
   				={sdo_casn,sdo_rasn,sdo_sdwen,sdo_sdcsn[0],sdo_sdcke[0]};
   assign #dt sdmem_dqm=sdo_dqm[3:0];  	
	assign    ahbsi_hready=ahbso_hready;
  //-----test tasks-----------------
  task init_amba;
  begin
   ahb_busy=0;
   new_ahb_trans=0;
   apbi_psel={NAPBSLV{1'b1}};//only for this test
   apbi_penable=1'b0;
   apbi_paddr=32'b0;
   apbi_pwrite=1'b0;
   apbi_pwdata=32'b0;
   ahbsi_hsel={NAHBSLV{1'b1}};//only for this test
   ahbsi_haddr=32'b0;
   ahbsi_hwrite=1'b0;
   ahbsi_htrans=HTRANS_IDLE;
   ahbsi_hsize=HSIZE_WORD;
   ahbsi_hburst=HBURST_SINGLE;
   ahbsi_hwdata=32'b0;
   ahbsi_hmbsel={NAHBAMR{1'b0}};
  end
	endtask
	
	always@(posedge clk)
	begin
		if(ahbso_hready)
		begin
			->ahb_finish;
			ahb_rdata<=ahbso_hrdata;
		end
	end
	
	reg [31:0]t_wdata;
	always
	begin:ahb_xtor
		wait(new_ahb_trans===1);
		new_ahb_trans=0;
		ahbsi_haddr<=ahbsn_haddr;
		ahbsi_hwrite<=ahbsn_hwrite;
		ahbsi_htrans<=ahbsn_htrans;
		ahbsi_hsize<=ahbsn_hsize;
		ahbsi_hburst<=ahbsn_hburst;
		ahbsi_hmbsel<=ahbsn_hmbsel;
		@(posedge clk);
		t_wdata=ahbsn_hwdata;
		ahb_busy=0;
		if(!ahbso_hready)
			@(ahb_finish);
		ahbsi_hwdata<=t_wdata;
		if(!new_ahb_trans)
		begin
			ahbsi_htrans<=HTRANS_IDLE;
			ahbsi_hwrite<=1'b0;
		end
	end
	
	task ahb_1tx;
	input [31:0]addr,wdata;
	input write;
	input [1:0]trans;
	input [2:0]size,burst;
	input [0:NAHBAMR - 1]mbsel;
	output reg[31:0]rdata;
	begin
		if(ahb_busy)
			wait(ahb_busy==0);
		ahbsn_haddr=addr;
		ahbsn_hwrite=write;
		ahbsn_htrans=trans;
		ahbsn_hsize=size;
		ahbsn_hburst=burst;
		ahbsn_hwdata=wdata;
		ahbsn_hmbsel=mbsel;		
		ahb_busy=1;
		new_ahb_trans=1;
		rdata=ahb_rdata;
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
  	clk=0;
  	rst=1;
  	init_amba;
  	#10
  	rst=0;
  	#20
  	rst=1;
  	apb_1tx(32'h0,32'b00_0_0_0_0010_1_0000000_1_0_00_0001_0001,1'b1,rdata);
  	apb_1tx(32'h4,32'b1_0_011_1_001_00_00_0_000_1_0_1100_0_0_0_10_00_00,1'b1,rdata);
  	#700;
  	ahb_1tx(32'h20000000,32'd1,1'b1,HTRANS_NONSEQ,HSIZE_WORD ,HBURST_SINGLE,mctrl_ram,rdata);
  	ahb_1tx(32'h20000004,32'd2,1'b1,HTRANS_NONSEQ,HSIZE_WORD ,HBURST_SINGLE,mctrl_ram,rdata);
  	ahb_1tx(32'h20000008,32'd3,1'b1,HTRANS_NONSEQ,HSIZE_WORD ,HBURST_SINGLE,mctrl_ram,rdata);
  	ahb_1tx(32'h20000010,32'd1,1'b1,HTRANS_NONSEQ,HSIZE_WORD ,HBURST_INCR4  ,mctrl_ram,rdata);
  	ahb_1tx(32'h20000014,32'd2,1'b1,HTRANS_SEQ   ,HSIZE_WORD ,HBURST_INCR4  ,mctrl_ram,rdata);
  	ahb_1tx(32'h20000018,32'd3,1'b1,HTRANS_SEQ   ,HSIZE_WORD ,HBURST_INCR4  ,mctrl_ram,rdata);
  	ahb_1tx(32'h2000001c,32'd4,1'b1,HTRANS_SEQ   ,HSIZE_WORD ,HBURST_INCR4  ,mctrl_ram,rdata);
  end
endmodule