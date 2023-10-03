module part3(A, B, Function, ALUout);
    parameter N = 4;
    input [N-1:0] A, B;
    input [1:0] Function; //only two bits since there are 4 different cases
    output reg [(2*N-1):0] ALUout;

    always @ *
        begin
            case(Function) //function takes in 2 bits for each of the 2^2 cases 
                2'b00: ALUout = A+B;
                2'b01: ALUout = |{A, B}; //case 1, 8'b00000001 if any of the 8 bits in A and B contain 1
                2'b10: ALUout = &{A, B}; //case 2, 8'b00000001 if all of the 8 bits in A and B are 1
                2'b11: ALUout = {A, B}; //case 3, display A as MSBs and B as LSBs
                default: ALUout = {8'b0};
            endcase
        end

endmodule




