`timescale 1ns / 1ps
module scytale_decryption#(
			parameter D_WIDTH = 8, 
			parameter KEY_WIDTH = 8, 
			parameter MAX_NOF_CHARS = 50,
			parameter START_DECRYPTION_TOKEN = 8'hFA
		)(
			// Clock and reset interface
			input clk,
			input rst_n,
			
			// Input interface
			input[D_WIDTH - 1:0] data_i,
			input valid_i,
			
			// Decryption Key
			input[KEY_WIDTH - 1 : 0] key_N,
			input[KEY_WIDTH - 1 : 0] key_M,
			
			// Output interface
			output reg[D_WIDTH - 1:0] data_o = 0,
			output reg valid_o = 0,
			
			output reg busy = 0
    );
	 // variabile auxiliare
	 reg[MAX_NOF_CHARS * 8 - 1 : 0] charlist = 0;
	 reg[6:0] nr_chars = 0;
	 reg[7:0] startL, startC;

	
	 always @(posedge clk) begin // pe frontul crescator al semnalului de ceas
		if(busy && startL == key_N) begin // daca semnalul busy este 1 si daca am depasit ultima linie, inseamna ca decriptarea a fost finalizata
				// resetez semnalele de output si registrele folosite pentru memorarea textului/numarului de caractere
				busy <= 0;
				valid_o <= 0;
				data_o <= 0;
				charlist <= 0;
				nr_chars <= 0;
		end
		else if(busy) begin // daca nu am parcurs inca toate liniile, setez semnalele data_o si valid_o
				data_o <= charlist[(key_N*startC + startL)*8 +:8];
				valid_o <= 1;
				if(startC + 1 == key_M) begin // daca am depasit ultima coloana, trec la coloana 0 din urmatoarea linie
					startC <= 0;
					startL <= startL + 1;
				end
				else begin // altfel, trec la urmatoarea coloana
					startC <= startC + 1;
				end
		end
		if(valid_i && !busy) begin // daca semnalul valid_i este 1 si semnalul busy este 0
			if(data_i != START_DECRYPTION_TOKEN) begin // in cazul in care caracterul din data_i nu marcheaza sfarsitul textului
				charlist[nr_chars*8 +:8] <= data_i; // adaug caracterul in registrul folosit pentru memorarea textului pe ultima pozitie
				nr_chars <= nr_chars + 1; // trec la urmatoarea pozitie
			end
			else begin //daca valoarea din data_i este START_DECRYPTION_TOKEN, setez semnalul busy pe 1 si resetez registrele folosite pt parcurgere
				busy <= 1;
				startL <= 0;
				startC <= 0;
				nr_chars <= 0;
			end
		end
	 end



endmodule
