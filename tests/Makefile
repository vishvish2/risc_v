SIM            ?= icarus
TOPLEVEL_LANG  ?= verilog

VERILOG_SOURCES += $(PWD)/../risc_v.srcs/sources_1/new/program_counter.sv

COMPILE_ARGS += -g2012

pc:
	$(MAKE) sim COCOTB_TEST_MODULES=program_counter_tb TOPLEVEL=program_counter

clean::
	rm -rf results.xml sim_build

include $(shell cocotb-config --makefiles)/Makefile.sim