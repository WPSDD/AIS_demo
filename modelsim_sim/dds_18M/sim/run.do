quit -sim
.main clear

vlib work
vlog ./tb_dds_18M.v
vlog ./altera_lib/altera_mf.v
vlog ./../design/*.v
vlog ./../quartus_prj/ipcore_dir/sp_ram_256x8.v

vsim -voptargs=+acc work.tb_dds_18M

add wave tb_dds_18M/dds_18M_inst/*

run 10us