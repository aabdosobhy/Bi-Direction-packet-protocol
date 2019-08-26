create_clock -period 20.000 -name sysClk -waveform {0.000 10.000} [get_pins */PS7_inst/FCLKCLK[0]]

set_property PACKAGE_PIN R19 [get_ports  {clk_o}] 
# RFW 
#set_property PACKAGE_PIN T9 [get_ports  "ser_data_O_p"]
#set_property PACKAGE_PIN U10 [get_ports  "ser_data_O_n"]

# RFE
set_property PACKAGE_PIN P14 [get_ports  {ser_data_O_p}]
set_property PACKAGE_PIN R14 [get_ports  {ser_data_O_n}]
set_property PACKAGE_PIN E18 [get_ports  {rst_o_p}]
set_property PACKAGE_PIN E19 [get_ports  {rst_o_n}]

#set_property IOSTANDARD LVCMOS18 [get_ports {clk}]
set_property IOSTANDARD LVCMOS25 [get_ports {clk_o}]
set_property IOSTANDARD LVDS_25  [get_ports {ser_data_O_*}]
set_property IOSTANDARD LVDS_25  [get_ports {rst_o_*}]


# SCL/ICSP Clock	JX2_SE_0[G14]
set_property PACKAGE_PIN G14 [get_ports i2c_scl]
set_property IOSTANDARD LVCMOS25 [get_ports i2c_scl]
set_property SLEW SLOW [get_ports i2c_scl]
set_property DRIVE 12 [get_ports i2c_scl]

# SDA/ICSP Data		JX2_SE_1[J15]
set_property PACKAGE_PIN J15 [get_ports i2c_sda]
set_property IOSTANDARD LVCMOS25 [get_ports i2c_sda]
set_property SLEW SLOW [get_ports i2c_sda]
set_property DRIVE 12 [get_ports i2c_sda]