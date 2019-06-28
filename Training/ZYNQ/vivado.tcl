# Software version: Xilinx Vivado 2017.4
# Product Family: Zynq-7000 
# Target Device: xc7z020clg400-1
# Language: VHDL

# reading all files 
read_vhdl -vhdl2008 register.vhd
read_vhdl -vhdl2008 Shift_reg.vhd
read_vhdl -vhdl2008 8b10_enc.vhd
read_vhdl -vhdl2008 PRNG.vhd
read_vhdl -vhdl2008 serializer.vhd
read_vhdl -vhdl2008 train.vhd


update_compile_order -fileset sources_1
update_compile_order -fileset sources_1
launch_simulation

set_property PART xc7z020clg400-1 [current_project]
set_property TARGET_LANGUAGE VHDL [current_project]




add_force {/train/clk} -radix hex {1 0ns} {0 50000ps} -repeat_every 100000ps
add_force {/train/rst} -radix hex {1 0ns}
run 100 ns
add_force {/train/rst} -radix hex {0 0ns}
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns






