class fixed_test extends base_test #(
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


        test_addr = new[total_transactions]; 
	test_addr = '{16, 8, 20, 16, 8, 20, 64, 68, 72, 24, 28, 32, 36, 128, 253, 254, 253, 255, 254, 255};
	test_pwrite = '{1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0 };      

        $display("[%0t] TOTAL TRANSACTIONS = %0d",
                 $time, total_transactions);

        // RUN TEST
        env_o.agt.gen.count = total_transactions;
        env_o.agt.gen.run(1, test_addr, test_pwrite);

    endtask

endclass

