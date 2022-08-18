`timescale 1ns / 1ps
module decryption_regfile #(
			parameter addr_witdth = 8,
			parameter reg_width 	 = 16
		)(
			// Clock and reset interface
			input clk, 
			input rst_n,
			
			// Register access interface
			input[addr_witdth - 1:0] addr,
			input read,
			input write,
			input [reg_width -1 : 0] wdata,
			output reg [reg_width -1 : 0] rdata,
			output reg done,
			output reg error,
			
			// Output wires
			output reg[reg_width - 1 : 0] select,
			output reg[reg_width - 1 : 0] caesar_key,
			output reg[reg_width - 1 : 0] scytale_key,
			output reg[reg_width - 1 : 0] zigzag_key
    );
	 
	 always @(posedge clk) begin // blocul always se executa pe frontul crescator al semnalului de ceas
		if(!rst_n) begin // daca semnalul de reset este 0, se reseteaza valorile output-urilor
			select = 0;
			caesar_key = 0;
			scytale_key = 65535;
			zigzag_key = 2;
			error = 0;
			done = 0;
			rdata = 0;
		end
		else begin
			if(done) done = 0; //in cazul in care valoarea semnalul done este 1, inseamna ca acesta
			// a fost ridicat in urma cu un ciclu de ceas, asa ca il vom trece pe 0.
			if(error) error = 0; // la fel ca in cazul semnalului done
			if(write) begin // daca semnalul write este 1
				case(addr) // verificam adresa: in cazul in care adresa nu corespunde unui registru, se ridica semnalul error
				// daca adresa corespunde unui registru, se pune valoarea din wdata in registrul respectiv
					8'h00: select = wdata[1:0];
					8'h10: caesar_key = wdata;
					8'h12: scytale_key = wdata;
					8'h14: zigzag_key = wdata;
					default: error = 1;
				endcase
				done = 1; // se seteaza semnalul done pe 1(va fi trecut inapoi pe 0 dupa un ciclu de ceas)
			end
		
			if(read) begin // daca semnalul read este 1
				case(addr) // verificam adresa: in cazul in care adresa nu corespunde unui registru, se ridica semnalul error
				// daca adresa corespunde unui registru, se trece valoarea din registrul respectiv in rdata
					8'h00: rdata = select[1:0];
					8'h10: rdata = caesar_key;
					8'h12: rdata = scytale_key;
					8'h14: rdata = zigzag_key;
					default: error = 1;
				endcase
				done = 1; // se seteaza semnalul done pe 1(va fi trecut inapoi pe 0 dupa un ciclu de ceas)
			end
		end
	 end
	
endmodule
