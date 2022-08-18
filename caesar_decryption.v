`timescale 1ns / 1ps
module caesar_decryption#(
				parameter D_WIDTH = 8,
				parameter KEY_WIDTH = 16
			)(
			// Clock and reset interface
			input clk,
			input rst_n,
			
			// Input interface
			input[D_WIDTH - 1:0] data_i,
			input valid_i,
			
			// Decryption Key
			input[KEY_WIDTH - 1 : 0] key,
			
			// Output interface
			output reg[D_WIDTH - 1:0] data_o,
			output busy,
			output reg valid_o
    );

	 always @(posedge clk) begin // pe frontul crescator al semnalului de ceas
		if(valid_i) begin // daca input-ul valid_i este 1
			data_o <= data_i - key; // scad din data_i cheia de decriptare si pun rezultatul din data_o
			valid_o <= 1; // setez pe 1 semnalul valid_o
		end
		else begin // altfel, setez pe 0 semnalul valid_o
		valid_o <= 0;
		end
	 end

endmodule
