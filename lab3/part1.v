// module testing(LEDR, SW) //testing
//     input a, b, c_in;
//     output s, c_out;
//     4RCA U0 (.a(SW[7:4]),
//             .b(SW[3:0]),
//             .c_in(SW[8]),
//             .s(LEDR[3:0]),
//             .c_out(LEDR[9:6]));
// endmodule

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