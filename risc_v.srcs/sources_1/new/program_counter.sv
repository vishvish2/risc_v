module program_counter (output logic [31:0] PC,
                        input logic [31:0] PCNext,
                        input logic CLK, Reset);

always_ff @ (posedge CLK)
begin
    if (Reset) begin
        PC <= 32'h00000000;
    end
    else begin
        PC <= PCNext;
    end

end


endmodule