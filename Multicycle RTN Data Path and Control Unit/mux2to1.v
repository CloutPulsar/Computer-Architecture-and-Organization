`timescale 1ns/1ps
//Created By: Edgar Granados
//CsC 142 Section 02
//Project 2: MultiCycle Datapath and Control Unit
//March 09, 2019
module mux2to1(din0, din1, sel, mux_out);
input[7:0] din0, din1;
input sel;
output[7:0] mux_out;
reg[7:0] mux_out;
always @(din0, din1, sel)
begin
if(sel == 1'b0)
    mux_out <= din0;
else
    mux_out <= din1;
end
endmodule
