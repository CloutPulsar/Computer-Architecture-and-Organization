`timescale 1ns/1ps
//Created By: Edgar Granados
//CsC 142 Section 02
//Project 2: MultiCycle Datapath and Control Unit
//March 09, 2019
module subtractor(fromMux, fromReg, dout, m);
input[7:0]fromMux, fromReg;
input m;
output[7:0] dout;
reg[7:0] dout;

always @(fromMux, fromReg, m)
begin
if(m == 1'b0)
    dout <= fromReg + fromMux;
else
    dout <= fromReg - fromMux;
end    
endmodule
