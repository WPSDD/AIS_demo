`timescale 100ps/100ps
module tb_dds_18M;
reg	    sclk, rst_n;
wire	[7:0]	o_sin;
wire	[7:0]	o_cos;
initial begin
	sclk  = 0;
	rst_n = 0;
	#100 
	rst_n = 1;
end

always #10 sclk =~ sclk;    //500Mhz

dds_18M dds_18M_inst(
	.clk		(sclk),
	.rst_n		(rst_n),
	.o_sin		(o_sin),
    .o_cos		(o_cos)
);
endmodule
