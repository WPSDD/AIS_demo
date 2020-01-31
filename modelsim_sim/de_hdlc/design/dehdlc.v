module dehdlc(
		input wire		sclk,
		input wire		rst_n,
		input wire		data_in,
		output reg		flag1,
		output reg		flag2,
		output reg		cnt

);

parameter S1 = 7'b000_0001;
parameter S2 = 7'b000_0010;
parameter S3 = 7'b000_0100;
parameter S4 = 7'b000_1000;
parameter S5 = 7'b001_0000;
parameter S6 = 7'b010_0000;
parameter S7 = 7'b100_0000;

reg [6:0]	state;

always @(posedge sclk or negedge rst_n)
		if(rst_n == 1'b0)
				state <= S1;
		else
			case(state)
				S1: if(data_in == 1)
							state <= S2;
					 else
							state <= S1;
				S2: if(data_in == 1)
							state <= S3;
					 else
							state <= S1;
				S3: if(data_in == 1)
							state <= S4;
					 else
							state <= S1;
				S4: if(data_in == 1)
							state <= S5;
					 else
							state <= S1;
				S5: if(data_in == 1)
							state <= S6;
					 else
							state <= S1;
				S6: if(data_in == 1)
							state <= S7;
					 else
							state <= S1;
				S7: if(data_in == 1)
							state <= S7;
					 else
							state <= S1;
				default: state <= S1;
			endcase
			
always @(posedge sclk or negedge rst_n)begin
		if(rst_n == 1'b0)
			begin
				flag1 <= 1'b0;
				flag2 <= 1'b0;
			end
		else if(state == S5 && data_in == 1'b1)
			begin
				flag1 <= 1'b1;
				flag2 <= 1'b0;
			end
		else if(state == S6 && data_in == 1'b1)
			begin
				flag1 <= 1'b0;
				flag2 <= 1'b1;
			end
		else
			begin
				flag1 <= 1'b0;
				flag2 <= 1'b0;
			end
end
	
always @(posedge sclk or negedge rst_n)begin
		if(rst_n == 1'b0)
			cnt <= 1'b0;
		else if(flag2 == 1)
			cnt <= cnt + 1'b1;
end

endmodule

