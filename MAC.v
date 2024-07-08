
module MAC(
	input        clk,  reset, 
	input [7:0]  A_in, W_in, 
	input [23:0] PS_in,
	
	output [7:0]  A_Pass, W_Pass,
       	output reg [23:0] PS_Pass 
);


reg [7:0] A, W;
reg loadWeightFlag;

assign A_Pass = A; 
assign W_Pass = loadWeightFlag ? W_in : 1'b0;

always @(posedge clk, posedge reset) begin

	if(reset) begin
		A = 8'b0;
		W = 8'b0;
		PS_Pass = 24'b0;		
		loadWeightFlag = 1'b0;
	end else begin
		if(~loadWeightFlag) begin
		       	W = W_in;
			loadWeightFlag = 1'b1;
		end else begin
			A <= A_in; 	
			PS_Pass <= A_in * W + PS_in;
		end
	end

end


endmodule

