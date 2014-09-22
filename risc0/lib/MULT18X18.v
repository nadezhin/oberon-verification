`timescale 1ns / 1ps  // NW 29.4.2011
module MULT18X18(
  input [17:0] A, B,
  output [35:0] P);
	 
assign P = {{18'b0}, A} * {{18'b0}, B};
endmodule
