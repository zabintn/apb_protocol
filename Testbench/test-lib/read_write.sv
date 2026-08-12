class read_write extends base_test #(
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

        test_addr   = new[total_transactions];
        test_pwrite = new[total_transactions];

        for (int i = 0; i < total_transactions/2; i++) begin

            // WRITE
            test_addr[i]   = i;
            test_pwrite[i] = 1;

            // READ
            test_addr[i + total_transactions/2]   = i;
            test_pwrite[i + total_transactions/2] = 0;

        end

        $display("[%0t] TOTAL TRANSACTIONS = %0d",
                 $time, total_transactions);

        env_o.agt.gen.count = total_transactions;

        env_o.agt.gen.run(
            1,
            test_addr,
            test_pwrite
        );

    endtask

endclass
