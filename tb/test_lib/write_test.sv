class write_test extends base_test #(
    DATA_BUS_WIDTH,
    ADDR_BUS_WIDTH
);

    virtual task apply_reset(int cycles = 2);
        vif.presetn = 1'b0;
        $display("[%0t] RESET ASSERTED", $time);
        repeat(cycles) @(posedge vif.pclk);
        vif.presetn = 1'b1;
        repeat(2) @(posedge vif.pclk);
        $display("[%0t] RESET DEASSERTED", $time);
    endtask
    
    function new(
        virtual apb_if #(DATA_BUS_WIDTH, ADDR_BUS_WIDTH) vif
    );
        super.new(vif);
    endfunction

    bit [ADDR_BUS_WIDTH-1:0] test_addr[];
    bit test_pwrite[];

    virtual task run();

        test_addr   = new[total_transactions];
        test_pwrite = new[total_transactions];

        for (int i = 0; i < total_transactions; i++) begin

            // WRITE ONLY
            test_addr[i]   = i*4;
            test_pwrite[i] = 1;

        end

        $display("[%0t] TOTAL TRANSACTIONS = %0d",
                 $time, total_transactions);

        env_o.agt.gen.count = total_transactions;

        env_o.agt.gen.run(1, test_addr, test_pwrite);

	//Scoreboard 
	
	    wait (env_o.sb.compare_count == total_transactions);
	   $finish;

    endtask

endclass
