
	parameter [2:0] WBCTI_CLASSIC		=3'b000;
	parameter [2:0] WBCTI_CONSTBURST=3'b001;
	parameter [2:0] WBCTI_INCRBURST	=3'b010;
	parameter [2:0] WBCTI_ENDBURST	=3'b111;
	
	parameter [1:0] WBBTE_LINEAR	=2'b00;
	parameter [1:0] WBBTE_WRAP4		=2'b01;
	parameter [1:0] WBBTE_WRAP8		=2'b10;
	parameter [1:0] WBBTE_WRAP16	=2'b11;
	
	parameter WB_LBURST_MSB=9;