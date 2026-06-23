module risc_v (output logic [31:0] CPUOut,
           input logic [31:0] CPUIn,
           input logic CLK, Reset);

// Fetch stage signals
logic [31:0] PCF, PCNextF, PCPlus4F, InstrF;

// Decode stage signals
logic [31:0] InstrD, PCD, PCPlus4D;
logic [31:0] RD1D, RD2D, ImmExtD;
logic [4:0] Rs1D, Rs2D, RdD;

logic RegWriteD, MemWriteD, ALUSrcD;
logic [1:0] ResultSrcD, JumpD;
logic [2:0] BranchD;          // branch type: 000=none,001=beq,010=bne,011=blt,100=bge
logic [4:0] ALUControlD;
logic [2:0] ImmSrcD;
logic [1:0] PCSrcD;           // CU output unused in pipeline

// Execute stage signals
logic [31:0] PCE, PCPlus4E, RD1E, RD2E, ImmExtE;
logic [4:0] Rs1E, Rs2E, RdE;
logic RegWriteE, MemWriteE, ALUSrcE;
logic [1:0] ResultSrcE, JumpE;
logic [2:0] BranchE;
logic [4:0] ALUControlE;

logic [31:0] SrcAE, SrcBE_fwd, SrcBE;   // SrcBE_fwd = post-forward, pre-imm mux
logic [31:0] WriteDataE, ALUResultE, PCTargetE;
logic ZeroE, NegativeE;
logic [1:0] PCSrcE;
logic [1:0] ForwardAE, ForwardBE;

// Memory stage signals
logic [31:0] ALUResultM, WriteDataM, PCPlus4M, ImmExtM;
logic [4:0] RdM;
logic RegWriteM, MemWriteM;
logic [1:0] ResultSrcM;
logic [31:0] ReadDataM;

// Writeback stage signals
logic [31:0] ALUResultW, ReadDataW, PCPlus4W, ImmExtW;
logic [4:0] RdW;
logic RegWriteW;
logic [1:0] ResultSrcW;
logic [31:0] ResultW;

// Hazard unit signals
logic StallF, StallD, FlushD, FlushE;

always_comb begin
    if (JumpE == 2'b01)
        PCSrcE = 2'b01;                             // jal
    else if (JumpE == 2'b10)
        PCSrcE = 2'b10;                             // jalr
    else begin
        case (BranchE)
            3'b001: PCSrcE = ZeroE ? 2'b01 : 2'b00;         // beq
            3'b010: PCSrcE = ~ZeroE ? 2'b01 : 2'b00;        // bne
            3'b011: PCSrcE = NegativeE ? 2'b01 : 2'b00;     // blt
            3'b100: PCSrcE = ~NegativeE ? 2'b01 : 2'b00;    // bge
            default: PCSrcE = 2'b00;                        // not a branch
        endcase
    end
end


assign PCNextF = (PCSrcE == 2'b01) ? PCTargetE :   // branch taken / jal
                 (PCSrcE == 2'b10) ? ALUResultE :  // jalr
                                     PCPlus4F;      // sequential

// Fetch stage
program_counter prog_count (
    .PC(PCF),
    .PCNext(PCNextF),
    .CLK(CLK),
    .Reset(Reset),
    .EN(StallF)     // EN=1 holds PC (stall)
);

instruction_memory instr_mem (
    .Instr(InstrF),
    .PC(PCF)
);

assign PCPlus4F = PCF + 32'd4;

// Fetch to Decode stage pipeline register
always_ff @(posedge CLK or posedge Reset) begin
    if (Reset || FlushD) begin
        InstrD <= 32'h00000013;   // addi x0, x0, 0
        PCD <= 32'b0;
        PCPlus4D <= 32'b0;
    end else if (!StallD) begin
        InstrD <= InstrF;
        PCD <= PCF;
        PCPlus4D <= PCPlus4F;
    end
    // StallD && !FlushD: hold (implicit - no else needed)
end

// Decode stage
assign Rs1D = InstrD[19:15];
assign Rs2D = InstrD[24:20];
assign RdD = InstrD[11:7];

// Control unit
// Zero and Negative are driven as 0 - PCSrcD is ignored.
control_unit cu (
    .MemWrite(MemWriteD),
    .ALUSrc(ALUSrcD),
    .RegWrite(RegWriteD),
    .ALUControl(ALUControlD),
    .ImmSrc(ImmSrcD),
    .PCSrc(PCSrcD),        // unused in pipeline
    .ResultSrc(ResultSrcD),
    .jump(JumpD),
    .branch(BranchD),
    .Instr(InstrD),
    .Zero(1'b0),          // placeholder - not needed for decode signals
    .Negative(1'b0)
);

// Register file
reg_file register (
    .RD1(RD1D),
    .RD2(RD2D),
    .WD3(ResultW),
    .A1(Rs1D),
    .A2(Rs2D),
    .A3(RdW),
    .WE3(RegWriteW),
    .CLK(CLK)
);

// Immediate extension
extend ext (
    .ImmExt(ImmExtD),
    .ImmSrc(ImmSrcD),
    .Instr(InstrD)
);

// Decode to Execute stage pipeline register
always_ff @(posedge CLK or posedge Reset) begin
    if (Reset || FlushE) begin
        RegWriteE <= 1'b0;
        MemWriteE <= 1'b0;
        ALUSrcE <= 1'b0;
        ResultSrcE <= 2'b00;
        JumpE <= 2'b00;
        BranchE <= 3'b000;
        ALUControlE <= 5'b0;
        PCE <= 32'b0;
        PCPlus4E <= 32'b0;
        RD1E <= 32'b0;
        RD2E <= 32'b0;
        ImmExtE <= 32'b0;
        Rs1E <= 5'b0;
        Rs2E <= 5'b0;
        RdE <= 5'b0;
    end else begin
        RegWriteE <= RegWriteD;
        MemWriteE <= MemWriteD;
        ALUSrcE <= ALUSrcD;
        ResultSrcE <= ResultSrcD;
        JumpE <= JumpD;
        BranchE <= BranchD;
        ALUControlE <= ALUControlD;
        PCE <= PCD;
        PCPlus4E <= PCPlus4D;
        RD1E <= RD1D;
        RD2E <= RD2D;
        ImmExtE <= ImmExtD;
        Rs1E <= Rs1D;
        Rs2E <= Rs2D;
        RdE <= RdD;
    end
end

// Execute Stage
assign SrcAE = (ForwardAE == 2'b10) ? ALUResultM :
                  (ForwardAE == 2'b01) ? ResultW :
                                         RD1E;

assign SrcBE_fwd = (ForwardBE == 2'b10) ? ALUResultM :
                   (ForwardBE == 2'b01) ? ResultW :
                                          RD2E;

assign WriteDataE = SrcBE_fwd;              // store data forwarded RD2, before imm mux
assign SrcBE      = ALUSrcE ? ImmExtE : SrcBE_fwd;

alu arith_logic (
    .ALUResult(ALUResultE),
    .Zero(ZeroE),
    .Negative(NegativeE),
    .A(SrcAE),
    .B(SrcBE),
    .ALUControl(ALUControlE)
);

assign PCTargetE = PCE + ImmExtE;           // branch / jal target

// Execute to Memory stage pipeline register
always_ff @(posedge CLK or posedge Reset) begin
    if (Reset) begin
        RegWriteM <= 1'b0;
        MemWriteM <= 1'b0;
        ResultSrcM <= 2'b00;
        ALUResultM <= 32'b0;
        WriteDataM <= 32'b0;
        PCPlus4M <= 32'b0;
        ImmExtM <= 32'b0;
        RdM <= 5'b0;
    end else begin
        RegWriteM <= RegWriteE;
        MemWriteM <= MemWriteE;
        ResultSrcM <= ResultSrcE;
        ALUResultM <= ALUResultE;
        WriteDataM <= WriteDataE;
        PCPlus4M <= PCPlus4E;
        ImmExtM <= ImmExtE;
        RdM <= RdE;
    end
end

// Memory stage
data_memory_and_io data_mem (
    .RD(ReadDataM),
    .CPUOut(CPUOut),
    .A(ALUResultM),
    .WD(WriteDataM),
    .CPUIn(CPUIn),
    .WE(MemWriteM),
    .CLK(CLK)
);

// Memory to Writeback stage pipeline register
always_ff @(posedge CLK or posedge Reset) begin
    if (Reset) begin
        RegWriteW <= 1'b0;
        ResultSrcW <= 2'b00;
        ALUResultW <= 32'b0;
        ReadDataW <= 32'b0;
        PCPlus4W <= 32'b0;
        ImmExtW <= 32'b0;
        RdW <= 5'b0;
    end else begin
        RegWriteW <= RegWriteM;
        ResultSrcW <= ResultSrcM;
        ALUResultW <= ALUResultM;
        ReadDataW <= ReadDataM;
        PCPlus4W <= PCPlus4M;
        ImmExtW <= ImmExtM;
        RdW <= RdM;
    end
end

// Writeback stage
assign ResultW = (ResultSrcW == 2'b00) ? ALUResultW :  // R/I-type
                 (ResultSrcW == 2'b01) ? ReadDataW :  // lw
                 (ResultSrcW == 2'b10) ? PCPlus4W :  // jal/jalr
                                         ImmExtW;        // lui (ResultSrc = 2'b11)

// Hazard unit
hazard_unit hu (
    .StallF(StallF),
    .StallD(StallD),
    .FlushD(FlushD),
    .FlushE(FlushE),
    .ForwardAE(ForwardAE),
    .ForwardBE(ForwardBE),
    .Rs1D(Rs1D),
    .Rs2D(Rs2D),
    .Rs1E(Rs1E),
    .Rs2E(Rs2E),
    .RdE(RdE),
    .RdM(RdM),
    .RdW(RdW),
    .ResultSrcE(ResultSrcE),
    .PCSrcE(PCSrcE),
    .RegWriteM(RegWriteM),
    .RegWriteW(RegWriteW)
);

endmodule
