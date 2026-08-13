class boundary_test extends base_test #(
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
        test_addr   = new[4];
        test_pwrite = new[4];
        test_addr   = '{252, 252, 253, 253};
        test_pwrite = '{1, 0, 1, 0};

        env_o.agt.gen.count = 4;
        env_o.agt.gen.run(1, test_addr, test_pwrite);
	        repeat(4 * 60) @(posedge vif.pclk);


        $display("[%0t] END OF BOUNDARY ADDR TEST", $time);
        $finish;
    endtask
endclass
