class scoreboard #(
    parameter DATA_BUS_WIDTH = 32,
    parameter ADDR_BUS_WIDTH = 32,
    parameter MEMSIZE        = 64,
    parameter MEM_BLOCK_SIZE = 8,
    parameter RESET_VAL      = 0
);

    mailbox mon2sb;

    bit [MEM_BLOCK_SIZE-1:0] expected_mem [bit [ADDR_BUS_WIDTH-1:0]];



    int compare_count = 0;
    int read_pass = 0;
    int read_fail = 0;
    int error_pass= 0;
    int error_fail= 0;
    int ready_pass= 0;
    int ready_fail= 0;

    localparam int BLOCKS_PER_WORD = DATA_BUS_WIDTH / MEM_BLOCK_SIZE;
    localparam int MEM_BYTES       = MEMSIZE * BLOCKS_PER_WORD;


    
    function new(mailbox mon2sb);

        this.mon2sb = mon2sb;
	for (int i = 0; i < MEM_BYTES; i++) begin
            expected_mem[i] = RESET_VAL;
        end
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
		
		//write 

		if (tr.pwrite) begin
			if (tr.paddr <= (MEM_BYTES - BLOCKS_PER_WORD)) begin
				for (int i = 0; i < BLOCKS_PER_WORD; i++) begin
					expected_mem[tr.paddr + i] =
						tr.pwdata[(i * MEM_BLOCK_SIZE)+: MEM_BLOCK_SIZE];
				end
				exp_pslverr = 1'b0;
				$display("======================= DATA WRITE =============================");
			end
			else begin
				exp_pslverr = 1'b1;
			end
		end


                // READ

                else begin
			if (tr.paddr <= (MEM_BYTES - BLOCKS_PER_WORD)) begin
				expected_data = '0;
				for (int i = 0; i < BLOCKS_PER_WORD; i++) begin
					if (expected_mem.exists(tr.paddr + i)) begin
						expected_data[(i * MEM_BLOCK_SIZE) +: MEM_BLOCK_SIZE] =
							expected_mem[tr.paddr + i];
					end
					else begin
						expected_data[(i * MEM_BLOCK_SIZE) +: MEM_BLOCK_SIZE] = RESET_VAL;
					end
				end
				exp_pslverr = 1'b0;
				$display("======================= DATA READ =============================");
			end
			
			else begin
				expected_data = '0;
				exp_pslverr = 1'b1;
			end
			
			if (tr.prdata == expected_data) begin
				read_pass++;
				$display("[%0t] READ DATA MATCH | ADDR=%0h | EXPECTED=%0h | ACTUAL=%0h", $time, tr.paddr, expected_data, tr.prdata);
			end
			
			else begin
				read_fail++;
				$display("[%0t] READ DATA FAIL | ADDR=%0h | EXPECTED=%0h | ACTUAL=%0h", $time, tr.paddr, expected_data, tr.prdata);
			end
		end

                // Compare PREADY

                if (tr.pready != exp_pready) begin
			ready_fail++;
			$display("[%0t] PREADY FAIL | EXP=%0b ACT=%0b", $time, exp_pready, tr.pready);
		end

                // Compare PSLVERR

                if (tr.pslverr != exp_pslverr) begin
                    error_fail++;
                    $display("[%0t] PSLVERR FAIL | EXP=%0b ACT=%0b", $time, exp_pslverr, tr.pslverr);
                end
                compare_count++;
		$display("[%0t] [SCOREBOARD] COUNT = %0d", $time, compare_count);
            end
    end
    endtask
    		

		


    task report();

        $display("");
        $display("==============================");
        $display("       SCOREBOARD REPORT");
        $display("==============================");
        $display("READ PASS  = %0d", read_pass);
        $display("READ FAIL  = %0d", read_fail);
        $display("PSLVERR FAIL  = %0d", error_fail);
        $display("READY FAIL = %0d", ready_fail);
        $display("==============================");

    endtask

endclass
