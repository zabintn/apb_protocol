class reset_test extends base_test #(
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
    
    //after applying reset perform reads to check whether the memory has
    //cleared out or not

    virtual task run();
        bit [ADDR_BUS_WIDTH-1:0] addresses[];
	bit test_pwrite[];
        env_o.agt.gen.count = 0;
        apply_reset();
        addresses = new[64];
      
      	for (int i = 0; i < 64; i++) begin
            addresses[i] = i * 4;
	    test_pwrite[i] = 1'b0;
        end
      
      	env_o.agt.gen.count = 64;
	env_o.agt.gen.run(1, addresses, test_pwrite);
        $display("[%0t] END OF RESET TEST", $time);

    endtask

endclass
