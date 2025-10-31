`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.10.2024 17:31:32
// Design Name: 
// Module Name: FA
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FA(
    input a,      // First input
    input b,      // Second input
    input cin,    // Carry input
    output sum,   // Sum output
    output cout   // Carry output
);

    // Internal wires
    wire sum1;
    wire carry1;
    wire carry2;

    // First half adder
    assign sum1 = a ^ b;        // XOR gate
    assign carry1 = a & b;      // AND gate

    // Second half adder
    assign sum = sum1 ^ cin;    // XOR gate
    assign carry2 = sum1 & cin; // AND gate

    // Final carry output
    assign cout = carry1 | carry2; // OR gate
endmodule
