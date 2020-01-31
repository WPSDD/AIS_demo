`timescale 1ns/1ns
module	tb_pad_test;
	reg	sclk, rst_n;
	reg	data_in;
	reg	[0:0] mem1x186 [185:0];
	wire	flag;
	integer	handle;
	
initial	begin
	sclk = 0;
	rst_n = 0;
	#100
	rst_n = 1;
end

initial	begin
	data_in = 0;
	#150
	read_data();
end

always #10 sclk <= ~sclk;

initial	begin
	$readmemb("./data_pad.txt",mem1x186);
end


pad_test pad_test_inst(
		.sclk					(sclk),			
		.rst_n				(rst_n),
		.data_pad			(data_in),
		.flag					(flag)
);

task read_data();
	integer i;
	begin
			handle = $fopen("./data_out.txt");
			for(i=0; i<186; i=i+1)
			begin
				@(posedge sclk)
				data_in = mem1x186[i[7:0]];
				if(flag == 1'b0)
						$fdisplay(handle, "%b", data_in);
				else	;
			end
			$fclose(handle);
	end
endtask
endmodule
