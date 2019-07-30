`timescale 1ns / 1ps
//Created By: Edgar Granados
//CsC 142 Section 02
//Project 2: MultiCycle Datapath and Control Unit
//March 09, 2019
module top_tb();
reg start, mode, clk ,reset;
reg signed[7:0] A,B,C,D;
wire done;
wire signed [7:0] result;
top uut(start, mode, clk, reset, A,B,C,D, result, done);
initial clk = 0;
always #5 clk = ~clk;
initial begin
reset = 1;
start = 0;
A = 8'h01; B = 8'h02; C = 8'hFF; D = 8'h02; mode = 1'b0;
#5 reset = 0;
start = 1;
#10 start = 0;
#40$display("My name is Edgar Granados, the output for this test case was:%d\nFor A =%d, B =%d, C =%d, D =%d and mode =%b\n",result,A,B,C,D,mode) ;
A = 8'hFE; B = 8'h01; C = 8'h01; D = 8'h04; mode = 1'b1;
start = 1;
#10 start = 0;
#40$display("My name is Edgar Granados, the output for this test case was:%d\nFor A =%d, B =%d, C =%d, D =%d and mode =%b\n",result,A,B,C,D,mode) ;
A = 8'h01; B = 8'hFF; C = 8'hFF; D = 8'h02; mode = 1'b0;
start = 1;
#10 start = 0;
#40$display("My name is Edgar Granados, the output for this test case was:%d\nFor A =%d, B =%d, C =%d, D =%d and mode =%b\n",result,A,B,C,D,mode) ;
A = 8'hFE; B = 8'h02; C = 8'hFF; D = 8'h02; mode = 1'b1;
start = 1;
#10 start = 0;
#40$display("My name is Edgar Granados, the output for this test case was:%d\nFor A =%d, B =%d, C =%d, D =%d and mode =%b\n",result,A,B,C,D,mode) ;
$stop;
$finish;
end
endmodule
