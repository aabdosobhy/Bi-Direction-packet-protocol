set pwd [pwd]

set OS [lindex $tcl_platform(os) 0]
if { $OS == "Windows" } {
    exec cmd /c mkdir build.vivado
} else {
    exec mkdir build.vivado
}
cd build.vivado

create_project Train_ZYNQ [pwd]

read_vhdl -vhdl2008 ../../library/register.vhd
read_vhdl -vhdl2008 ../../library/shift_2b_reg.vhd
read_vhdl -vhdl2008 ../8b10_enc.vhd
read_vhdl -vhdl2008 ../PRNG.vhd
read_vhdl -vhdl2008 ../serializer.vhd
read_vhdl -vhdl2008 ../ps7_stub.vhd
read_vhdl -vhdl2008 ../train.vhd
read_vhdl -vhdl2008 ../top.vhd
read_xdc ../top.xdc

set_property PART xc7z020clg400-1 [current_project]
set_property board_part em.avnet.com:microzed_7020:part0:1.1 [current_project]
set_property TARGET_LANGUAGE VHDL [current_project]

launch_runs synth_1

launch_runs impl_1 -to_step write_bitstream -jobs 4