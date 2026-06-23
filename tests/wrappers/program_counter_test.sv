module program_counter_test(output logic [31:0] PC,
                            input logic [31:0] PCNext,
                            input logic CLK, Reset, EN);

program_counter program_counter(PC, PCNext, CLK, Reset, EN);

initial begin
	$dumpfile("dump_files/program_counter.vcd");
	$dumpvars;
end
endmodule
