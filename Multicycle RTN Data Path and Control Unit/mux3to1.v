`timescale 1ns/1ps
//Created By: Edgar Granados
//CsC 142 Section 02
//Project 2: MultiCycle Datapath and Control Unit
//March 09, 2019
module mux3to1(B,C,D,sel, mux_out);
input[7:0] B,C,D;
input[1:0] sel;
output[7:0] mux_out;
reg[7:0] mux_out;
parameter
AddB = 2'b00,
AddC = 2'b01,
AddD = 2'b10;

always @(B,C,D,sel)
begin
case(sel)
AddB:
    mux_out = B;
AddC:
    mux_out = C;
AddD:
    mux_out = D;
default:
    mux_out = 8'hZZ;
endcase
end
endmodule
