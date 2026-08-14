import apb_env_pkg::*;

class base_test #(
    parameter DATA_BUS_WIDTH = 32,
    parameter ADDR_BUS_WIDTH = 32
);

    env env_o;
    int total_transactions;
    virtual apb_if #(DATA_BUS_WIDTH, ADDR_BUS_WIDTH) vif;

    function new(virtual apb_if #(DATA_BUS_WIDTH, ADDR_BUS_WIDTH) vif);
    	this.vif=vif;
        $display("[%0t] INSIDE THE BASE TEST CONSTRUCTOR", $time);
        env_o = new(vif);
    endfunction
    
    virtual task apply_reset(int cycles = 2);
        vif.presetn = 1'b0;
        repeat(cycles) @(posedge vif.pclk);
        vif.presetn = 1'b1;
    endtask
    
    virtual task run();
	apply_reset();
	env_o.agt.gen.count = total_transactions;
        env_o.agt.gen.run();
    endtask

endclass	
