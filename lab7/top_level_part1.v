//top level

module top_level_part1(KEY, SW, HEX0);
	input [9:0] SW;
	input KEY;
	output [3:0] HEX0;
	
	part1 p1(.address(SW[8:4]), .clock(KEY), .data(SW[3:0]), .wren(SW[9]), .q(HEX0));
endmodule

