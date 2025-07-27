`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.10.2024 20:17:37
// Design Name: 
// Module Name: MUX2to1_tb
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

module tb_mux2to1;
reg [1:0] I; // Inputs 
reg S;
wire Y; // Outputs
// Instantiate the Unit Under Test (UUT) 
mux2_to_1 uut (.I(I), .S(S), .Y(Y));
initial
begin
// Initialize Inputs
I[0] = 0; I[1] = 0; S = 0;
// Add stimulus here
#10 I[0] = 0; I[1] = 1; S = 0;
#10 I[0] = 1; I[1] = 1; S = 0;
#10 I[0] = 0; I[1] = 0; S = 1;
#10 I[0] = 0; I[1] = 1; S = 1;
#10 $finish; end
endmodule
