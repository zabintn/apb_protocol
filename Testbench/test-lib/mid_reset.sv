class mid_reset_test extends base_test #(
    DATA_BUS_WIDTH,
    ADDR_BUS_WIDTH
);
    function new(
        virtual apb_if #(DATA_BUS_WIDTH, ADDR_BUS_WIDTH) vif
    );
        super.new(vif);
    endfunction
    bit [ADDR_BUS_WIDTH-1:0] test_addr[];
    bit test_pwrite[];
    virtual task run();
        test_addr   = new[1];
        test_pwrite = new[1];
        test_addr   = '{4};
        test_pwrite = '{1};
        env_o.agt.gen.count = 1;
        env_o.agt.gen.run(1, test_addr, test_pwrite);

        @(posedge vif.pclk);

        // Assert reset in the middle
        vif.presetn = 0;
        $display("[%0t] RESET ASSERTED", $time);
        repeat(2) @(posedge vif.pclk);

        // Check DUT
        if (vif.pready !== 0)
            $display("MID RESET TEST FAIL: PREADY");
        if (vif.pslverr !== 0)
            $display("MID RESET TEST FAIL: PSLVERR");
        else
            $display("MID RESET TEST PASSED. PREADY=%0b, PSLVERR=%0b", vif.pready, vif.pslverr);

        vif.presetn = 1;
        repeat(2) @(posedge vif.pclk);
        $display("[%0t] RESET DEASSERTED", $time);

        test_addr   = '{4};
        test_pwrite = '{0};
        env_o.agt.gen.count = 1;
        env_o.agt.gen.run(1, test_addr, test_pwrite);

        $display("[%0t] END OF MID RESET TEST", $time);
        $finish;
    endtask
endclass
