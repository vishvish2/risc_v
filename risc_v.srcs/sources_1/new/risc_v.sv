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

logic [31:0] PCF, PCNextF, PCPlus4F, PCPlus4D, PCPlus4E, PCPlus4M, PCPlus4W;
logic [31:0] InstrD, PCD, PCE, PCTargetE, ImmExtD, ImmExtE;
logic [31:0] RDE1, RDE2, SrcAE, SrcBE, ALUResultM, WriteDataE, WriteDataM, ReadDataW, ResultW;
logic [4:0] Rs1D, Rs2D, RdD, Rs1E, Rs2E, RdE, RdM, RdW;
logic ZeroE, NegativeE;

logic RegWriteD, RegWriteE, RegWriteM, RegWriteW;
logic [1:0] ResultSrcD, ResultSrcE, ResultSrcM, ResultSrcW;
logic MemWriteD, MemWriteE, MemWriteM;
logic JumpD;
logic BranchD;
logic [4:0] ALUControlD, ALUControlE;
logic ALUSrcD, ALUSrcE;
logic [2:0] ImmSrcD;
logic [1:0] PCSrcE;

logic StallF, StallD, FlushD, FlushE;
logic [1:0] ForwardAE, ForwardBE;

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

program_counter prog_count (PC, PCNext, CLK, Reset, 0);

instruction_memory instr_mem (Instr, PC);

control_unit cu (MemWrite, ALUSrc, RegWrite, ALUControl, ImmSrc, PCSrc,
    ResultSrc, JumpD, BranchD, Instr, Zero, Negative);

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