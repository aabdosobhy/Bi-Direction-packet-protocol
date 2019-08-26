BOARD="MachXO2"
DEVICE="LCMXO2-1200HC"
PKG="TQFP100"
GRADE=6
SEARCH="/usr/local/diamond/3.10_x64/ispfpga/vhdl/data/"


ALL:	train.bit

%.edi : %.vhd %.fdc
	@echo "### running synpwrap ..."
	@synpwrap -prj train.prj >$*.synpwrap.out \
	    || ( ./cc.sh srr $*.srr && false )
	
	@echo "--- premap"
	@echo "--- compiler"
	@ ./cc.sh srr synlog/$*_compiler.srr
	@ ./cc.sh srr synlog/$*_premap.srr
	@echo "--- fpga_mapper"
	@ ./cc.sh srr synlog/$*_fpga_mapper.srr
	@echo "--- synpwrap"
	@ ./cc.sh synpwrap $*.synpwrap.out

%.ngo : %.edi
	@echo "### running edif2ngd ..."
	@edif2ngd -l $(BOARD) -d $(DEVICE) $< $@ \
	    |& tee $*.edif2ngd.out | ./cc.sh edif2ngd

%.ngd : %.ngo
	@echo "### running ngdbuild ..."
	@ngdbuild -a $(BOARD) -d $(DEVICE) -p $(SEARCH) $< $@ \
	    |& tee $*.ngdbuild.out | ./cc.sh ngdbuild

# %.ncd : %.ngd 
%.ncd : %.ngd %.lpf
	@echo "### running map ..."
	@map -a $(BOARD) -p $(DEVICE) -t $(PKG) -s $(GRADE) $< -o $@ \
	    |& tee $*.map.out | ./cc.sh map
	@ncdread $@ -o $@.asc \
	    |& ./cc.sh ncdread
	@./cc.sh mrp $*.mrp

%.o.ncd : %.ncd
	@echo "### running par ..."
	@par -w $< $*.o.ncd $*.prf \
	    |& tee $*.par.out | ./cc.sh par
	@ncdread $@ -o $@.asc \
	    |& ./cc.sh ncdread

%.twr : %.o.ncd
	trce -v $< $*.prf -o $@

%.bit : %.o.ncd
	@echo "### running bitgen ..."
	@bitgen -g RamCfg:Reset -w $< $@ \
	    |& tee $*.bitgen.out | ./cc.sh bitgen

%.jed : %.o.ncd
	@echo "### running bitgen ..."
	@bitgen -w -jedec $< $@ \
	    |& tee $*.bitgen.out | ./cc.sh bitgen

%.bin : %.jed
	@ddtcmd -oft -jed2bin -if $< -of $@ \
	    |& tee $*.ddtcmd.bin.out | ./cc.sh ddtcmd

%.hex : %.jed
	@ddtcmd -oft -jed2hex -compress on -if $< -of $@ \
	    |& tee $*.ddtcmd.hex.out | ./cc.sh ddtcmd

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
	rm -f _CMD_.CML
	rm -f _cmd._cml
	rm -f _CMD_COMPILER.CML
	rm -rf backup
	rm -rf dm
	rm -rf coreip
	rm -rf physical_plus
	rm -rf synlog*
	rm -rf synwork
	rm -rf syntmp
	rm -rf scemi_cfg*
	rm -rf .recordref