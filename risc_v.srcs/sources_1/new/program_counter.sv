module program_counter (output logic [31:0] PC,
                        input logic [31:0] PCNext,
                        input logic CLK, Reset, EN);

always_ff @ (posedge CLK)
begin
    if (Reset) begin
        PC <= 32'h00000000;
    end
    else if (!EN) begin
        PC <= PCNext;
    end
    else
        PC <= PC;

end


endmodule