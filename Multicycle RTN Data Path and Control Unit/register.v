`timescale 1ns/1ps
//Created By: Edgar Granados
//CsC 142 Section 02
//Project 2: MultiCycle Datapath and Control Unit
//March 09, 2019
module register(data, q, e, clk, reset);
input clk, reset, e;
input[7:0] data;
output[7:0] q;
reg[7:0] q;

always @(posedge clk, posedge reset)
begin
	if(reset == 1)
		q <= 8'h00;
	else if(clk ==1 && e == 1)
		q <= data;	
end
endmodule