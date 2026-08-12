`timescale 1ns/1ps
class monitor #(parameter DATA_BUS_WIDTH=32, ADDR_BUS_WIDTH=32
        );
        mailbox mon2sb;
        virtual apb_if #(DATA_BUS_WIDTH, ADDR_BUS_WIDTH) vif;

        function new(mailbox mon2sb,  virtual apb_if #(DATA_BUS_WIDTH, ADDR_BUS_WIDTH) vif);
                this.mon2sb  = mon2sb;
           
                this.vif     = vif;
                $display("[%0t] MONITOR CONSTRUCTED", $time);
        endfunction
task run();

    forever begin

        transaction #(DATA_BUS_WIDTH, ADDR_BUS_WIDTH) mon_tr;
        mon_tr = new();

        // Wait for SETUP phase
        do @(posedge vif.pclk); 
	while (!(vif.psel && !vif.penable));
		
	@(negedge vif.pclk);
        mon_tr.psel  = vif.psel;
        mon_tr.pwrite = vif.pwrite;
        mon_tr.paddr = vif.paddr;
        mon_tr.pwdata = vif.pwdata;

        // Wait for ACCESS phase
        @(posedge vif.pclk);
	@(posedge vif.pclk);
        wait(vif.psel && vif.penable);

        mon_tr.penable = vif.penable;

        // Wait for transfer completion
        wait(vif.pready);

        mon_tr.prdata  = vif.prdata;
        mon_tr.pready  = vif.pready;
        mon_tr.pslverr = vif.pslverr;

        mon_tr.display("MONITOR");

        mon2sb.put(mon_tr);

    end

endtask

endclass

