module pad_test(
		input wire		sclk,
		input wire		rst_n,
		input wire		data_pad,
		output reg		flag
);

parameter S1 = 6'b00_0001;
parameter S2 = 6'b00_0010;
parameter S3 = 6'b00_0100;
parameter S4 = 6'b00_1000;
parameter S5 = 6'b01_0000;
parameter S6 = 6'b10_0000;

reg [5:0]	state;

always @(posedge sclk or negedge rst_n)
		if(rst_n == 1'b0)
				state <= S1;
		else
			case(state)
				S1: if(data_pad == 1)
							state <= S2;
					 else
							state <= S1;
				S2: if(data_pad == 1)
							state <= S3;
					 else
							state <= S1;
				S3: if(data_pad == 1)
							state <= S4;
					 else
							state <= S1;
				S4: if(data_pad == 1)
							state <= S5;
					 else
							state <= S1;
				S5: if(data_pad == 1)
							state <= S6;
					 else
							state <= S1;
				S6: state <= S1;
				default: state <= S1;
			endcase
			
always @(posedge sclk or negedge rst_n)
		if(rst_n == 1'b0)
				flag <= 1'b0;
		else if(state == S5 && data_pad == 1'b1)
				flag <= 1'b1;
		else
				flag <= 1'b0;

endmodule

