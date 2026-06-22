SIM            ?= icarus
TOPLEVEL_LANG  ?= verilog

VERILOG_SOURCES += $(PWD)/../risc_v.srcs/sources_1/new/program_counter.sv
VERILOG_SOURCES += $(PWD)/wrappers/program_counter_test.sv
VERILOG_SOURCES += $(PWD)/../risc_v.srcs/sources_1/new/extend.sv
VERILOG_SOURCES += $(PWD)/../risc_v.srcs/sources_1/new/alu.sv

COMPILE_ARGS += -g2012
all: pc ext
pc:
	rm -rf sim_build
	mkdir -p dump_files
	$(MAKE) sim COCOTB_TEST_MODULES=program_counter_tb COCOTB_TOPLEVEL=program_counter_test

ext:
	rm -rf sim_build
	$(MAKE) sim COCOTB_TEST_MODULES=extend_tb COCOTB_TOPLEVEL=extend

alu:
	rm -rf sim_build
	$(MAKE) sim COCOTB_TEST_MODULES=alu_tb COCOTB_TOPLEVEL=alu


include $(shell cocotb-config --makefiles)/Makefile.sim