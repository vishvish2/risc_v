module extend (output logic [31:0] ImmExt,
                input logic [2:0] ImmSrc,
                input logic [31:0] Instr);

logic [31:0] imm0, imm1, imm2, imm3, imm4;

assign imm0 = {{20{Instr[31]}}, Instr[31:20]};
assign imm1 = {{20{Instr[31]}}, Instr[31:25], Instr[11:7]};
assign imm2 = {{19{Instr[31]}}, Instr[31], Instr[7], Instr[30:25], Instr[11:8], 1'b0};
assign imm3 = {Instr[31:12], 12'b0};
assign imm4 = {{12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0};

always_comb begin
    case (ImmSrc)
        3'b000: ImmExt = imm0;  // I-Type
        3'b001: ImmExt = imm1;  // S-Type
        3'b010: ImmExt = imm2;  // B-Type
        3'b011: ImmExt = imm3;  // U-Type
        3'b100: ImmExt = imm4;  // J-Type

    endcase
end
endmodule