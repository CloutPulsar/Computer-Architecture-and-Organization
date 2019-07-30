`timescale 1ns/1ps
//Created By: Edgar Granados
//CsC 142 Section 02
//Project 2: MultiCycle Datapath and Control Unit
//March 09, 2019
module FSM(start, mode, clk, reset, selMux1, m, e, selMux2,done);
input start, mode,clk,reset;
output selMux1, m, e,done;
output[1:0] selMux2;

reg selMux1, m, e, done;
reg[1:0] currState, nextState, previousState, selMux2;

parameter
State0 = 2'b00,
State1 = 2'b01,
State2 = 2'b10,
State3 = 2'b11;

always @(posedge clk)
begin
	if(currState == State0)
	begin
	   
	   if(start == 1'b1)
		   nextState = State1;
	   else
	       nextState = State0;
	end
	else if(currState ==State1)
		nextState = State2;
	else if(currState ==State2)
		nextState = State3;
	else if(currState ==State3)
		nextState  = State0;
	else
		nextState = 2'bXX;
end
always @(posedge clk)
begin
	case(currState)
	State0:
	begin
		if(start == 0)
		begin
			e <= 1'b0;
			selMux2 <= 2'bXX;
			m <= 1'bX;
			selMux1 <= 1'bX;
		end
		else
		begin
			e = 1'b1;
			selMux2 = 2'bXX;
			m = 1'bX;
			selMux1 = 1'b0;
		end
	    if(previousState == State3)
	       done <= 1'b1;
	    else 
	       done <= 1'b0;
	end
	State1:
	begin
		if(mode == 1'b0)
		begin
			e <= 1'b1;
			selMux2 <= 2'b00;
			m <= 1'b0;
			selMux1 <= 1'b1;
		end
		else
		begin
			e <= 1'b1;
			selMux2 <= 2'b00;
			m <= 1'b1;
			selMux1 <= 1'b1;	
		end
	end
	State2:
	begin
		e = 1'b1;
		selMux2 <= 2'b01;
		m <= 1'b0;
		selMux1 <= 1'b1;
	end
	State3:
	begin
	if(mode == 1'b0)
	begin
		e <= 1'b1;
		selMux2 <= 2'b10;
		m <= 1'b1;
		selMux1 <= 1'b1;
	end
	else
	begin
		e <= 1'b1;
		selMux2 <= 2'b10;
		m <= 1'b0;
		selMux1 <= 1'b1;	
	end
	end
	endcase
end
//=====================D=FLIP FLOP------------------------------
always @(posedge clk, posedge reset)
begin
	if(reset == 1)
	begin
		
		currState <= State0;
		done <= 0;
	end
	else
	begin
	    previousState <= currState;
		currState <= nextState;
	end
end
endmodule

