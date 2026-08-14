`timescale 1ns/1ps


module  tb_top #(parameter DATA_BUS_WIDTH=32,
parameter ADDR_BUS_WIDTH=32,
parameter TOTAL_TRANSACTIONS = 64 
);
    import test_lib_pkg::*;

    bit pclk=0;
    bit presetn;
    base_test test;
    read_write rw;
    fixed_test ft;
    reset_test rt;
    mid_reset_test wt;
    overwrite_test ot;
    boundary_test bt;
	
    always #5 pclk=~pclk;

    apb_if #(.DATA_BUS_WIDTH(DATA_BUS_WIDTH), .ADDR_BUS_WIDTH(ADDR_BUS_WIDTH)) vif(pclk);

    //DUT

    apb_v3_sram #(
            .ADDR_BUS_WIDTH(ADDR_BUS_WIDTH) ,
            .DATA_BUS_WIDTH(DATA_BUS_WIDTH),
	    .MEMSIZE           (64), 
	    .MEM_BLOCK_SIZE      (8),
	    .RESET_VAL           (0),
	    .EN_WAIT_DELAY_FUNC  (1),
	    .MIN_RAND_WAIT_CYC   (2),
	    .MAX_RAND_WAIT_CYC   (2)
	    ) DUT (.PCLK(vif.pclk), .PRESETn(vif.presetn),
		   .PREADY(vif.pready), .PSLVERR(vif.pslverr), .PRDATA(vif.prdata),
                   .PSEL(vif.psel), .PENABLE(vif.penable), .PWRITE(vif.pwrite),
                   .PADDR(vif.paddr), .PWDATA(vif.pwdata)
                    );
	
    //DETERMINE WHICH TEST TO RUN

    task run_test();

    if ($test$plusargs("RW")) begin
            $display("[%0t] RUNNING READ_WRITE TEST", $time);
            rw = new(vif);
            test = rw;

    end
    else if ($test$plusargs("FIXED")) begin
	    $display("[%0t] RUNNING FIXED TEST", $time);
	    ft=new(vif);
	    test=ft;
    end	   
    else if ($test$plusargs("RESET")) begin
	    $display("[%0t] RUNNING RESET TEST", $time);
	    rt=new(vif);
	    test=rt;
    end
    else if ($test$plusargs("MID")) begin
	    $display("[%0t] RUNNING MID TRANSACTION RESET CHECK TEST", $time);
	    wt=new(vif);
	    test=wt;
    end
    else if ($test$plusargs("OW")) begin
            $display("[%0t] RUNNING OVERWRITE TEST", $time);
            ot=new(vif);
            test=ot;
    end
    else if ($test$plusargs("BOUNDARY")) begin
            $display("[%0t] RUNNING BOUNDARY TEST", $time);
            bt=new(vif);
            test=bt;
    end

    else begin
            $display("[%0t] RUNNING BASE TEST", $time);
            test = new(vif);
    end
    endtask

    initial begin
	    $dumpfile("waveform.vcd");
	    $dumpvars(1, tb_top);
    end

    initial begin


            run_test();
            test.total_transactions = TOTAL_TRANSACTIONS;

            fork
                    test.env_o.agt.mon.run();
                    test.env_o.agt.drv.run();
                    test.env_o.sb.run();
            join_none

            test.run();

            wait(test.env_o.sb.compare_count == test.total_transactions);
            test.env_o.sb.report();
            $display("[%0t] ENV: WAIT CONDITION SATISFIED", $time);

            $finish;

    end

endmodule





