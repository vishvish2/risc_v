module risc_v (output logic [31:0] CPUOut,
                input logic [31:0] CPUIn,
                input logic CLK, Reset);

logic [31:0] PC, PCNext, Instr;

logic MemWrite, ALUSrc, RegWrite, Zero, Negative;
logic [4:0] ALUControl;
logic [2:0] ImmSrc;
logic [1:0] PCSrc, ResultSrc;

logic [31:0] RD1, RD2, WD3;
logic [4:0] A1, A2, A3;
logic WE3;

logic [31:0] ImmExt, ALUResult, SrcA, SrcB;
logic [31:0] RD, A, WD;

logic [31:0] PCPlus4, PCTarget, Result;

assign A1 = Instr[19:15];
assign A2 = Instr[24:20];
assign A3 = Instr[11:7];
assign WE3 = RegWrite;
assign SrcA = RD1;
assign SrcB = (ALUSrc == 1'b1) ? ImmExt : RD2;
assign PCPlus4 = PC + 32'd4;
assign PCTarget = PC + ImmExt;
assign WD = RD2;
assign A = ALUResult;
assign WD3 = Result;

program_counter prog_count (PC, PCNext, CLK, Reset);

instruction_memory instr_mem (Instr, PC);

control_unit cu (MemWrite, ALUSrc, RegWrite, ALUControl, ImmSrc, PCSrc,
    ResultSrc, Instr, Zero, Negative);

reg_file register (RD1, RD2, WD3, A1, A2, A3, WE3, CLK);

extend ext (ImmExt, ImmSrc, Instr);

alu arith_logic (ALUResult, Zero, Negative, SrcA, SrcB, ALUControl);

data_memory_and_io data_mem (RD, CPUOut, A, WD, CPUIn, MemWrite, CLK); 

assign Result = (ResultSrc == 2'b00) ? ALUResult:
                (ResultSrc == 2'b01) ? RD:
                (ResultSrc == 2'b10) ? PCPlus4:
                                        ImmExt;

assign PCNext = (PCSrc == 2'b00) ? PCPlus4:
                (PCSrc == 2'b01) ? PCTarget:
                (PCSrc == 2'b10) ? ALUResult:
                                    PCPlus4;

endmodule