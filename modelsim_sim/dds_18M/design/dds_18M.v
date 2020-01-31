module  dds_18M(
    input   wire            clk,
    input   wire            rst_n,
    output  wire  [7:0]     o_sin,
    output  wire  [7:0]     o_cos
);

parameter   frq_w = 32'd154404074;     //频率控制字
parameter   phi_bias = 32'd1073741824;  //余弦函数相对于正弦函数的相位偏移量

reg    [31:0]      phi_sum_sin;    //正弦相位累加器
reg    [31:0]      phi_sum_cos;    //余弦相位累加器
wire   [7:0]       addr_sin;       //存放正弦函数值的RAM地址
wire   [7:0]       addr_cos;       //存放余弦函数值的RAM地址

always  @(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)begin
        phi_sum_sin <= 1'b0;
        phi_sum_cos <= phi_bias;
        end
    else begin
        phi_sum_sin <= phi_sum_sin + frq_w;
        phi_sum_cos <= phi_sum_cos + frq_w;
        end

assign  addr_sin = phi_sum_sin[31:24];
assign  addr_cos = phi_sum_cos[31:24];

sp_ram_256x8	sp_ram_256x8_inst_sin (
	.address ( addr_sin ),
	.clock ( clk ),
	.data ( 8'd0 ),
	.wren ( 1'b0 ),
	.q ( o_sin )
	);

sp_ram_256x8	sp_ram_256x8_inst_cos (
	.address ( addr_cos ),
	.clock ( clk ),
	.data ( 8'd0 ),
	.wren ( 1'b0 ),
	.q ( o_cos )
	);

endmodule