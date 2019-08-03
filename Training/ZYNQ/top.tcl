set pwd [pwd]

#cd $work_directory

set OS [lindex $tcl_platform(os) 0]
if { $OS == "Windows" } {
    exec cmd /c mkdir build.vivado
} else {
    exec mkdir build.vivado
}
cd build.vivado

create_project Train_ZYNQ [pwd]


read_vhdl -vhdl2008 ../register.vhd
read_vhdl -vhdl2008 ../Shift_reg.vhd
read_vhdl -vhdl2008 ../8b10_enc.vhd
read_vhdl -vhdl2008 ../PRNG.vhd
read_vhdl -vhdl2008 ../serializer.vhd
read_vhdl -vhdl2008 ../train.vhd
read_vhdl -vhdl2008 ../top.vhd

read_xdc ../top.xdc

set_property part xc7z020clg484-1 [current_project]

set_property TARGET_LANGUAGE VHDL [current_project]


launch_runs synth_1

launch_runs impl_1