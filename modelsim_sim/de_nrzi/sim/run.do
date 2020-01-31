quit -sim
.main clear

vlib	./lib/
vlib	./lib/work/
vlib	./lib/design/
#vlib	./lib/altera_lib/

vmap	base_space ./lib/work/
vmap	design ./lib/design/
#vmap	altera_lib ./lib/altera_lib/

vlog	-work base_space	./tb_denrzi.v
vlog	-work design		./../design/*.v
#vlog	-work altera_lib	./altera_lib/*.v

vsim	 -voptargs=+acc	-L base_space -L design base_space.tb_denrzi
#vsim	-t ns -sdfmax tb_pad_test/pad_test_inst=pad_test_v.sdo -voptargs=+acc	-L altera_lib -L base_space -L design base_space.tb_pad_test

add wave	-divider {tb_denrzi}
add wave	tb_denrzi/*
add wave	-divider {denrzi}
add wave	tb_denrzi/denrzi_inst/*

run 10us

