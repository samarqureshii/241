//module mux(LEDR, SW)
	//input x,y,s;
	//output m;

	//mux2to1 U0(
		//.x(SW[0]),
		//.y(SW[1]),
		//.s(SW[9]),
		//.m(LEDR[0])
	//);
//endmodule

module mux2to1(x, y, s, m);
	input x, y, s;
	output m;
	wire c0, c1, c2;
	
	//NOT
	v7404 U0(.pin1(s), .pin2(c0));
	v7408 U1(.pin1(x), .pin2(c0), .pin3(c1), .pin4(s), .pin5(y), .pin6(c2));
	v7432 U2(.pin1(c1), .pin2(c2), .pin3(m));
endmodule

//NOT 
module v7404 (pin1, pin2, pin3, pin4, pin5, pin6, pin8, pin9, pin10, pin11, pin12, pin13);
	input pin1, pin3, pin5, pin9, pin11, pin13;
	output pin2, pin4, pin6, pin8, pin10, pin12;
	
	assign pin2 = ~pin1;
	assign pin4 = ~pin3;
	assign pin6 = ~pin5;
	assign pin8 = ~pin9;
	assign pin10 = ~pin11;
	assign pin12 = ~pin13;
endmodule

//AND 
module v7408 (pin1, pin2, pin3, pin4, pin5, pin6, pin8, pin9, pin10, pin11, pin12, pin13);
	input pin1, pin2, pin4, pin5, pin9, pin10, pin12, pin13;
	output pin3, pin6, pin8, pin11;
	
	assign pin3 = pin1 & pin2;
	assign pin6 = pin4 & pin5;
	assign pin8 = pin9 & pin10;
	assign pin11 = pin12 & pin13;
endmodule

//OR
module v7432 (pin1, pin2, pin3, pin4, pin5, pin6, pin8, pin9, pin10, pin11, pin12, pin13);
	input pin1, pin2, pin4, pin5, pin9, pin10, pin12, pin13;
	output pin3, pin6, pin8, pin11;
	
	assign pin3 = pin1 | pin2;
	assign pin6 = pin4 | pin5;
	assign pin8 = pin9 | pin10;
	assign pin11 = pin12 | pin13;
endmodule


