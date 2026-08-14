class overwrite_test extends base_test #(
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
        apply_reset();
	// Write same address 3 times with different data, then read once
        test_addr   = new[4];
        test_pwrite = new[4];
        test_addr   = '{4, 4, 4, 4};
        test_pwrite = '{1, 1, 1, 0};

        env_o.agt.gen.count = 4;
        env_o.agt.gen.run(1, test_addr, test_pwrite);
	repeat(4 * 60) @(posedge vif.pclk);  
        $display("[%0t] END OF SAME ADDR OVERWRITE TEST", $time);
        $finish;
    endtask
endclass
