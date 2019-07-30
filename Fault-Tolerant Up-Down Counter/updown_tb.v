/*
Created By: Edgar Granados
Date: April 2, 2019
Instructor: Dr. Faroughi
Project 3: Fault-Tolerant Up-Down Counter.
*/
`timescale 1ns / 1ps


module updown_tb();
reg clk;
reg[1:0] mode;
reg[2:0] reset, preset;
wire[2:0] qout;

updown uut(.clk(clk), .reset(reset), .preset(preset), .mode(mode), .qout(qout));

initial begin
$timeformat(-9, 0, " ns", 0);
//Step 1) Reset the Counter, and clock until the counter becomes 3.
clk = 0;
reset = 3'b111;
preset = 3'b000;
mode = 2'b01;
#5 clk = 1;
reset = 3'b000;
#5 clk = 0;
#5 clk = 1;


#5 clk = 0;
#5 clk = 1;

//Step 2: Cause a fualt at q0 by resetting q0.
#5 clk = 0;
#2reset[0] = 1'b1;

//Step 3: Clock the counter, the output of the counter should fix to 4. 
#5 clk = 1;
#5 clk = 0;
reset[0] = 1'b0;

//Step 4: Cause a fault at q1: Output should be 110(6)
#3preset[1] = 1'b1;
#5 clk = 1;
preset[1] = 1'b0;
#5 clk = 0;

//Step 5: Clock the counter, the counter should advance to 5.
#5 clk = 1;
//Step 6: Advance the counter to 7.
#5 clk = 0;
#5 clk = 1;
#5 clk = 0;
//Step 7 : Cause a fualt at  q2. The output of the counter should be 011(3).       
reset[2] = 1'b1;
#5 clk = 1;
#5 clk = 0;
reset[2] = 1'b0;

//Step 8: Clcok the counter. If it is working correctly, the counter should advance to 0.
#5 clk = 1;
//Step 9: Switch the counter to to count down and clock twice. The counter should show 6.
mode = 2'b10;
#5 clk = 0;
#5 clk = 1;
#5 clk = 0;
//Step 10: Cause a fault at q0. The counter should show the count as 7(111)
preset[0] = 1'b1;
//Step 11: Clock the counter, the counter should decrement to 5.
#5 clk = 1;
preset[0] = 1'b0;
//Extra Test cases to show that counter counts down at each posedge clk cycle. 
#5 clk = 0;
#5 clk = 1;
#5 clk = 0;
#5 clk = 1;
#5 clk = 0;
#10 $stop;
$finish;
end

always @ (*)
begin
$monitor("Designed and Created By: Edgar Granados \nCurrent Time:%d ns, Mode set to: %b Reset = %b Preset = %b \nCounter = %d(%b)\n", $time, mode, reset, preset, qout,qout);
end
endmodule