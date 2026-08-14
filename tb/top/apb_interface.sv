`timescale 1ns/1ps

interface apb_if #(parameter DATA_BUS_WIDTH=32, ADDR_BUS_WIDTH=32
	)(
	input logic  pclk
	);
	
	logic presetn;
	logic psel;
	logic penable;
	logic pwrite;

	
	
	logic [DATA_BUS_WIDTH-1:0] pwdata;
	logic [ADDR_BUS_WIDTH-1:0] paddr;
	logic [DATA_BUS_WIDTH-1:0] prdata;

	logic pready;
	logic pslverr;
	
endinterface

