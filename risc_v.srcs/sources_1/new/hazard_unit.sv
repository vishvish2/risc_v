module hazard_unit(output logic StallF, StallD, FlushD, FlushE,
                    output logic [1:0] ForwardAE, ForwardBE,
                    input logic [4:0] Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW,
                    input logic [1:0] ResultSrcE, PCSrcE,
                    input logic RegWriteM, RegWriteW);

logic lwStall;
                                        
always_comb begin
    // Data hazards
    // Forward A
    if (((Rs1E == RdM) && RegWriteM) && (Rs1E != 5'b0))
        ForwardAE = 2'b10;
    else if (((Rs1E == RdW) && RegWriteW) && (Rs1E != 5'b0))
        ForwardAE = 2'b01;
    else
        ForwardAE = 2'b00;

    // Forward B
    if (((Rs2E == RdM) && RegWriteM) && (Rs2E != 5'b0))
        ForwardBE = 2'b10;
    else if (((Rs2E == RdW) && RegWriteW) && (Rs2E != 5'b0))
        ForwardBE = 2'b01;
    else
        ForwardBE = 2'b00;
        
     // Load word (lw) stall
    lwStall = ((Rs1D == RdE) || (Rs2D == RdE)) && (ResultSrcE == 2'b01);
    StallF = lwStall;
    StallD = lwStall;
    
    // Control hazard register flush
    FlushD = (PCSrcE != 2'b00);
    FlushE = lwStall || (PCSrcE != 2'b00);

end

endmodule                  