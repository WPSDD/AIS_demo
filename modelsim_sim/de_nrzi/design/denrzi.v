module	denrzi(
	input wire		sclk,
	input wire		data_demo,
	input wire		data_demo_dly,
	output reg		data_denrzi
);


always @(posedge sclk)begin
//	if(rst_n == 1'b1)
		if(data_demo == data_demo_dly)
			 data_denrzi <= 1'b1;
		else
			 data_denrzi <= 1'b0;
end

endmodule


