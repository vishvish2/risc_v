module decoder(output logic [6:0] sevenSegment,
                input logic [3:0] number);

always_comb begin
    case (number)
        // 0
        4'b0000: sevenSegment = 7'b0000001;
        
        // 1
        4'b0001: sevenSegment = 7'b1001111;
        
        // 2
        4'b0010: sevenSegment = 7'b0010010;
        
        // 3
        4'b0011: sevenSegment = 7'b0000110;
        
        // 4
        4'b0100: sevenSegment = 7'b1001100;
        
        // 5
        4'b0101: sevenSegment = 7'b0100100;
        
        // 6
        4'b0110: sevenSegment = 7'b0100000;
       
        // 7
        4'b0111: sevenSegment = 7'b0001111;
        
        // 8
        4'b1000: sevenSegment = 7'b0000000;
        
        // 9
        4'b1001: sevenSegment = 7'b0000100;
        
        default: sevenSegment = 7'b0110000;
        
    
    endcase
    
end
             
endmodule