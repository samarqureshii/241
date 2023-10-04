module ALU_TOP( //top module    
    input [7:0] SW,  // Switches on FPGA
    input [1:0] KEY, // Buttons on FPGA
    output [7:0] LEDR, // LEDs on FPGA
    output [6:0] HEX0, HEX2, HEX3, HEX4 // 7-segment displays on FPGA
);


    // ALU instantiation
    part2 U_ALU (
        .A(SW[7:4]),
        .B(SW[3:0]),
        .Function(KEY),
        .ALUout(LEDR)
    );

    //A for HEX2
    hex_decoder U_HEX_A(
        .c(SW[7:4]),
        .display(HEX2)
    );


    //B for HEX0
    hex_decoder U_HEX_B(
        .c(SW[3:0]),
        .display(HEX0)
    );


    // displaying ALU out
    hex_decoder U_HEX_ALU_HIGH(
        .c(LEDR[7:4]),
        .display(HEX4)
    );
    hex_decoder U_HEX_ALU_LOW(
        .c(LEDR[3:0]),
        .display(HEX3)
    );

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

module part2(A, B, Function, ALUout);
    input [3:0] A, B;
    input [1:0] Function; //only two bits since there are 4 different cases
    output reg [7:0] ALUout;
    wire [3:0] s; //4 bit sum
    wire [3:0] c3; //c_out, one bit for each stage of the 4 bit RCA

    //create RCA for case 0
    part1 U5(.a(A),
            .b(B),
            .c_in(1'b0),
            .s(s),
            .c_out(c3)

            ); //c3 is the c_out, s is the sum

    always @ *
        begin
            case(Function) //function takes in 2 bits for each of the 2^2 cases
                2'b00: ALUout = {3'b0, c3[3], s}; // case 0, sum of A + B, concatenated with 000, c_out, and 4 bit sum = 8 bit ALUout
                2'b01: ALUout = |{A, B}; //case 1, 8'b00000001 if any of the 8 bits in A and B contain 1
                2'b10: ALUout = &{A, B}; //case 2, 8'b00000001 if all of the 8 bits in A and B are 1
                2'b11: ALUout = {A, B}; //case 3, display A as MSBs and B as LSBs
                default: ALUout = {8'b0};
            endcase
        end

endmodule


module part1(a, b, c_in, s, c_out); //4 bit ripple carry adder
    input [3:0] a, b;
    input c_in;
    output [3:0] s;
    output [3:0] c_out;
    wire c0, c1, c2; //intermediaries

    FA U1(a[0], b[0], c_in, s[0], c0);
    FA U2(a[1], b[1], c0, s[1], c1);
    FA U3(a[2], b[2], c1, s[2], c2);
    FA U4(a[3], b[3], c2, s[3], c_out[3]);

    assign c_out[0] = c0;
    assign c_out[1] = c1;
    assign c_out[2] = c2;
endmodule

module FA (a, b, c_in, s, c_out); //full adder
    input a, b, c_in;
    output s, c_out;

    assign c_out = (a & b) | (b & c_in) | (a & c_in);
    assign s = a ^ b ^ c_in;
endmodule