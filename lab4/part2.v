module part2(Clock, Reset_b, Data, Function, ALUout);
    input Clock, Reset_b;
    input [3:0] Data; //A
    input [1:0] Function;

    reg[7:0] pre_reg;
    output reg[7:0] ALUout; // B is ALUout [3:0], LSB

   always @(*)
   begin
    case(Function)
        2'b00: pre_reg = Data + ALUout[3:0]; //A +  LSB of ALUout (B)
        2'b01: pre_reg = Data * ALUout[3:0]; //A + LSB of ALUout (B)
        2'b10: pre_reg = ALUout[3:0] << Data; //left shifts the 4 LSB by 'A' bits
        2'b11: pre_reg = ALUout;
      default: pre_reg = 0;
    endcase
   end

    always @(posedge Clock)  // listens for rising edge on the clock
    //on every rising edge of the CLK, the value in pre reg is transferred into ALUout 
    //captures and stores the data preset at its input (pre_reg) in this case, on the rising edge of the CLK
    begin
        if (Reset_b) //active high reset
            ALUout <= 0;
        else //if reset is not high, ALUout is just the pre register value 
            //value from previous always block is given to ALUout if we don't reset
            ALUout <= pre_reg;
    end

endmodule
