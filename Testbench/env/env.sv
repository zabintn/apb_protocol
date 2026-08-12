`timescale 1ns/1ps

class env #(parameter DATA_BUS_WIDTH=32, ADDR_BUS_WIDTH=32);
        agent agt;
        scoreboard sb;

        mailbox mon2sb;

        function new(virtual apb_if #(DATA_BUS_WIDTH, ADDR_BUS_WIDTH) vif);

                mon2sb=new();
    $display("[%0t] ENV: before agent", $time);
                agt=new(mon2sb, vif);
	$display("[%0t] ENV: after agent", $time);
            $display("[%0t] ENV: before scoreboard", $time);       
       	sb=new(mon2sb);
	    $display("[%0t] ENV: after scoreboard", $time);
        endfunction
endclass
