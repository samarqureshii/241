module part1(input Clock, input Enable, input Reset, output [7:0] CounterValue);

    wire [7:0] T;
    assign T[0] = Enable & CounterValue[0];
    assign T[1] = T[0] & CounterValue[1];
    assign T[2] = T[1] & CounterValue[2];
    assign T[3] = T[2] & CounterValue[3];
    assign T[4] = T[3] & CounterValue[4];
    assign T[5] = T[4] & CounterValue[5];
    assign T[6] = T[5] & CounterValue[6];
    



    tflip u0(.Enable(Enable), .Clock(Clock), .Reset(Reset), .Q(CounterValue[0]));
    tflip u1(.Enable(T[0]), .Clock(Clock), .Reset(Reset), .Q(CounterValue[1]));
    tflip u2(.Enable(T[1]), .Clock(Clock), .Reset(Reset), .Q(CounterValue[2]));
    tflip u3(.Enable(T[2]), .Clock(Clock), .Reset(Reset), .Q(CounterValue[3]));
    tflip u4(.Enable(T[3]), .Clock(Clock), .Reset(Reset), .Q(CounterValue[4]));
    tflip u5(.Enable(T[4]), .Clock(Clock), .Reset(Reset), .Q(CounterValue[5]));
    tflip u6(.Enable(T[5]), .Clock(Clock), .Reset(Reset), .Q(CounterValue[6]));
    tflip u7(.Enable(T[6]), .Clock(Clock), .Reset(Reset), .Q(CounterValue[7]));
endmodule 

module tflip(Clock, Reset, Enable, Q);
    input Clock, Reset, Enable;
    output reg Q;

    always @ (posedge Clock)
    begin
        if (Reset)
            Q <= 0;
        else if (Enable)
            Q <= ~Q;
        else
            Q <= Q;
    end
endmodule