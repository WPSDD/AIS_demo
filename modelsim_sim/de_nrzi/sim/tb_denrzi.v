`timescale 1ns/100ps

module tb_denrzi;
	reg 	tb_clk, data_demo, data_demo_dly;
	reg	[0:0] mem1x256 [255:0];
	wire 	data_denrzi;
	integer	handle;
	
	initial 
	begin
		tb_clk <= 1'b0;
	end
	
	always #10 tb_clk <= ~tb_clk;
	
	initial	begin
		data_demo = 0;
		data_demo_dly = 0;
		#160
		read_data();
	end
	
	initial	begin
		$readmemb("./data_demo.txt",mem1x256);
	end
	
	denrzi denrzi_inst(
			.sclk					(tb_clk),
			.data_demo			(data_demo),
			.data_demo_dly		(data_demo_dly),
			.data_denrzi		(data_denrzi)
	);
	
	task read_data();
	integer i;
	begin
			handle = $fopen("./data_denrzi.txt");
			for(i=0; i<257; i=i+1)
			begin
				@(posedge tb_clk)
				if(i == 0)
					begin
						data_demo <= mem1x256[i[7:0]];
						data_demo_dly <= 1'b1;
					end
				else
					begin
						data_demo <= mem1x256[i[7:0]];
						data_demo_dly <= mem1x256[i[7:0]-1];
						#10 $fdisplay(handle, "%b", data_denrzi);
					end
			end
			$fclose(handle);
	end
	endtask
endmodule	
