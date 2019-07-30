`timescale 1ns/1ps
//Created By: Edgar Granados
//CsC 142 Section 02
//Project 2: MultiCycle Datapath and Control Unit
//March 09, 2019
module top(start, mode, clk, reset, A, B, C, D, result, done);
input start, mode, clk, reset;
input[7:0] A,B,C,D;
output done;
output[7:0] result;
wire selMux1, m, e,done;
wire[1:0]selMux2;
wire[7:0]mux_out2,mux_out3,result, q, dout;


FSM g0(.start(start), .mode(mode), .clk(clk),
.reset(reset), .selMux1(selMux1), .m(m), .e(e),
.selMux2(selMux2), .done(done));
mux2to1 g1(.din0(A), .din1(dout), .sel(selMux1), .mux_out(mux_out2));
mux3to1 g2(.B(B), .C(C), .D(D), .sel(selMux2), .mux_out(mux_out3));
register g3(.data(mux_out2), .q(q), .e(e), .clk(clk), .reset(reset));
subtractor g4(.fromMux(mux_out3), .fromReg(q), .dout(dout), .m(m));

assign result = q;
endmodule