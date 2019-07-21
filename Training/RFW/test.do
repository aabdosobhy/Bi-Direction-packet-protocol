
vsim work.train

add wave -position insertpoint  \
sim:/train/SEED \
sim:/train/clk \
sim:/train/datain \
sim:/train/rst \
sim:/train/BE_cnt \
sim:/train/e_clk \
sim:/train/s_clk \
sim:/train/word_align \
sim:/train/not_clk \
sim:/train/dec_8b \
sim:/train/rst_sys \
sim:/train/v_rst \
sim:/train/pdata2mux \
sim:/train/state \
sim:/train/decoderIn \
sim:/train/decoderOut \
sim:/train/reg4W_10b \
sim:/train/en_PRNG \
sim:/train/PRNG_O \
sim:/train/PRNG_8b \
sim:/train/error_cnt \
sim:/train/BE_I \
sim:/train/BE_O
force -freeze sim:/train/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/train/datain 1 0
force -freeze sim:/train/rst 1 0
run
force -freeze sim:/train/rst 0 0
run
run
run
force -freeze sim:/train/datain 0 0
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run