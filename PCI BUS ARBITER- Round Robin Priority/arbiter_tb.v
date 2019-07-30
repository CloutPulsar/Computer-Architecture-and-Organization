`timescale 1ns/1ps

module arbiter_tb();
reg _frame, _IRDY, clk, _reset;
reg[2:0] _req;
wire[2:0] final_gnt;

arbiter uut(_req, _frame, _IRDY, clk, _reset, final_gnt);
initial clk = 1;
always #1 clk = ~clk;

initial begin
//We first begin the Round-Robin Arbiter by asserting the _reset signal to initiate the state machine and signals.
_reset = 1'b0;
#2
_reset = 1'b1;
//TEST CASE 1: In this test case, we will test the functionality of the round-robin arbter. After asserting _reset,
//the pointer that keeps track of the highest priority master will be set on the first master, i.e. _req[0](Device0). Because of this, 
// the order of priority from the arbiter will be Device0 -> Device1 -> Device2. The _frame signal must also be asserted within 16 clock cycles
// after a device signals a request and is granted the bus. If it does not assert the _frame signal, then the transaction will not be validated
// and the bus will go to the IDLE state.
/* ---------------------------------------For Simplicity, we will test the 16 clock cycle validation later-----------------------------------*/
//TEST 1: Device0 signals request, and also asserts _frame and _IRDY at the same time.
_req = 3'b110;
_frame = 1'b0;
_IRDY = 1'b0;
#4
_frame = 1'b1;
#2
//BUS will go to idle because _frame and _IRDY are both deasserted.
_IRDY = 1'b1;

//TEST CASE 2: In this test,case we set our request signal to 100 to test if the priority pointer updated. The grant signal should be 101.@12ns 
_req = 3'b100;
#4
_frame = 1'b0;
#2
_IRDY = 1'b0;
#4
_IRDY = 1'b1;
//If data phase transaction is not completed within 8 clock cycles, bus will return to idle state and the grant vector will be reset.@30ns
#14
_frame = 1'b1;
#2

//TEST CASE 3: Because the transaction did not complete after 8 clock cycles, The bus was returned to the idle state. In this test case
//we will test the request vector 010, since our priority pointer was maintained at Device2, we should get a grant signal of 011. @36ns
_req = 3'b010;
#2
_frame = 1'b0;
#4
_IRDY = 1'b0;
#2
_IRDY = 1'b1;
#4
_frame = 1'b1;

//TEST CASE 4: The final test case will test the 16 clock cycle Bus reset after a requestor receives the bus. If an initiator that is granted the bus does not assert 
//its FRAME# signal within 16 clock cycles, the transaction will be terminated and the bus will return to the idle state. @84ns
#3
_req = 3'b000;
_IRDY = 1'b0;
#42;
//@86ns Arbiter grants Device1 the bus, and after 5 clock cycles, Device2 asserts FRAME# initiating the transaction.
_frame =1'b0;
#6
_frame = 1'b1;
_IRDY = 1'b1;
#10
$stop;
$finish;
end

endmodule