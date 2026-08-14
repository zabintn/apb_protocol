`timescale 1ns/1ps
class agent #(parameter DATA_BUS_WIDTH=32, ADDR_BUS_WIDTH=32);

        driver drv;
        monitor mon;
        generator gen;

        mailbox gen2drv;
        virtual apb_if #(DATA_BUS_WIDTH, ADDR_BUS_WIDTH) vif;

        function new(mailbox mon2sb, virtual apb_if #(DATA_BUS_WIDTH, ADDR_BUS_WIDTH) vif);
                this.vif=vif;
		gen2drv=new();
                drv=new(gen2drv, vif);
                mon=new(mon2sb, vif);
                gen=new(gen2drv, vif );
        endfunction

	task run();
		fork
			gen.run();
			drv.run();
			mon.run();
		join_none
	endtask

endclass

