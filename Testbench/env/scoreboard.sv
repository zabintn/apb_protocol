class scoreboard #(
    parameter DATA_BUS_WIDTH = 32,
    parameter ADDR_BUS_WIDTH = 32,
    parameter MEMSIZE        = 64
);

    mailbox mon2sb;

    bit [DATA_BUS_WIDTH-1:0]
        expected_mem [bit [ADDR_BUS_WIDTH-1:0]];

    int compare_count = 0;
    int pass = 0;
    int fail = 0;


    function new(mailbox mon2sb);

        this.mon2sb = mon2sb;

        $display("Scoreboard Constructed");

    endfunction


    task run();

        forever begin

            transaction #(DATA_BUS_WIDTH, ADDR_BUS_WIDTH) tr;
            bit exp_pready;
            bit exp_pslverr;
            bit [DATA_BUS_WIDTH-1:0] expected_data;

            mon2sb.get(tr);


            // Only process ACCESS phase
            if (tr.psel && tr.penable) begin

                exp_pready  = 1'b1;
                exp_pslverr = 1'b0;
                expected_data = '0;


               // WRITE


	       if (tr.pwrite) begin
		       if (tr.paddr < MEMSIZE) begin
			       expected_mem[tr.paddr] = tr.pwdata;
			       exp_pslverr = 1'b0;
			       pass++;
			       $display("======================= DATA WRITE =============================");
		       end
		       else begin
			       exp_pslverr = 1'b1;
		       end
	       end
	       // READ

	       else begin
		       if (tr.paddr < MEMSIZE) begin
			       if (expected_mem.exists(tr.paddr))
				       expected_data = expected_mem[tr.paddr];
			       else 
				       expected_data = '0;
			       	       exp_pslverr = 1'b0;
				       $display("======================= DATA READ =============================");
			       end
			       else begin
				       expected_data = '0;
				       exp_pslverr = 1'b1;
			       end


    		if (tr.prdata == expected_data) begin
			pass++;
			$display("[%0t] READ DATA MATCH | ADDR=%0h | EXPECTED=%0h | ACTUAL=%0h", $time, tr.paddr, expected_data, tr.prdata);
		end
		else begin
			fail++;
			$display("[%0t] READ DATA FAIL | ADDR=%0h | EXPECTED=%0h | ACTUAL=%0h", $time, tr.paddr, expected_data, tr.prdata);
		end
		end

                // Compare PREADY

                if (tr.pready != exp_pready) begin
                    fail++;
                    $display("[%0t] PREADY FAIL | EXP=%0b ACT=%0b", $time, exp_pready, tr.pready);
                end
		else
			$display("[%0t] PREADY CORRRECT | EXP=%0b ACT=%0b", $time, exp_pready, tr.pready);


                // Compare PSLVERR

                if (tr.pslverr != exp_pslverr) begin
                    fail++;
                    $display("[%0t] PSLVERR FAIL | EXP=%0b ACT=%0b", $time, exp_pslverr, tr.pslverr);
                end
                compare_count++;
            end
    end
    endtask
    		

		


    task report();

        $display("");
        $display("==============================");
        $display("       SCOREBOARD REPORT");
        $display("==============================");
        $display("PASS  = %0d", pass);
        $display("FAIL  = %0d", fail);
        $display("TOTAL = %0d", compare_count);
        $display("==============================");

    endtask

endclass
