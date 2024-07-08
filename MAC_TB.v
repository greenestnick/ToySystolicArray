
`include "./MAC.v"

module MAC_TB();

	reg clk;
	reg [1:0] reset;
	reg [7:0] A11, A21, W11, W12;
	wire [7:0] Ap11, Ap12, Ap21, Ap22, Wp11, Wp12, Wp21, Wp22;
	wire [23:0] PSp11, PSp12, PSp21, PSp22;

	//         clk, reset, A,   W,     PS, Ap,   Wp,   PSp
	MAC mac11 (clk, reset[0], A11,  W11,  24'b0, Ap11, Wp11, PSp11);	
	MAC mac12 (clk, reset[0], Ap11, W12,  24'b0, Ap12, Wp12, PSp12);		
	MAC mac21 (clk, reset[1], A21,  Wp11, PSp11, Ap21, Wp21, PSp21);
	MAC mac22 (clk, reset[1], Ap21, Wp12, PSp12, Ap22, Wp22, PSp22);

	initial begin
		clk = 1'b0;
		reset = 2'b11;

		$monitor(
		"Time: %3t\n\t", $time,
		"%d\t\t%d\n", W11, W12, 
		"%d\t%d,%d,%3d\t%d,%d,%3d\n", A11, mac11.A, mac11.W, mac11.PS_in, mac12.A, mac12.W, mac12.PS_in,
		"   \t%d,%d,%3d\t%d,%d,%3d\n\n", mac11.A_Pass, mac11.W_Pass, mac11.PS_Pass, mac12.A_Pass, mac12.W_Pass, mac12.PS_Pass,	
		"%d\t%d,%d,%3d\t%d,%d,%3d\n", A21, mac21.A, mac21.W, mac21.PS_in, mac22.A, mac22.W, mac22.PS_in, 	
		"   \t%d,%d,%3d\t%d,%d,%3d\n", mac21.A_Pass, mac21.W_Pass, mac21.PS_Pass, mac22.A_Pass, mac22.W_Pass, mac22.PS_Pass 
		);
	
		#10

		reset = 2'b10;		
		W11 = 8'd4;
		W12 = 8'd10;
		repeat (2) #10 clk = ~clk;
		reset = 2'b00;
		W11 = 8'd9;
		W12 = 8'd6;
		repeat (2) #10 clk = ~clk;
		
		W11 = 8'bx;
		W12 = 8'bx;	
		A11 = 8'd2;
		A21 = 8'd0;  
                repeat (2) #10 clk = ~clk;
		A11 = 8'd3;
		A21 = 8'd7;
		repeat (2) #10 clk = ~clk;
		A11 = 8'dx;
		A21 = 8'd1;
		repeat (2) #10 clk = ~clk;
		A21 = 8'dx;
		repeat (4) #10 clk = ~clk;


		reset = 2'b11;
		$finish;
	end	
	

endmodule
