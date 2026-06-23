module control_unit (output logic MemWrite, ALUSrc, RegWrite,
                        output logic [4:0] ALUControl, 
                        output logic [2:0] ImmSrc,
                        output logic [1:0] PCSrc, ResultSrc, jump,
                        output logic [2:0] branch,
                        input logic [31:0] Instr,
                        input logic Zero, Negative);

logic [6:0] opcode;
logic [2:0] funct3;
logic [6:0] funct7;

assign opcode = Instr[6:0];
assign funct3 = Instr[14:12];
assign funct7 = Instr[31:25];

assign MemWrite = (opcode == 7'b0100011 && funct3 == 3'h2) ? 1 : 0; // only sw needs MemWrite = 1
assign RegWrite = (opcode[5:0] == 6'b100011) ? 0 : 1;               // only sw, beq, bne, blt and bge need RegWrite = 0

always_comb begin

    case (opcode)
        7'b0110011: begin
            ImmSrc = 3'bxxx;
            ALUSrc = 1'b0;
            ResultSrc = 2'b00;
            PCSrc = 2'b00;
            jump = 2'b00;
            branch = 3'b000;
            case (funct3)
                3'h0: ALUControl = (funct7 == 7'h00) ? 5'bx0x10 : 5'bx1x10; // add/sub
                3'h6: ALUControl = 5'bxx111;                                // or
                3'h7: ALUControl = 5'bxx011;                                // and
                3'h1: ALUControl = 5'b0xx00;                                // sll
                3'h5: ALUControl = 5'b1xx00;                                // srl
                3'h2: ALUControl = 5'bx1x01;                                // slt
                default: ALUControl = 5'bxxxxx;
            endcase
        end

        7'b0010011: begin
            ImmSrc = 3'b000;
            ALUSrc = 1'b1;
            ResultSrc = 2'b00;
            PCSrc = 2'b00;
            jump = 2'b00;
            branch = 3'b000;
            case (funct3)
                3'h0: ALUControl = 5'bx0x10;            // addi
                3'h6: ALUControl = 5'bxx111;            // ori
                3'h7: ALUControl = 5'bxx011;            // andi
                3'h1: ALUControl = 5'b0xx00;            // slli
                3'h5: ALUControl = 5'b1xx00;            // srli
                3'h2: ALUControl = 5'bx1x01;            // slti
                default: ALUControl = 5'bxxxxx;
            endcase
        end

        7'b0000011: begin       // lw
            ImmSrc = 3'b000;
            ALUSrc = 1'b1;
            ALUControl = 5'bx0x10;
            ResultSrc = 2'b01;
            PCSrc = 2'b00;
            jump = 2'b00;
            branch = 3'b000;
        end

        7'b0100011: begin       // sw
            ImmSrc = 3'b001;
            ALUSrc = 1'b1;
            ALUControl = 5'bx0x10;
            ResultSrc = 2'bxx;
            PCSrc = 2'b00;
            jump = 2'b00;
            branch = 3'b000;
        end

        7'b1100011: begin
            ImmSrc = 3'b010;
            ALUSrc = 1'b0;
            ALUControl = 5'bx1x10;
            ResultSrc = 2'bxx;
            jump = 2'b00;
            case (funct3)
                3'h0: begin
                    PCSrc = {1'b0, Zero};             // beq
                    branch = 3'b001;
                end
                
                3'h1: begin
                    PCSrc = {1'b0, ~Zero};            // bne
                    branch = 3'b010;
                end
                
                3'h4: begin
                    PCSrc = {1'b0, Negative};         // blt
                    branch = 3'b011;
                end
                
                3'h5: begin
                    PCSrc = {1'b0, ~Negative};        // bge
                    branch = 3'b100;
                end
                
                default: begin
                    PCSrc = 2'bxx;
                    branch = 3'bxxx;
                end
            endcase
        end

        7'b1101111: begin       // jal
            ImmSrc = 3'b100;
            ALUSrc = 1'bx;
            ALUControl = 5'bxxxxx;
            ResultSrc = 2'b10;
            PCSrc = 2'b01;
            jump = 2'b01;
            branch = 3'b000;
        end

        7'b1100111: begin       // jalr
            ImmSrc = 3'b000;
            ALUSrc = 1'b1;
            ALUControl = 5'bx0x10;
            ResultSrc = 2'b10;
            PCSrc = 2'b10;
            jump = 2'b10;
            branch = 3'b000;
        end

        7'b0110111: begin       // lui
            ImmSrc = 3'b011;
            ALUSrc = 1'bx;
            ALUControl = 5'bxxxxx;
            ResultSrc = 2'b11;
            PCSrc = 2'b00;
            jump = 2'b00;
            branch = 3'b000;
        end

        default: begin
            ImmSrc = 3'bxxx;
            ALUSrc = 1'bx;
            ALUControl = 5'bxxxxx;
            ResultSrc = 2'bxx;
            PCSrc = 2'bxx;
            jump = 2'bxx;
            branch = 3'bxxx;
        end
    endcase
end

endmodule