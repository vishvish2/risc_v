SIM            ?= icarus
TOPLEVEL_LANG  ?= verilog

VERILOG_SOURCES += $(PWD)/../risc_v.srcs/sources_1/new/program_counter.sv
VERILOG_SOURCES += $(PWD)/wrappers/program_counter_test.sv
VERILOG_SOURCES += $(PWD)/../risc_v.srcs/sources_1/new/extend.sv

COMPILE_ARGS += -g2012

pc:
	mkdir -p dump_files
	$(MAKE) sim COCOTB_TEST_MODULES=program_counter_tb COCOTB_TOPLEVEL=program_counter_test


include $(shell cocotb-config --makefiles)/Makefile.sim