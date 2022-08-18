`timescale 1ns / 1ps
module zigzag_decryption #(
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
			input[KEY_WIDTH - 1 : 0] key,
			
			// Output interface
			output reg[D_WIDTH - 1:0] data_o = 0,
			output reg valid_o = 0,
			output reg busy = 0
    );
	 // variabile auxiliare
	 integer i;
	 reg[7:0] restart, line, pos, size, cat, rest, nr_chars = 0;
	 reg[5*8 - 1 : 0] lineStart, linePos;
	 reg[MAX_NOF_CHARS * 8 - 1 : 0] charlist = 0;
	 reg dir;
	 
	 always @(posedge clk) begin // pe frontul crescator al semnalului de ceas
		if(busy) begin // daca semnalul busy este 1
			if(pos < nr_chars) begin // daca nu am gasit inca toate caracterele din textul decriptat
				// setez semnalele data_o si valid_o
				data_o <= charlist[(lineStart[line*8 +: 8] + linePos[line*8 +: 8])*8 +: 8]; 
				valid_o <= 1;
				
				// actualizez pozitia la care am ajuns in textul initial si pozitia in linia curenta
				pos <= pos + 1;
				linePos[line*8 +: 8] <= linePos[line*8 +: 8] + 1;
				
				// pentru a parcurge liniile in zig-zag, folosesc registrul dir pentru a marca directia(sus 1 / jos 0)
				// in care trebuie sa merg pentru a gasi linia urmatoare. Daca am ajuns la linia 0(cea mai de sus),
				// voi trece la linia 1 si voi seta directia in jos. Daca am ajuns la linia key-1, voi trece la linia
				// key-2 si voi seta directia in sus.
				if(line == key - 1) begin
					dir <= 1;
					line <= line - 1;
				end
				else if(line == 0) begin
					dir <= 0;
					line <= line + 1;
				end
				else begin
					if(!dir) begin
						line <= line + 1;
					end
					else begin
						line <= line - 1;
					end
				end
			end
			else begin // decriptarea a fost finalizata, resetez semnalele de output si registrele folosite pentru
			// memorarea textului/numarului de caractere
				busy <= 0;
				valid_o <= 0;
				data_o <= 0;
				charlist <= 0;
				nr_chars <= 0;
			end
			
		end
		
		if(valid_i && !busy) begin // daca semnalul valid_i este 1 si semnalul busy este 0
			if(data_i != START_DECRYPTION_TOKEN) begin // in cazul in care caracterul din data_i nu marcheaza sfarsitul textului
				charlist[nr_chars*8 +:8] <= data_i; // adaug caracterul in registrul folosit pentru memorarea textului pe ultima pozitie
				nr_chars <= nr_chars + 1; // trec la urmatoarea pozitie
			end
			else begin //daca valoarea din data_i este START_DECRYPTION_TOKEN
				//setez semnalul busy pe 1 si resetez registrele folosite pentru parcurgerea in zig-zag
				busy <= 1;
				dir <= 0;
				pos <= 0;
				line <= 0;
				linePos <= 0;
			end
		end
	 end
	 
	 always @(*) begin // la modificarea oricarui semnal
		if(valid_i && !busy) begin // daca semnalul valid_i este 1 si semnalul busy este 0
			if(data_i == START_DECRYPTION_TOKEN) begin //daca valoarea din data_i este START_DECRYPTION_TOKEN
				// Parcurg indicii liniilor mai mici decat cheia de criptare pentru a stabili de unde incepe fiecare linie in registrul
				// care contine textul. Pentru a realiza acest lucru, voi calcula dimensiunea(in caractere) fiecarei linii
				// si o voi folosi pentru a stabili pozitia de inceput a liniei urmatoare. Deoarece linia 0 incepe la pozitia 0,
				// este suficient sa adun dimensiunea si pozitia de inceput ale liniei anterioare pentru a afla pozitia de inceput
				// a liniei curente.
				// Pentru a stabili dimensiunile liniilor, am observat ca atunci cand parcurgem caracterele in zig-zag pe linii se formeaza un ciclu:
				// [L(0), L(1), .. , L(key-1), L(key-2), .. , L(2), L(1)], [L(0), L(1), .. , L(key-1), L(key-2), .. , L(2), L(1)] ....
				// Am determinat faptul ca intr-un astfel de ciclu sunt parcurse 2*(key - 1) caractere si am notat aceasta valoarea cu "restart"
				// De asemenea, am observat ca intr-un ciclu este parcurs cate 1 caracter de pe liniile L(0) si L(key-1), respectiv
				// cate doua caractere de pe liniile din mijloc.
				// Am adaptat codul din modulul division de la Tema1 pentru a imparti numarul total de caractere din text la valoarea "restart"
				// si am aflat astfel dimensiunile liniilor. In cazul in care ultimul ciclu nu contine suficiente caractere pentru a fi finalizat, 
				// am folosit restul aceleiasi impartiri pentru a determina daca trebuie sa cresc dimensiunea liniei cu 0, 1 sau 2
				lineStart = 0;
				restart = 2*(key - 1);
				
				cat = 0;
				rest = 0;
				for(i = 7; i >= 0; i = i - 1) begin
					rest = rest << 1;
					rest[0] = nr_chars[i];
					if(rest >= restart) begin
						rest = rest - restart;
						cat[i] = 1;
					end
				end

				for(i = 0; i < 5; i = i + 1) begin
					if(i < key) begin
						if(i != 0) begin
							lineStart[i*8 +:8] = lineStart[(i-1)*8 +:8] + size;
						end
						size = 0;
						if(i == 0 || i == key - 1) begin
							size = cat;
							if(rest > i) begin
								size = size + 1;
							end
						end
						else begin
							size = 2*cat;
							if(rest > i) begin
								size = size + 1;
							end
							if(rest > restart - i) begin
								size = size + 1;
							end
						end
					end
				end
			end
		end
	 end

endmodule
