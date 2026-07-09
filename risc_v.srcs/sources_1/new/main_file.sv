`timescale 1ns / 1ps
module main_file(output logic [6:0] SEGMENT,
                    output logic [7:0] ANODE,
                    output logic [11:0] LED,
                    input logic [7:0] SWITCH,
                    input clk, reset);

logic [16:0] counter = 0;
logic [31:0] cpu_out;
logic [31:0] cpu_in;
logic [31:0] val;

logic clk_out, locked;

clk_wiz_0 clk_gen (
    .clk_in1(clk),      // 100MHz board clock
    .clk_out1(clk_out), // 80MHz generated clock
    .reset(reset),
    .locked(locked)
);

assign cpu_in = {24'd0, SWITCH};

risc_v cpu (.CLK(clk_out),
            .CPUOut(cpu_out),
            .CPUIn(cpu_in), 
            .Reset(reset));

assign val = cpu_out;
assign LED = cpu_out[11:0];

logic [3:0] ones;
logic [3:0] tens;

// Individual digits for seven segment display
assign tens = val / 10;
assign ones = val % 10;            

logic sel;
logic [3:0] digit;

always @(posedge clk_out) begin
    if (counter == 99999) begin
        counter <= 0;
        sel <= ~sel;      // pulse for one clock cycle
    end
        else begin
            counter <= counter + 1;
        end
    
end

always_comb begin
    case (sel)
        1'b0: begin
            digit = ones;
            ANODE = 8'b11111110; // right digit
        end

        1'b1: begin
            digit = tens;
            ANODE = 8'b11111101; // left digit
        end

        default: begin
            digit = 4'd0;
            ANODE = 8'b11111111;
        end
    endcase
end

// Translate digit to sevent segment display
decoder test (.number(digit), .sevenSegment(SEGMENT));
              
endmodule