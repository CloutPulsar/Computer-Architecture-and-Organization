`timescale 1ns / 1ps

module dff(clk, reset, data, preset, q);
input clk, reset, preset,data;
output q;
reg q;
always @(posedge clk, posedge reset, posedge preset)
begin
	if(preset && reset)
		q <= 1'bX;
	else if(reset)
		q <= 1'b0;
	else if(preset)	
		q <= 1'b1;
	else 
		q <= data;
end
endmodule