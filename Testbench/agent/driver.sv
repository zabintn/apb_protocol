`timescale 1ns/1ps
class driver #(
        parameter DATA_BUS_WIDTH=32, ADDR_BUS_WIDTH=32
        );
        mailbox gen2drv;
        virtual apb_if #(DATA_BUS_WIDTH, ADDR_BUS_WIDTH) vif;
        transaction #(DATA_BUS_WIDTH, ADDR_BUS_WIDTH) tr;

        function new(mailbox gen2drv, virtual apb_if #(DATA_BUS_WIDTH, ADDR_BUS_WIDTH) vif);
                this.gen2drv = gen2drv;
                this.vif     = vif;
                $display("[%0t] DRIVER CONSTRUCTED", $time);
        endfunction

        task run;
		forever begin
                        gen2drv.get(tr);

                        // SETUP phase:
                        @(posedge vif.pclk);
                        vif.psel    <= 1'b1;
                        vif.penable <= 1'b0;
                        vif.pwrite  <= tr.pwrite;
                        vif.paddr   <= tr.paddr;
                        vif.pwdata  <= tr.pwdata;

                        // ACCESS phase
                        @(posedge vif.pclk);
                        vif.penable <= 1'b1;
			
			@(posedge vif.pclk);
			wait (vif.pready);
			@(negedge vif.pclk);
                      
                        tr.prdata  = vif.prdata;
                        tr.pready  = vif.pready;
                        tr.pslverr = vif.pslverr;

                        tr.display("DRIVER");

                        
                        @(posedge vif.pclk);
                        vif.psel    <= 1'b0;
                        vif.penable <= 1'b0;
                end
        endtask
endclass

