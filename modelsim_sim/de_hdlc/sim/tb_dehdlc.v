`timescale 1ns/1ns
module	tb_dehdlc;
	reg	sclk, rst_n;
	reg	data_in;
	reg	data0;
	reg	[7:0]	cnt0;
	reg	[0:0] mem1x256 [255:0];
	wire	flag1, flag2, cnt;
	integer	handle;
	
initial	begin
	sclk = 0;
	rst_n = 0;
	#100
	rst_n = 1;
end

initial	begin
	data_in <= 1'b0;
	data0 <= 1'b0;
	cnt0 <= 1'b0;
	#150
	read_data();
end

always #10 sclk <= ~sclk;

initial	begin
	$readmemb("./ais_denrzi.txt", mem1x256);
end


dehdlc dehdlc_inst(
		.sclk					(sclk),			
		.rst_n				(rst_n),
		.data_in				(data_in),
		.flag1				(flag1),
		.flag2				(flag2),
		.cnt					(cnt)
);

task read_data();
	integer i;
	begin
			handle = $fopen("./data_out.txt");
			for(i=0; i<256; i=i+1)
				begin
				@(posedge sclk)
				if(cnt0 < 8'd184)
					begin
					data_in <= mem1x256[i[7:0]];
					if(cnt == 1'b1)
						begin
						data0 <= data_in;
						if(flag1 == 1'b0)
							begin
							cnt0 <= cnt0 + 1'b1;
							$fdisplay(handle, "%b", data_in);
							end
						else	;
						end
					else  ;
					end
				else
					$fclose(handle);
				end
	end
endtask
endmodule
