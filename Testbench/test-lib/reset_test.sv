class reset_test extends base_test #(
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

task run();

    env_o.agt.gen.count = 0;

    vif.presetn = 0;
    $display("RESET ASSERTED. PREADY=%0b", vif.pready);
	
    repeat(2) @(posedge vif.pclk);

    // Check reset behavior
    if (vif.pready !== 0)
	    $display("RESET TEST FAIL: PREADY");
    
    if (vif.pslverr !== 0)
	    $display("RESET TEST FAIL: PSLVERR");

    else $display("RESET TEST PASSED. PREADY= %0b, PSLVERR= %0b", vif.pready, vif.pslverr);

    vif.presetn = 1;

    repeat(2) @(posedge vif.pclk);
    $display("RESET DEASSERTED. PREADY=%0b", vif.pready);

    test_addr   = new[2];
    test_pwrite = new[2];

    test_addr   = '{5, 5};
    test_pwrite = '{1, 0};

    env_o.agt.gen.count = 5;
    env_o.agt.gen.run(1, test_addr, test_pwrite);
    $display("END OF RESET TEST AT [%0t]", $time);
    $finish;

endtask
endclass
