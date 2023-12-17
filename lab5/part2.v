module toplevel (input CLOCK_50, input [9:0] SW, output [6:0] HEX0);
  wire [3:0] counterValue;

  part2 #(50000000) p2 (CLOCK_50, SW[9], SW[1:0], counterValue[3:0]);
  hex_decoder hd (counterValue[3:0], HEX0[6:0]);
endmodule


module part2 
    #(parameter CLOCK_FREQUENCY = 50000000)(
    input ClockIn,
    input Reset,
    input [1:0] Speed,
    output [3:0] CounterValue);
    wire EN;

    RateDivider #(CLOCK_FREQUENCY) U0(.ClockIn(ClockIn), .Reset(Reset), .Speed(Speed), .Enable(EN));
    DisplayCounter U1(ClockIn, Reset, EN, CounterValue);

endmodule

module RateDivider #(parameter FREQUENCY = 50000000) (
    input ClockIn, 
    input Reset, //when Reset is high, enable is set to low, and DownCount is reset to 0 
    input [1:0] Speed, //determines the frequency division ratio 
    //controls how the Enable signal goes high relative to the input clock frequency
    output reg Enable); 

    //given input clock signal, it produces output signal Enable at a fraction of the input clock rate, this fraction is determined by the Speed

    reg [30:0] downCount; //27 bit register that is a countdown timer
    //gets decremented on every posedge of the clock (unless its being loaded or reset )

    always @(posedge ClockIn) begin
        if(Reset || downCount == 27'd0) //if reset is high and enable is set to 0 or downcount is 0 
        begin
            Enable <= 1'b1;
            case(Speed) //select frequency based on the inputted speed 
                2'b00: downCount <= 0; //loads 0, Enable will always be high 
                2'b01: downCount <= FREQUENCY - 1; //every 1s
                2'b10: downCount <= (FREQUENCY << 1) - 1; // double the base frequency (every 2s)
                2'b11: downCount <= (FREQUENCY << 2) - 1; // quadruple the base frequency (every 4s)
                default: downCount <= 0;
            endcase
        end 

        else //keep decrementing and Enable set to 0 
        begin
            downCount <= downCount - 1'b1;
            Enable <= 0;
        end
    end

endmodule

module DisplayCounter ( //up counter from 0000 to 1111
    input Clock,
    input Reset,
    input EnableDC,
    output reg [3:0] CounterValue);

    always @(posedge Clock) begin
        if (Reset)
            CounterValue <= 4'b0000;
        else if (EnableDC)
            CounterValue <= CounterValue + 4'b0001;
    end

endmodule


module hex_decoder(c, display);
    input [3:0] c;
    output [6:0] display;
    
    assign c0 = c[0];
    assign c1 = c[1];
    assign c2 = c[2];
    assign c3 = c[3];

    assign display[0] = (~c3 & ~c2 & ~c1 & c0) + (~c3 & c2 & ~c1 & ~c0) + (c3 & ~c2 & c1 & c0) + (c3 & c2 & ~c1 & c0);
    assign display[1] = (~c3 & c2 & ~c1 & c0) + (~c3 & c2 & c1 & ~c0) + (c3 & ~c2 & c1 & c0) + (c3 & c2 & ~c1 & ~c0) + (c3 & c2 & c1 & ~c0) + (c3 & c2 & c1 & c0);
    assign display[2] = (~c3 & ~c2 & c1 & ~c0) + (c3 & c2 & ~c1 & ~c0) + (c3 & c2 & c1 & ~c0) + (c3 & c2 & c1 & c0);	
    assign display[3] = (~c3 & ~c2 & ~c1 & c0) + (~c3 & c2 & ~c1 & ~c0) + (~c3 & c2 & c1 & c0) + (c3 & ~c2 & ~c1 & c0) + (c3 & ~c2 & c1 & ~c0) + (c3 & c2 & c1 & c0);
    assign display[4] = (~c3 & ~c2 & ~c1 & c0) + (~c3 & ~c2 & c1 & c0) + (~c3 & c2 & ~c1 & ~c0) + (~c3 & c2 & ~c1 & c0) + (~c3 & c2 & c1 & c0) + (c3 & ~c2 & ~c1 & c0);
    assign display[5] = (~c3 & ~c2 & ~c1 & c0) + (~c3 & ~c2 & c1 & ~c0) + (~c3 & ~c2 & c1 & c0) + (~c3 & c2 & c1 & c0) + (c3 & c2 & ~c1 & c0);
    assign display[6] = (~c3 & ~c2 & ~c1 & ~c0) + (~c3 & ~c2 & ~c1 & c0) + (~c3 & c2 & c1 & c0) + (c3 & c2 & ~c1 & ~c0);
endmodule