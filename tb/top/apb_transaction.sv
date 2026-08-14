`timescale 1ns/1ps

class transaction #(parameter DATA_BUS_WIDTH=32, ADDR_BUS_WIDTH=32);
	rand bit pwrite;
	rand logic [ADDR_BUS_WIDTH-1:0] paddr;
        rand logic [DATA_BUS_WIDTH-1:0] pwdata;
	bit psel;
	bit penable;

	
	logic [DATA_BUS_WIDTH-1:0] prdata;
        bit pready;
        bit pslverr;

        bit [DATA_BUS_WIDTH-1:0] exp_prdata;
        bit exp_pready;
        bit exp_pslverr;
       

	function void display(string tag);
		$display("[%0t] [%0s] psel=%0b penable=%0b pwrite=%0b paddr=%0h pwdata=%0h | prdata=%0h pready=%0b pslverr=%0b", $time, tag,
		psel, penable, pwrite, paddr, pwdata,
		prdata, pready, pslverr
		);

    endfunction
endclass

