class generator #(
    parameter DATA_BUS_WIDTH = 32,
    parameter ADDR_BUS_WIDTH = 32
);

    mailbox gen2drv;
    int count;
    virtual apb_if #(DATA_BUS_WIDTH, ADDR_BUS_WIDTH) vif;


    function new(mailbox gen2drv, virtual apb_if #(DATA_BUS_WIDTH, ADDR_BUS_WIDTH) vif);
        this.gen2drv = gen2drv;
	this.vif=vif;
    endfunction

task run(
	input bit use_test_addr = 0,
	input bit [ADDR_BUS_WIDTH-1:0] test_addr[] = {},
       	input bit test_pwrite[] = {}
	);
	
	for (int i = 0; i < count; i++) begin
		transaction #(DATA_BUS_WIDTH, ADDR_BUS_WIDTH) tr;
		tr = new();
		if (!tr.randomize() with {
			paddr inside {[0:128]};
			})
			$error("RANDOMIZATION FAILED");
       
		       	if (use_test_addr) begin
				tr.paddr  = test_addr[i];
				tr.pwrite = test_pwrite[i];
			end			
			tr.display("GENERATOR");
			gen2drv.put(tr);
		end
endtask    
    
task write();
    	
	    repeat(count) begin
		    transaction #(DATA_BUS_WIDTH, ADDR_BUS_WIDTH) tr;
		    tr=new();

		    if(!tr.randomize() with {
			    paddr inside {[0:63]};
			    pwrite==1;
			    })
			    $error("RANDOMIZATION FAILED");
	
		tr.display("GENERATOR");
		gen2drv.put(tr);
	end

    endtask 
    
    task read();
    	
	    repeat(count) begin
		    transaction #(DATA_BUS_WIDTH, ADDR_BUS_WIDTH) tr;
		    tr=new();

		    if(!tr.randomize() with {
			    paddr inside {[0:63]};
			    pwrite==0;
			    })
			    $error("RANDOMIZATION FAILED");
	
		tr.display("GENERATOR");
		gen2drv.put(tr);
	end

    endtask


endclass
