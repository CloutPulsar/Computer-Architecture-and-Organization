`timescale 1ns/1ps

module cachecontroller(CAddress, CStrobe, CRW, CReady, CData,CData_In, CData_Out, MAddress, MStrobe, MRW, MData,MData_In, MData_Out, MReady, clk, reset);
input clk, reset,CStrobe, CRW, MReady;
input[31:0] CAddress, CData_In, MData_In;
inout[31:0] CData, MData;
output CReady, MStrobe, MRW;
output[31:0] MAddress, CData_Out, MData_Out;

integer i;
wire[31:12] addrTag;
wire[11:2] addrIndex;
wire[1:0] byteOffset;
wire hit;
reg CReady, MStrobe, MRW;
reg[31:0] C_In, C_Out, M_In, M_Out, MAddress;
reg[31:0] data[0:1023];
reg dirty[0:1023], valid[0:1023];
reg[19:0] tag[0:1023];

reg[3:0] currState, nextState;

parameter 
IDLE = 0,
READ = 1,
READMISS = 2,
READMEM = 3,
READDATA = 4,
WRITE = 5,
WRITEHIT =6,
WRITEMISS = 7,
WRITEMEM  = 8,
WRITEDATA = 9;
assign addrTag = CAddress[31:12];
assign addrIndex = CAddress[11:2];
assign byteOffset = CAddress[1:0];
assign hit = valid[addrIndex] & (addrTag == tag[addrIndex]);

//For INOUT PORTS
assign CData = (!CRW) ? C_In : 32'hZZZZZZZZ;
assign CData_Out = C_Out;
assign MData = (!MRW) ? M_In : 32'hZZZZZZZZ;
assign MData_Out = M_Out;

always @(posedge clk)
begin
	case(currState)
		IDLE:
		begin
			CReady <=0;
			MStrobe <= 0;
			MAddress <= 32'h00000000;
			if(CStrobe && CRW)
				nextState <= READ;
			else if(CStorbe && !CRW)
				nextState <= WRITE;
			else
				nextState <= IDLE;
		end
		READ:
		begin
			if(hit)
			begin
				nextState <= IDLE;
				CReady <= 1;
			end
			else
				nextState <= READMISS;
		end
		READMISS:
		begin
			nextState <= READMEM;
			MAddress <= CAddress;
		end
		READMEM:
		begin
			if(MReady)
				nextState <= READDATA;
			else
				nextState <= READMEM;
		end
		READDATA:
		begin
			nextState <= IDLE;
			CReady <= 1;
			MRW <= 1;
			MStrobe <= 1;
			valid[addrIndex] <= 1;
			dirty[addrIndex] <= 0;
			tag[addrIndex] <= addrTag;
			data[addrIndex] <= MData_Out;
		end
		WRITE:
		begin
			if(hit)
			begin
				nextState <= WRITEHIT;
				CReady <= 1;
			end
			else
				nextState <= WRITEMISS;
		end
		WRITEHIT:
		begin
			CReady <= 1;
			valid[addrIndex] <= 1;
			dirty[addrIndex] <= 1;
			tag[addrIndex] <= addrTag;
			data[addrIndex] <= CData_Out;
			nextState <= IDLE;
		end
		WRITEMISS:
		begin
			nextState <= WRITEMEM;
			MAddress <= CAddress;
		end
		WRITEMEM:
		begin
			if(MReady)
			begin
				nextState <= WRITEDATA;
			end
			else
				nextState <= WRITEMEM;
		end
		WRITEDATA:
		begin
			if(dirty[addrIndex])
			begin
				M_Out <= data[addrIndex];
				valid[addrIndex] <= 0;
				dirty[addrIndex] <= 0;
			end

			MStrobe <= 1;
			MRW <= 0;
			valid[addrIndex] <= 1;
			dirty[addrIndex] <= 0;
			tag[addrIndex] <= addrTag;
			data[addrIndex] <= MData_Out;
			nextState <= IDLE;
		end
	endcase
end
always @(posedge clk, posedge reset)
begin
	C_Out <= CData;
	C_In  <= CData_In;
	M_Out <= MData;
	M_In  <= MData_In;
	if(reset)
	begin
		for(i = 0; i< 1024; i= i+1)
		begin
			valid[i] <= 0;
			dirty[i] <= 0;
			tag[i] <= 0;
			data[i] <= 0;
		end
		MStrobe <= 1'bZ;
		MRW <= 1'bZ;
		currState <= IDLE;
		CData_In <= 32'hXXXXXXXX;
		MData_In <= 32'hXXXXXXXX;
	end
	else 
		currState <= nextState
end
endmodule