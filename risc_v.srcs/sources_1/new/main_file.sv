`timescale 1ns / 1ps
module main_file(output logic [6:0] SEGMENT,
                    output logic [7:0] ANODE,
                    output logic [6:0] LED,
                    input logic [5:0] SWITCH,
                    input clk, reset);

logic [16:0] counter = 0;
logic [31:0] cpu_out;
logic [31:0] cpu_in;
logic [31:0] val;

assign cpu_in = {26'd0, SWITCH};

logic cpu_clk;
logic [15:0] div_counter;

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        div_counter <= 0;
        cpu_clk <= 0;
    end
    else if (div_counter == 1) begin // cpu_clk clock cycle last 2 clock cycles of clk
        div_counter <= 0;
        cpu_clk <= ~cpu_clk;    // clk = 100MHz, hence cpu_clk = 50MHz
    end
    else begin
        div_counter <= div_counter + 1;
    end
end

risc_v cpu (.CLK(cpu_clk),
            .CPUOut(cpu_out),
            .CPUIn(cpu_in), 
            .Reset(reset));

assign val = cpu_out;
assign LED = cpu_out[6:0];

logic [3:0] ones;
logic [3:0] tens;

// Individual digits
assign tens = val / 10;
assign ones = val % 10;            

logic sel;
logic [3:0] digit;

always @(posedge clk) begin
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