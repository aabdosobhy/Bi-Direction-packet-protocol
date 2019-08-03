create_clock -period 10.000 -name sysClk -waveform {0.000 5.000} [get_ports -filter { NAME =~  "*clk*" && DIRECTION == "IN" }]

# RFW 
set_property PACKAGE_PIN T9 [get_ports -filter { NAME =~  "*lvds_p*" && DIRECTION == "IN" }]
set_property PACKAGE_PIN U10 [get_ports -filter { NAME =~  "*lvds_n*" && DIRECTION == "IN" }]

# RFE
#set_property PACKAGE_PIN T9 [get_ports -filter { NAME =~  "*lvds_p*" && DIRECTION == "IN" }]
#set_property PACKAGE_PIN U10 [get_ports -filter { NAME =~  "*lvds_n*" && DIRECTION == "IN" }]
#set_property PACKAGE_PIN T9 [get_ports -filter { NAME =~  "*lvds_p*" && DIRECTION == "IN" }]
#set_property PACKAGE_PIN U10 [get_ports -filter { NAME =~  "*lvds_n*" && DIRECTION == "IN" }]
