`timescale 1ns/1ps
module cachecontroller_tb();
reg clk, reset,CStrobe, CRW, MReady;
reg[31:0] CAddress, CData_In, MData_In;
reg[31:0] MemoryAddressArray[0:50000];
wire CReady, MStrobe, MRW;
wire[31:0] MAddress, CData_Out, MData_Out;

cachecontroller uut(CAddress, CStrobe, CRW, CReady,CData_In, CData_Out, MAddress, MStrobe, MRW, MData_In, MData_Out, MReady, clk, reset);

initial clk = 0;
always #1 clk = ~clk;


initial begin
    reset = 1;
    CAddress = 32'h00000000; 
    CStrobe = 0;
    CRW = 0; 
    MReady = 0;
    
    //Initialize Memory Locations with values. This was done to make testing different cases easier. When a certain address from Cache Controller is sent. The Memory Module will return value of that address.
    MemoryAddressArray[0] = 32'h00000023; //35 decimal
    MemoryAddressArray[4] = 32'h00000007; // 7 decimal
    MemoryAddressArray[8] = 32'h00000015; //21 decimal
    MemoryAddressArray[4096] = 32'h00000002; // 2 decimal USED FOR WRITE MISS TEST CASE
    MemoryAddressArray[4100] = 32'h00001001; //4097 decimal USED FOR WRITE MISS TEST CASE
    MemoryAddressArray[4104] = 32'h00001002; //4098 decimal USED FOR WRITE MISS TEST CASE

//--------------------------------------------------BEGINNING OF TESTBENCH WITH TEST CASES---------------------------------------------------------------------------------------
//First Test Case: READ MISS TEST. For the first test case we are going to test the read miss mechanism of the cache controller design.
//The Controller takes 5 clock cycles to load a value from memory onto a cache block. Therefore, we must give it enough time so that the task is executed. 
//For this test, we loaded the first three values from Memory 0, 4, and 8 onto the cache. The results we should expect is the first 3 cache blocks be filled with the values from memory
//WHEN CACHE READY SIGNAL IS ASSERTED, THIS TELLS US THAT A CACHE BLOCK HAS BEEN UPDATED WITH A VALUE FROM MEMORY!

//EXPECTED RESULTS: 3 Read Misses, and Values of Memory 0,4,8 loaded onto Cache Blocks 0,1,2. 
//ACTUAL RESULTS: At time 29ns we see that the cache blocks 0,1,2 are filled in with values of MemoryAddressArray 0,4, and 8.  
    #1
    reset = 0;
    CStrobe = 1;
    CRW = 1;
    MReady = 1;
    #9CStrobe = 0;
    #1CStrobe = 1;
    CAddress = 32'h00000004; 
    #9CStrobe = 0;
    #1CStrobe = 1;
    CAddress = 32'h00000008; 
    #9;
 //SECOND TEST CASE: Read Hit For All 3 Blocks. For this test case we wanted to assure that our Read Hit state was working correctly. After we had loaded all the values
 //from memory onto their respective cache blocks. If a read hit occurs on a cache block we should see that the value of CData_Out alternate between high impedance and the 
 //value stored in cache block x. This is indicating that the FSM is switcing between IDLE state and READ state, which confirms that a read hit is occuring. Thus, this operation
 //should take 2 clock cycles to perform a read hit. 
 
 //EXPECTED RESULTS: 3 READ HITS, FSM alternates between IDLE and READ State because of read hits. Process should take only 2 clock cycles per read hit. 
 //ACTUAL RESULTS: TEST CASE BEGINS @ 35ns. The results show that every 2 clock cycles, a read hit occurs, causing CData_Out to output the data stored in cache block x. 
 //When the CReady signal is asserted, this tells the CPU module that the data is ready to be sent to the CPU from the cache controller. 
 //OUR RESULTS ARE AS EXPECTED, 3 Read Hits with no Reading from memory. 
    #4CStrobe = 0;
    #1CStrobe = 1;
    CAddress = 32'h00000000;
    #3CStrobe = 0;
    #1CStrobe = 1;
    CAddress = 32'h00000004;
    #3CStrobe = 0;
    #1CStrobe = 1;
    CAddress = 32'h00000008;   
    #3CStrobe = 0;;
 //THIRD TEST CASE: Write Hit. For this test cases we tested the cache controller's write hit. Since the cache blocks 0,1,2 are loaded with clean values from memory. If  
//the CPU specifies a write for one of these addresses, then the cache controller will issue a write hit; because the data is already loaded into cache and will not need
//to be fetched from memory. Similar to Read Hit, the write hit operation should take only 2 clock cycles to perform since the FSM is only switching from IDLE to WRITE states.

//EXPECTED RESULTS: 3 Write HITS, Data in Cache Blocks should be updated and dirty bit should be asserted for each WRITE HIT. Main Memory SHOULD NOT be updated. The Write HIT process
// should take 2 clock cycles to complete. [IDLE --> WRITE ]--> IDLE
//ACTUAL RESULTS: 3 WRITE HITS, the data in cache blocks 0,1,2 have been updated with the values inputted by Signal CDATA_IN. The WRITE HIT operation only takes 2 clock cycles and after 
//completing, the dirty bit is also updated. 
    #1CRW = 0; // Change Cache mode to Write
    CStrobe = 1;
    CData_In = 598;
    CAddress = 32'h0000000;
    #3CStrobe = 0;
    #1CStrobe = 1;
    CData_In = 65;
    CAddress = 32'h00000004;
    #3CStrobe = 0;
    #1CStrobe = 1;
    CData_In = 100;
    CAddress = 32'h00000008;  
    #3CStrobe = 0;
//FOURTH TEST CASE: WRITE MISS. For the final test case we wanted to test the implementation of a Write Miss on the cache controller. Because our Cache Design is implementing  
//Write-Back with Write Allocation Policy; we first write back the dirty data from the cache block to Main Memory. Once this has been completed we load this data back onto cache 
//and perform a write hit operation on it. 
//EXPECTED RESULTS: We should expect 3 Write Misses, with the dirty data written to memory and then a write done on the cache.
//ACTUAL RESULTS: 3 Write Misses, Data was written back to memory of specified address. Then a write hit operation was done after data was written back.
    #1CRW = 0; // Change Cache mode to Write
    CStrobe = 1;
    CData_In = 253;
    CAddress = 32'b00000000000000000001000000000000; //Maps to CACHE BLOCK 0
    #12CStrobe = 0;
    #3CStrobe = 1;
    CData_In = 1234;
    CAddress = 32'b00000000000000000001000000000100; //Maps to CACHE BLOCK 1
    #12CStrobe = 0;
    #3CStrobe = 1;
    CData_In = 82;
    CAddress = 32'b00000000000000000001000000001000; //Maps to CACHE BLOCK 2
    #26;
    $stop;
    $finish;
end 
always @(posedge MStrobe)
begin
        MData_In <= MemoryAddressArray[MAddress];
end
always @(MData_Out)
begin
        if(MData_Out >= 0)
        MemoryAddressArray[MAddress] <= MData_Out;
end
endmodule
