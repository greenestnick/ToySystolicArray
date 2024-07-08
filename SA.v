`include "./MAC.v"
`include "./MEM44.v"

module SA (
	input clk, rst, we, ena,
	input [1:0] sel,
	input [3:0] addr,
	input [7:0] data_in
);


wire [31:0] weightPassWires [4:0];
wire [31:0] fifoInputWires;
wire [31:0] featurePassWires [4:0];
wire [95:0] partialPassWires [4:0];
assign partialPassWires[0] = 96'b0;
wire  [3:0] macReset;

// Generation of the 4x4 Systolic Array with relevant interconnect wires
genvar i;
generate
	for(i = 0; i < 16; i = i + 1) begin : macgen
		localparam integer c = i % 4;
		localparam integer r = i >> 2;
		
		//clk reset A_in W_in PS_in --> A_Pass W_Pass PS_Pass	
		MAC mac (clk, macReset[r], featurePassWires[c][r * 8 +: 8], weightPassWires[r][c * 8 +: 8], partialPassWires[r][c * 24 +: 24], featurePassWires[c + 1][r * 8 +: 8], weightPassWires[r + 1][c * 8 +: 8], partialPassWires[r + 1][c * 24 +: 24]);
	end
endgenerate

//Memory Elements that hold the weights, features, and resultant matricies
wire [3:0] addrInternal = addr & {4{we}} | loadAddr;
MEM44 weightMem    (clk, rst, we & ~ena & (sel == 2'b00), addrInternal, data_in, weightPassWires[0]);
MEM44 featureMem   (clk, rst, we & ~ena & (sel == 2'b01), addrInternal, data_in, fifoInputWires);
MEM44 writebackMem (clk, rst, wbwe, loadAddr, activationFunct, );

//Control Logic, FIFO buffers
reg [31:0] featureLoadFIFO [3:0];
reg [1:0] loadStage;
reg [3:0] loadAddr;
wire [3:0] fifoReset;
reg [3:0] enableShift;
reg wbwe;

assign macReset = (we | rst) ? 4'hf : ((loadStage == 2'b0) ? enableShift: 4'b0);
assign fifoReset = (we) ? 4'hf : ((loadStage == 2'b1) ? enableShift: 4'b0); 

assign featurePassWires[0][7:0]   = fifoReset[0] ? 8'b0 : featureLoadFIFO[0][7:0];
assign featurePassWires[0][15:8]  = fifoReset[1] ? 8'b0 : featureLoadFIFO[1][7:0];
assign featurePassWires[0][23:16] = fifoReset[2] ? 8'b0 : featureLoadFIFO[2][7:0];
assign featurePassWires[0][31:24] = fifoReset[3] ? 8'b0 : featureLoadFIFO[3][7:0];

//Quantization units built as combinatorial logic. Can
wire [7:0] quant [3:0];
assign quant[0] = (partialPassWires[4][0  +: 24] <= 8'hff) ? partialPassWires[4][0  +: 24] : 8'hff; 
assign quant[1] = (partialPassWires[4][24 +: 24] <= 8'hff) ? partialPassWires[4][24 +: 24] : 8'hff; 
assign quant[2] = (partialPassWires[4][48 +: 24] <= 8'hff) ? partialPassWires[4][48 +: 24] : 8'hff; 
assign quant[3] = (partialPassWires[4][72 +: 24] <= 8'hff) ? partialPassWires[4][72 +: 24] : 8'hff; 

//Output FIFOs
reg [71:0] outputFIFO;
reg [2:0] outputFifoReset;

//Activation Function Logic
reg [7:0] activationThresh;
wire [7:0] activationWire = (loadAddr >= 4'd4) ? outputFIFO[0 +: 8] : quant[0];
wire [7:0] activationFunct = (activationWire < activationThresh) ? 8'h0 : activationWire;


//General control logic and FIFO logic
always @(posedge clk or posedge rst) begin
	if(rst) begin
		for(integer i = 0; i < 4; i = i + 1) featureLoadFIFO[i] = 32'b0;
		loadStage = 2'b0;
		loadAddr = 4'b0;
		enableShift = 4'b1110;
		wbwe = 1'b0;
		activationThresh = 8'b0;
		outputFIFO= 72'b0;
		outputFifoReset = 3'b111;

	end else if(~ena & we & sel == 2'b10) begin
		activationThresh = data_in;		
	
	end else if(ena & ~we) begin

		for(integer i = 0; i < 4; i = i + 1)
			if(~fifoReset[i]) featureLoadFIFO[i] = featureLoadFIFO[i] >> 8;
		
		outputFIFO = outputFIFO >> 8;
		if(outputFifoReset[0]) outputFIFO[16 +: 8] = quant[1];
		if(outputFifoReset[1]) outputFIFO[40 +: 8] = quant[2];
		if(outputFifoReset[2]) outputFIFO[64 +: 8] = quant[3];

		
		case (loadStage) 
			0: begin // Loading the weights and feature FIFOs
				
				for(integer i = 0; i < 4; i = i + 1) featureLoadFIFO[i] = {fifoInputWires[i * 8 +: 8], featureLoadFIFO[i][0 +: 24]};	
				
				if(loadAddr == 4'd3) begin 
					loadAddr  = 4'b1111;
					enableShift = 4'b1111;
					loadStage = loadStage + 1;
				end
			end

			1: begin //Begin multiplying until the first output is completed
				if(loadAddr == 4'd3) begin 
					loadAddr  = 4'b1111;
					wbwe = 1'b1;
					loadStage = loadStage + 1;
				end
			end

			2: begin //Continue multiplying and storing results back into memory		
				if(loadAddr >= 4'd4) outputFifoReset = outputFifoReset << 1;

				if(loadAddr == 4'd15) begin
					loadStage = loadStage + 1;
					wbwe = 1'b0;
				end
			end
		endcase
		enableShift = enableShift << 1;
		loadAddr = loadAddr + 1;
		
	end
end


endmodule
