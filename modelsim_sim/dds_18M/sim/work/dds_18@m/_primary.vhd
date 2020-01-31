library verilog;
use verilog.vl_types.all;
entity dds_18M is
    generic(
        frq_w           : integer := 154404074;
        phi_bias        : integer := 1073741824
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        o_sin           : out    vl_logic_vector(7 downto 0);
        o_cos           : out    vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of frq_w : constant is 1;
    attribute mti_svvh_generic_type of phi_bias : constant is 1;
end dds_18M;
