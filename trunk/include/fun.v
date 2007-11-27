
function detect_x;
	input [31:0] i;
	input [5:0]	j;
	reg k;
	reg [5:0]	l;
	begin
		k=0;
		for(l=0;l<j;l=l+1'b1)
			if(i[l]===1'bx)
				k=1;
		detect_x=k;
	end
	endfunction

function integer clogb2;
input [31:0] value;
begin
   for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1)
        value = value >> 1;
end
endfunction 