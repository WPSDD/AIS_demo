library verilog;
use verilog.vl_types.all;
entity dehdlc is
    generic(
        S1              : vl_logic_vector(0 to 6) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1);
        S2              : vl_logic_vector(0 to 6) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0);
        S3              : vl_logic_vector(0 to 6) := (Hi0, Hi0, Hi0, Hi0, Hi1, Hi0, Hi0);
        S4              : vl_logic_vector(0 to 6) := (Hi0, Hi0, Hi0, Hi1, Hi0, Hi0, Hi0);
        S5              : vl_logic_vector(0 to 6) := (Hi0, Hi0, Hi1, Hi0, Hi0, Hi0, Hi0);
        S6              : vl_logic_vector(0 to 6) := (Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0);
        S7              : vl_logic_vector(0 to 6) := (Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0)
    );
    port(
        sclk            : in     vl_logic;
        rst_n           : in     vl_logic;
        data_in         : in     vl_logic;
        flag1           : out    vl_logic;
        flag2           : out    vl_logic;
        cnt             : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of S1 : constant is 1;
    attribute mti_svvh_generic_type of S2 : constant is 1;
    attribute mti_svvh_generic_type of S3 : constant is 1;
    attribute mti_svvh_generic_type of S4 : constant is 1;
    attribute mti_svvh_generic_type of S5 : constant is 1;
    attribute mti_svvh_generic_type of S6 : constant is 1;
    attribute mti_svvh_generic_type of S7 : constant is 1;
end dehdlc;
