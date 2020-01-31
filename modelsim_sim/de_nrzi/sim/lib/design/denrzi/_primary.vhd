library verilog;
use verilog.vl_types.all;
entity denrzi is
    port(
        sclk            : in     vl_logic;
        data_demo       : in     vl_logic;
        data_demo_dly   : in     vl_logic;
        data_denrzi     : out    vl_logic
    );
end denrzi;
