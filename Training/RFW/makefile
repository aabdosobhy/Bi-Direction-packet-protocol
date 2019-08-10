BOARD="MachXO2"
DEVICE="LCMXO2-1200HC"
PKG="TQFP100"
GRADE=4
SEARCH="/usr/local/diamond/3.10_x64/ispfpga/vhdl/data/"
BUILD= ./build/
SRC= ./src/
CFG= ./cfg/

ALL:	train.bit

%.edi : %.vhd 
	@echo "1"
	synpwrap -prj "$*.prj"

%.ngo : %.edi
	@echo "2"
	edif2ngd -l $(BOARD) -d $(DEVICE) $< $@

%.ngd : %.ngo
	@echo "3"
	ngdbuild -a $(BOARD) -d $(DEVICE) -p $(SEARCH) $< $@

%.ncd : %.ngd %.lpf
	@echo "4"	
	map -a $(BOARD) -p $(DEVICE) -t $(PKG) -s $(GRADE) $< -o $@ $*.lpf

%.o.ncd : %.ncd
	@echo "5"
	par -w $< $*.o.ncd $*.prf

%.bit : %.o.ncd
	bitgen -w $< $@

#$(BUILD)%.svf : $(BUILD)%.bit
#	@echo "create bitmap"
#	ddtcmd -oft -svfsingle -revd -op "SRAM Fast Program" -if $< -of $@

clean:
	rm -f *~ *.db *.htm *.xml
	rm -f *.alt *.asd *.bgn *.cam 
	rm -f *.drc *.edi *.ext *.fse
	rm -f *.hrr *.jed *.log *.mrp
	rm -f *.ncd *.ngd *.ngo *.out
	rm -f *.pad *.par *.prf *.prs
	rm -f *.rpt *.sdc *.srd *.srm
	rm -f *.srr *.srs *.twr *.bit
	rm -f *.bin *.hex *.svf
	rm -f *_synplify.lpf
	rm -f *_synplify_tmp*
	rm -f *.areasrr *.ncd.asc
	rm -f stdout.log.bak*
	rm -f run_options.txt
	rm -f _cmd._cml
	rm -f _CMD_COMPILER.CML
	rm -rf backup
	rm -rf dm
	rm -rf coreip
	rm -rf physical_plus
	rm -rf synlog
	rm -rf synwork
	rm -rf syntmp
