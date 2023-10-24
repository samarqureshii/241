module part3(clock, reset, ParallelLoadn, RotateRight, ASRight, Data_IN, Q);
  input clock, reset, ParallelLoadn, RotateRight, ASRight;
  input [3:0] Data_IN;
  output [3:0] Q;

  transfer U3 (ASRight ? Q[3] : Q[0], Q[2], RotateRight, Data_IN[3], ParallelLoadn, clock, reset, Q[3]);
  transfer U2 (Q[3], Q[1], RotateRight, Data_IN[2], ParallelLoadn, clock, reset, Q[2]);
  transfer U1 (Q[2], Q[0], RotateRight, Data_IN[1], ParallelLoadn, clock, reset, Q[1]);
  transfer U0 (Q[1], Q[3], RotateRight, Data_IN[0], ParallelLoadn, clock, reset, Q[0]);
endmodule

module transfer(inLeft, inRight, useLeft, D, loadSignal, clock, reset, Q);
  input inLeft, inRight, useLeft, D, loadSignal, clock, reset;
  output reg Q;

  always @(posedge clock) 
  begin
    if (reset)
      Q <= 0;
    else if (loadSignal) 
      Q <= useLeft ? inLeft : inRight;
    else 
      Q <= D;
  end
endmodule
