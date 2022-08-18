`timescale 1ns / 1ps
module decryption_top#(
			parameter addr_witdth = 8,
			parameter reg_width 	 = 16,
			parameter MST_DWIDTH = 32,
			parameter SYS_DWIDTH = 8
		)(
		// Clock and reset interface
		input clk_sys,
		input clk_mst,
		input rst_n,
		
		// Input interface
		input [MST_DWIDTH - 1 : 0] data_i,
		input 						  valid_i,
		output busy,
		
		//output interface
		output [SYS_DWIDTH - 1 : 0] data_o,
		output      					 valid_o,
		
		// Register access interface
		input[addr_witdth - 1:0] addr,
		input read,
		input write,
		input [reg_width - 1 : 0] wdata,
		output[reg_width - 1 : 0] rdata,
		output done,
		output error
		
    );
	wire [15:0] select, caesar_key, scytale_key, zigzag_key;
	wire [7:0] caesar_data_i, scytale_data_i, zigzag_data_i, caesar_data_o, scytale_data_o, zigzag_data_o;
	wire caesar_valid_i, scytale_valid_i, zigzag_valid_i, caesar_valid_o, scytale_valid_o, zigzag_valid_o, caesar_busy, scytale_busy, zigzag_busy;
	
	// in modului decryption top, am declarat variabilele wire necesare pentru a face conexiunile si m-am folosit apoi de toate modulele
	// implementate pentru a obtine semnalele de output. Pentru a determina valoarea lui busy, am folosit operatia OR intre 
	// toate semnalele busy ale modulelor de decriptare.
	
	decryption_regfile regfile(clk_sys, rst_n, addr, read, write, wdata, rdata, done, error, select, caesar_key, scytale_key, zigzag_key);
	demux demux(clk_sys, clk_mst, rst_n, select[1:0], data_i, valid_i, caesar_data_i, caesar_valid_i, scytale_data_i, scytale_valid_i, zigzag_data_i, zigzag_valid_i);
	caesar_decryption caesar(clk_sys, rst_n, caesar_data_i, caesar_valid_i, caesar_key, caesar_data_o, caesar_busy, caesar_valid_o);
	scytale_decryption scytale(clk_sys, rst_n, scytale_data_i, scytale_valid_i, scytale_key[15:8], scytale_key[7:0], scytale_data_o, scytale_valid_o, scytale_busy);
	zigzag_decryption zigzag(clk_sys, rst_n, zigzag_data_i, zigzag_valid_i, zigzag_key[7:0], zigzag_data_o, zigzag_valid_o, zigzag_busy);
	mux mux(clk_sys, rst_n, select[1:0], data_o, valid_o, caesar_data_o, caesar_valid_o, scytale_data_o, scytale_valid_o, zigzag_data_o, zigzag_valid_o);
	assign busy = caesar_busy || scytale_busy || zigzag_busy; 
	
endmodule
