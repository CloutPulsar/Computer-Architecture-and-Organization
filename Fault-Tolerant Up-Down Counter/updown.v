/*
Created By: Edgar Granados
Date: April 2, 2019
Instructor: Dr. Faroughi
Project 3: Fault-Tolerant Up-Down Counter.
*/

`timescale 1ns / 1ps


module updown(clk, reset, preset,mode, qout);
input clk;
input[1:0] mode;
input[2:0] reset, preset;
output[2:0] qout;

wire [2:0] res,qout;
reg[2:0]  count,prev;
reg[1:0]  prevMode;
always @ (posedge reset)
begin
	if(reset == 3'b111)
	begin
		count = 0;
		prev = count;
		prevMode = mode;
	end
end
always @(posedge clk)
begin
    if(mode == 2'b00 || mode == 2'b11)
		count = count;
	else if(mode == 2'b01 && ((prev + 1) % 8) != count && prevMode == mode)
	begin
		count = prev;
		count = (count + 1) % 8;

	end
	else if(mode == 2'b10 && ((prev + (8 - 1)) % 8) != count && prevMode == mode)
	begin
		count = prev;
		count = (count + (8 - 1)) % 8;
		
	end
	else if(mode == 2'b01)
	begin
		prev = count;
		count = (count + 1) % 8;
		prevMode = mode;

	end
	else if(mode == 2'b10)
	begin
		prev  = count;
		count = (count + (8 - 1)) % 8;
		prevMode = mode;
	end
	else
	begin
		count = 3'bZZZ;
		prev = 3'bZZZ;
	end
end
dff d0(clk, reset[0], count[0], preset[0], res[0]);
dff d1(clk, reset[1], count[1], preset[1], res[1]);
dff d2(clk, reset[2], count[2], preset[2], res[2]);

assign qout = res;
endmodule