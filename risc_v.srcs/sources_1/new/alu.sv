module alu (output logic [31:0] ALUResult,
            output logic Zero, Negative,
            input logic [31:0] A, B,
            input logic [4:0] ALUControl);

logic [31:0] y_add, y_sub, y_or, y_and, y_sll, y_srl, y_slt;

assign y_add = A + B;
assign y_sub = A - B;
assign y_or = A | B;
assign y_and = A & B;
assign y_sll = A << B;
assign y_srl = A >> B;
assign y_slt = {31'b0, y_sub[31]};      // zero extend if A - B is negative

always_comb begin
    casez (ALUControl)
        5'b?0?10: ALUResult = y_add;    // add
        5'b?1?10: ALUResult = y_sub;    // subtract
        5'b??111: ALUResult = y_or;     // bitwise OR
        5'b??011: ALUResult = y_and;    // bitwise AND
        5'b0??00: ALUResult = y_sll;    // shift left logical
        5'b1??00: ALUResult = y_srl;    // shift right logical
        5'b?1?01: ALUResult = y_slt;    // set less than

        default: ALUResult = 32'bx;
        
    endcase
end

assign Negative = ALUResult[31];        // Asserted if output is negative
assign Zero = ~|ALUResult;              // Asserted if output is zero

endmodule