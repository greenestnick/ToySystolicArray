`include "./SA.v"

`timescale 1ns/100ps

module SA_TB();

	reg clk, reset, we, ena;
	reg [1:0] sel;
	reg [3:0] addr;
        reg [7:0] data_in;
	wire [31:0] data_out;

	reg [31:0] testMatA [3:0];	
	reg [31:0] testMatB [3:0];
	
	wire [1:0] memCounterRow;
        wire [4:0] memCounterCol;

	SA sa(clk, reset, we, ena, sel, addr, data_in);

	task PrintMems;	
		$display(
			"Weight  \t Feature\n",
			"%x\t %x\n", sa.weightMem.memArray[0], sa.featureMem.memArray[0],  				
			"%x\t %x\n", sa.weightMem.memArray[1], sa.featureMem.memArray[1],  
			"%x\t %x\n", sa.weightMem.memArray[2], sa.featureMem.memArray[2],  
			"%x\t %x\n", sa.weightMem.memArray[3], sa.featureMem.memArray[3],  
		);
	endtask
	
	task PrintWBMem;	
		$display(
			"WriteBack Memory\n",
			"%x\n", sa.writebackMem.memArray[0],  				
			"%x\n", sa.writebackMem.memArray[1],  
			"%x\n", sa.writebackMem.memArray[2],  
			"%x\n", sa.writebackMem.memArray[3],  
		);
	endtask
	
	task PrintSystem;
	$display(
	"Time: %0t \tAddress: %2d\n", $realtime, sa.loadAddr, 
	"%x | %x | %x*%x+%x=%x  %x*%x+%x=%x  %x*%x+%x=%x  %x*%x+%x=%x\n", sa.featureLoadFIFO[0], sa.featurePassWires[0][0 +:8], sa.macgen[0 ].mac.A_in, sa.macgen[0 ].mac.W, sa.macgen[0 ].mac.PS_in, sa.macgen[0 ].mac.PS_Pass, sa.macgen[1 ].mac.A_in, sa.macgen[1 ].mac.W, sa.macgen[1 ].mac.PS_in, sa.macgen[1 ].mac.PS_Pass, sa.macgen[2 ].mac.A_in, sa.macgen[2 ].mac.W, sa.macgen[2 ].mac.PS_in, sa.macgen[2 ].mac.PS_Pass, sa.macgen[3 ].mac.A_in, sa.macgen[3 ].mac.W, sa.macgen[3 ].mac.PS_in, sa.macgen[3 ].mac.PS_Pass,
	"%x | %x | %x*%x+%x=%x  %x*%x+%x=%x  %x*%x+%x=%x  %x*%x+%x=%x\n", sa.featureLoadFIFO[1], sa.featurePassWires[0][8 +:8], sa.macgen[4 ].mac.A_in, sa.macgen[4 ].mac.W, sa.macgen[4 ].mac.PS_in, sa.macgen[4 ].mac.PS_Pass, sa.macgen[5 ].mac.A_in, sa.macgen[5 ].mac.W, sa.macgen[5 ].mac.PS_in, sa.macgen[5 ].mac.PS_Pass, sa.macgen[6 ].mac.A_in, sa.macgen[6 ].mac.W, sa.macgen[6 ].mac.PS_in, sa.macgen[6 ].mac.PS_Pass, sa.macgen[7 ].mac.A_in, sa.macgen[7 ].mac.W, sa.macgen[7 ].mac.PS_in, sa.macgen[7 ].mac.PS_Pass,
	"%x | %x | %x*%x+%x=%x  %x*%x+%x=%x  %x*%x+%x=%x  %x*%x+%x=%x\n", sa.featureLoadFIFO[2], sa.featurePassWires[0][16+:8], sa.macgen[8 ].mac.A_in, sa.macgen[8 ].mac.W, sa.macgen[8 ].mac.PS_in, sa.macgen[8 ].mac.PS_Pass, sa.macgen[9 ].mac.A_in, sa.macgen[9 ].mac.W, sa.macgen[9 ].mac.PS_in, sa.macgen[9 ].mac.PS_Pass, sa.macgen[10].mac.A_in, sa.macgen[10].mac.W, sa.macgen[10].mac.PS_in, sa.macgen[10].mac.PS_Pass, sa.macgen[11].mac.A_in, sa.macgen[11].mac.W, sa.macgen[11].mac.PS_in, sa.macgen[11].mac.PS_Pass,
	"%x | %x | %x*%x+%x=%x  %x*%x+%x=%x  %x*%x+%x=%x  %x*%x+%x=%x\n", sa.featureLoadFIFO[3], sa.featurePassWires[0][24+:8], sa.macgen[12].mac.A_in, sa.macgen[12].mac.W, sa.macgen[12].mac.PS_in, sa.macgen[12].mac.PS_Pass, sa.macgen[13].mac.A_in, sa.macgen[13].mac.W, sa.macgen[13].mac.PS_in, sa.macgen[13].mac.PS_Pass, sa.macgen[14].mac.A_in, sa.macgen[14].mac.W, sa.macgen[14].mac.PS_in, sa.macgen[14].mac.PS_Pass, sa.macgen[15].mac.A_in, sa.macgen[15].mac.W, sa.macgen[15].mac.PS_in, sa.macgen[15].mac.PS_Pass, 
	  "Quant:        %x                   %x                   %x                   %x\n", sa.quant[0], sa.quant[1], sa.quant[2], sa.quant[3], 
	"\nFIFOs:                             %x                   %x                   %x\n", sa.outputFIFO[16+:8], sa.outputFIFO[40+:8], sa.outputFIFO[64+:8],
	  "                                   %x                   %x                   %x\n", sa.outputFIFO[8 +:8], sa.outputFIFO[32+:8], sa.outputFIFO[56+:8],
	  "                                   %x                   %x                   %x\n", sa.outputFIFO[0 +:8], sa.outputFIFO[24+:8], sa.outputFIFO[48+:8],
	  "Activate:    %x --> %x\n", sa.activationWire, sa.activationFunct,
	);
	endtask

	

	initial begin
		$timeformat(-9, 0, "ns", 5);

		clk = 1'b0;
		we = 1'b0;
		ena = 1'b0;
		sel = 2'b0;
		addr = 4'b0;		
		reset = 1'b1;
		repeat (2) #5 clk = ~clk;	
		
		testMatA[0] = {8'd4, 8'd3, 8'd2, 8'd1};		
		testMatA[1] = {8'd4, 8'd3, 8'd2, 8'd1};
		testMatA[2] = {8'd4, 8'd3, 8'd2, 8'd1};
		testMatA[3] = {8'd4, 8'd3, 8'd2, 8'd1};
		
		testMatB[0] = {8'd1, 8'd2, 8'd0, 8'd4};					
		testMatB[1] = {8'd0, 8'd2, 8'd3, 8'd4};				
		testMatB[2] = {8'd1, 8'd0, 8'd3, 8'd4};				
		testMatB[3] = {8'd1, 8'd2, 8'd3, 8'd4};				

		reset = 1'b0;
		we = 1'b1;
		addr = 4'b0;
		repeat (16) begin
			data_in = testMatA[addr[3:2]][addr[1:0] * 8 +: 8];
			//data_in = $urandom_range(255);
			//$display("\t\t%0t -> Data: %x at %2d (%2d)", $time, data_in, sa.addrInternal, addr);
			repeat (2) #5 clk = ~clk;
			
			addr = addr + 1'b1;
		end
			
		sel = 2'b1;	
		repeat (16) begin
			data_in = testMatB[addr[3:2]][addr[1:0] * 8 +: 8];
			//data_in = $urandom_range(255);
			//$display("\t\t%0t -> Data: %x at %2d", $time, data_in, sa.addrInternal);
			repeat (2) #5 clk = ~clk;
			
			addr = addr + 1;
		end
	
		sel = 2'b10;
		data_in = 8'ha;
		repeat (2) #5 clk = ~clk;
		
		PrintSystem();

		$display("\nENABLE PRELOADING AND SYSARRY\n");	
		/*$monitor(
			"%x  %x\n", sa.fifoInputWires[24 +: 8], sa.featureLoadFIFO[0],	
			"%x  %x\n", sa.fifoInputWires[16 +: 8], sa.featureLoadFIFO[1],
			"%x  %x\n", sa.fifoInputWires[8 +: 8], sa.featureLoadFIFO[2],
			"%x  %x\n", sa.fifoInputWires[0 +: 8], sa.featureLoadFIFO[3],
		);*/

		we = 1'b0;
		ena = 1'b1;		
		repeat (4) begin 
			PrintSystem();
			repeat (2) #5 clk = ~clk;
			//$display("%x", sa.weightPassWires[0]);
			//PrintAll();
			//$display("\t\t%t (%b): %b\n", $time, clk, sa.macReset);
			//$display("\t\t%b %b %b %b", sa.macgen[0].mac.loadWeightFlag, sa.macgen[1].mac.loadWeightFlag, sa.macgen[2].mac.loadWeightFlag, sa.macgen[3].mac.loadWeightFlag);	
			//$display("\t\t%b %b %b %b", sa.macgen[0].mac.reset, sa.macgen[1].mac.reset, sa.macgen[2].mac.reset, sa.macgen[3].mac.reset);	
		end
		
		PrintSystem();
		
		$display("\nENABLE MATRIX MULITIPLY (%0t)\n", $time);	
		repeat(22) begin
			//$display("\t\tT:%0t : %8x", $time, sa.featurePassWires[0]);	
			//$display("\t\t        %x%x%x%x", sa.macgen[12].mac.A, sa.macgen[8].mac.A, sa.macgen[4].mac.A, sa.macgen[0].mac.A);
			PrintSystem();	
			PrintWBMem();
			repeat (2) #5 clk = ~clk;
		end

		#20	
		$display("\nRESET THE SYSTEM (%0t)\n", $time);
		reset = 1'b1;
		repeat (2) #5 clk = ~clk;
		PrintSystem();	
	end


endmodule
