
module MEM44(
	input        clk, reset, we,
	input  [3:0] addr,
	input  [7:0] data_in,
	output [31:0] col_out
);

reg [31:0] memArray [3:0];
wire [4:0] addrCol = {2'b0 , addr[1:0]} << 3;
assign col_out = {memArray[3][addrCol +: 8], memArray[2][addrCol +: 8], memArray[1][addrCol +: 8], memArray[0][addrCol +: 8]};
//reverse wires

always @(posedge clk, posedge reset) begin
	if(reset) begin
		for(integer i = 0; i < 4; i = i + 1) memArray[i] = 32'b0;
	end else if(we) begin
		memArray[addr[3:2]][addrCol +: 8] = data_in;	
	end

end


endmodule
