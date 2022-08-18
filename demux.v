`timescale 1ns / 1ps
module demux #(
		parameter MST_DWIDTH = 32,
		parameter SYS_DWIDTH = 8
	)(
		// Clock and reset interface
		input clk_sys,
		input clk_mst,
		input rst_n,
		
		//Select interface
		input[1 : 0] select,
		
		// Input interface
		input [MST_DWIDTH -1  : 0]	 data_i,
		input 						 	 valid_i,
		
		//output interfaces
		output reg [SYS_DWIDTH - 1 : 0] 	data0_o,
		output reg     						valid0_o,
		
		output reg [SYS_DWIDTH - 1 : 0] 	data1_o,
		output reg     						valid1_o,
		
		output reg [SYS_DWIDTH - 1 : 0] 	data2_o,
		output reg     						valid2_o
    );
	 // variabile auxiliare
	 reg[31:0] data_i_reg = 0;
	 reg[7:0] cnt_sys = 1, start_clk_sys = 0, cnt_start = 0, cnt_stop = 3;
	 
	 always @(posedge clk_mst) begin // pe frontul crescator al semnalului clk_mst
			start_clk_sys <= 1; // marchez start_clk_sys cu 1 pentru a incepe sa contorizez clk_sys
			data_i_reg <= data_i; // copiez data_i in registrul corespunzator
	 end
	 
	 always@(posedge clk_sys) begin // pe frontul crescator al semnalului clk_sys
		if(start_clk_sys) begin // verific daca am trecut de primul front crescator al semnalului clk_mst
			if(cnt_start < 3 && valid_i) begin // daca valid_i = 1 si contorul pentru inceputul copierii datelor in semnalele de output nu a ajuns la 3
				cnt_start <= cnt_start + 1; // cresc contorul pentru inceputul copierii datelor
				cnt_stop <= 3; // setez contorul pentru oprirea copierii datelor pe 3
			end
			
			if(!valid_i && cnt_start != 0) begin // daca valid_i este 0 si cnt_start nu este 0
				cnt_stop <= cnt_stop - 1; // scad contorul pentru oprirea copierii datelor
			end
			
			if(!cnt_stop) begin // daca am ajuns la finalul copierii datelor, setez semnalele de output pe 0 si resetez contorul de start
				cnt_start <= 0;
				valid0_o <= 0;
				valid1_o <= 0;
				valid2_o <= 0;
				data0_o <= 0;
				data1_o <= 0;
				data2_o <= 0;
			end
			else if(cnt_start == 3 && cnt_sys == 0) begin // daca datele din data_i sunt valide(adica ma aflu in dreptul posedge clk_mst) si contorul pentru inceputul
			// copierii datelor este 3, atunci folosesc select pentru a pune pe output valoarea din data_i
				case(select)
					0: begin // caesar
						data0_o <= data_i[(3-cnt_sys)*8 +:8];
						valid0_o <= 1;
					end
					1: begin // scytale
						data1_o <=  data_i[(3-cnt_sys)*8 +:8];
						valid1_o <=  1;
					end
					2: begin // zigzag
						data2_o <=  data_i[(3-cnt_sys)*8 +:8];
						valid2_o <=  1;
					end
				endcase
			end
			else if(cnt_start == 3 && cnt_sys > 0) begin // daca datele din data_i nu sunt valide, voi folosi datele salvate in registru pentru
			// a le copia in semnalele de output
				case(select)
					0: begin // caesar
						data0_o <= data_i_reg[(3-cnt_sys)*8 +:8];
						valid0_o <=  1;
					end
					1: begin // scytale
						data1_o <=  data_i_reg[(3-cnt_sys)*8 +:8];
						valid1_o <=  1;
					end
					2: begin // zigzag
						data2_o <=  data_i_reg[(3-cnt_sys)*8 +:8];
						valid2_o <=  1;
					end
				endcase
			end
			
			if(cnt_sys < 3) cnt_sys <= cnt_sys + 1; // cresc contorul pentru posedge clk_sys
			else cnt_sys <= 0; // de fiecare data cand contorul pentru posedge clk_sys depaseste valoarea 3, il resetez la 0
		end
		else begin // daca nu am intrat inca pe primul posedge clk_mst, setez valorile semnalelor de output pe 0
			valid0_o <= 0;
			valid1_o <= 0;
			valid2_o <= 0;
			data0_o <= 0;
			data1_o <= 0;
			data2_o <= 0;
		end
	 end

endmodule
