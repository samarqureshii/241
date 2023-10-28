module part3 #(parameter CLOCK_FREQUENCY=50000000)(
    input wire ClockIn,
    input wire Reset,
    input wire Start,
    input wire [2:0] Letter,
    output wire DotDashOut,
    output wire NewBitOut);

    reg [12:0] morse;

    always@(*)begin
        case(Letter)
            3'b000: morse = 12'b101110000000;
            3'b001: morse = 12'b111010101000;
            3'b010: morse = 12'b111010111010;
            3'b011: morse = 12'b111010100000;
            3'b100: morse = 12'b100000000000;
            3'b101: morse = 12'b101011101000;
            3'b110: morse = 12'b111011101000;
            3'b111: morse = 12'b101010100000;
        endcase
    end
    
    rate_divider #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY)) div2(
        .ClockIn(ClockIn), 
        .Reset(Reset), 
        .Start(Start)
    );
    
    assign NewBitOut = div2.Enable;  

    shift_register sr(
        .ClockIn(ClockIn),
        .Reset(Reset),
        .Enable(div2.Enable), 
        .LoadVal(morse[11:0]),  
        .DotDashOut(DotDashOut) 
    );

endmodule




//registers hlld 0.5s of on/off

module rate_divider #(parameter CLOCK_FREQUENCY = 50000000)(input ClockIn, input Reset, input Start, output reg Enable);

    reg [$clog2(CLOCK_FREQUENCY):0] counter;

    always @(posedge ClockIn, negedge ClockIn)
        begin
        if(Reset || Start)
        begin
            Enable <=1'b0;
            counter = (CLOCK_FREQUENCY);
        end

        else 
        begin
            Enable <= 1'b0;
            if(!counter)
            begin
                Enable<=1;
                counter = (CLOCK_FREQUENCY);
            end
        end 
        counter <= counter-1;
        end

endmodule

module shift_register
(
    input ClockIn,
    input Reset,
    input Enable,
    input [11:0] LoadVal,  //morse pattern input
    output reg DotDashOut  
);

    //storage
    reg [11:0] shift_reg;

    always @(posedge ClockIn or posedge Reset) begin
        if (Reset) begin
            shift_reg <= 12'b0;
        end else if (Enable) begin
            shift_reg <= {shift_reg[10:0], DotDashOut};  // right shift
        end
    end

    always @(*) begin
        DotDashOut = shift_reg[0];  // assign LSB
    end

endmodule

