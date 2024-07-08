`include "./MEM44.v"

module MEM44_TB();

	reg clk, reset, we;
	reg [3:0] addr;
	reg [7:0] data_in;
	wire [31:0] row_out;

	MEM44 mem (clk, reset, we, addr, data_in, row_out);

	initial begin
		$monitor(
			"Time: %0t\n", $time,
			"%x\n%x\n%x\n%x\n", mem.memArray[0], mem.memArray[1], mem.memArray[2], mem.memArray[3],	
			"\t\tRO:%x\n", row_out
		);

		clk = 1'b0;
		reset = 1'b1;
		addr = 4'b0;

		#5
		reset = 1'b0;
		addr = 4'b0;
		we = 1'b1;
		repeat (5) begin
			data_in = $urandom_range(1,128);
			$display("\t\t Load %x at %d", data_in, addr);
			repeat (2) #5 clk = ~clk;
			
			addr = addr + 1;
		end

		reset = 1'b1;
		# 5
		reset = 1'b0;		
	end


endmodule
