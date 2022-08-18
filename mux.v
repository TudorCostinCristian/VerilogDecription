`timescale 1ns / 1ps
module mux #(
		parameter D_WIDTH = 8
	)(
		// Clock and reset interface
		input clk,
		input rst_n,
		
		//Select interface
		input[1:0] select,
		
		// Output interface
		output reg[D_WIDTH - 1 : 0] data_o,
		output reg						 valid_o,
				
		//output interfaces
		input [D_WIDTH - 1 : 0] 	data0_i,
		input   							valid0_i,
		
		input [D_WIDTH - 1 : 0] 	data1_i,
		input   							valid1_i,
		
		input [D_WIDTH - 1 : 0] 	data2_i,
		input     						valid2_i
    );
	
	 always @(posedge clk) begin // pe frontul crescator al semnalului clk
		valid_o <= 0; // setez valid_o pe 0
		case(select) // in functie de valoarea lui select, pun pe output semnalele corespunzatoare
			0: if(valid0_i) begin // caesar
					data_o <= data0_i;
					valid_o <= 1;
				end
			1: if(valid1_i) begin // scytale
					data_o <= data1_i;
					valid_o <= 1;
				end
			2: if(valid2_i) begin // zigzag
					data_o <= data2_i;
					valid_o <= 1;
				end
		endcase
	 end
endmodule
