class mid_reset_test extends base_test #(
    DATA_BUS_WIDTH,
    ADDR_BUS_WIDTH
);

    function new(
        virtual apb_if #(DATA_BUS_WIDTH, ADDR_BUS_WIDTH) vif
    );
        super.new(vif);
    endfunction
    // Apply reset for two cycles
    virtual task apply_reset(int cycles = 2);
        vif.presetn = 1'b0;
        $display("[%0t] RESET ASSERTED", $time);
        repeat(cycles) @(posedge vif.pclk);
        vif.presetn = 1'b1;
        repeat(2) @(posedge vif.pclk);
        $display("[%0t] RESET DEASSERTED", $time);
    endtask

virtual task run();

    bit [ADDR_BUS_WIDTH-1:0] addresses[];
    bit test_pwrite[];

    // =========================
    // POWER-ON RESET
    // =========================
    apply_reset();


    // =========================
    // WRITE BEFORE RESET
    // =========================
    addresses   = new[1];
    test_pwrite = new[1];

    addresses[0]   = 4;
    test_pwrite[0] = 1'b1;

    env_o.agt.gen.count = 1;
    env_o.agt.gen.run(1, addresses, test_pwrite);

    wait (env_o.sb.compare_count >= 1);

    $display("[%0t] WRITE BEFORE RESET COMPLETED", $time);


    // MID TRANSACTION RESET
    vif.presetn = 1'b0;
    $display("[%0t] RESET ASSERTED", $time);

    repeat(2) @(posedge vif.pclk);

    if (vif.pready !== 0)
        $display("MID RESET TEST FAIL: PREADY");

    if (vif.pslverr !== 0)
        $display("MID RESET TEST FAIL: PSLVERR");
    else
        $display("MID RESET TEST PASSED. PREADY=%0b, PSLVERR=%0b",
                 vif.pready, vif.pslverr);


    // DEASSERT RESET
    vif.presetn = 1'b1;
    repeat(2) @(posedge vif.pclk);

    $display("[%0t] RESET DEASSERTED", $time);

    addresses[0]   = 4;
    test_pwrite[0] = 1'b0;

    env_o.agt.gen.count = 1;
    env_o.agt.gen.run(1, addresses, test_pwrite);

    wait (env_o.sb.compare_count >= 2);

    $display("[%0t] END OF MID RESET TEST", $time);
    $finish;

endtask

endclass
