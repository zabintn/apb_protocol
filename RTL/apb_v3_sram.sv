`timescale 1ns/1ps
module apb_v3_sram #(
                    // device parameters
                    parameter ADDR_BUS_WIDTH=32,        // Width of Address bus i.e. PADDR
                    parameter DATA_BUS_WIDTH=32,        // Width of Data bus (i.e. PWDATA and PRDATA)
                    parameter MEMSIZE=64,               // RAM memory Size
                    parameter MEM_BLOCK_SIZE=8,         // RAM memory block size
                    parameter RESET_VAL=0,              // Default Reset value of DUT
                    parameter EN_WAIT_DELAY_FUNC=0,     // Enable Random Delay Assertion in read or write operation 
                    parameter MIN_RAND_WAIT_CYC=0,      // Minimum cycle delay for read and write operation
                    parameter MAX_RAND_WAIT_CYC=1)(     // Maximum cycle delay for read and write operation
                    // IO ports
                    input  wire                         PRESETn,
                    input  wire                         PCLK,
                    input  wire                         PSEL,
                    input  wire                         PENABLE,
                    input  wire                         PWRITE,
                    input  wire [ADDR_BUS_WIDTH-1:0]    PADDR,
                    input  wire [DATA_BUS_WIDTH-1:0]    PWDATA,
                    output reg  [DATA_BUS_WIDTH-1:0]    PRDATA,
                    output reg                          PREADY,
                    output reg                          PSLVERR
                    );

 reg [MEM_BLOCK_SIZE-1:0] memory[MEMSIZE-1:0]; localparam IDLE=0, SETUP=1, ACCESS=2, WAIT=3; localparam WRITE=1, READ=0; reg [1:0] state; integer wait_cyc_cntr=0; integer wait_cyc_limit; task reset_ram; input integer reset_value; integer i; begin for(i=0;i<MEMSIZE;i=i+1) memory[i]=reset_value; end endtask task wr_data2mem; input integer mem_block_size; input integer data_bus_width; integer rqrd_tx_num; integer i; begin rqrd_tx_num=data_bus_width/mem_block_size; if(data_bus_width==mem_block_size) begin memory[PADDR]=PWDATA; memory[ADDR_BUS_WIDTH/2]='0; end else begin for(i=0;i<rqrd_tx_num;i=i+1) begin memory[i]=PWDATA[((i+1)*MEM_BLOCK_SIZE)-1 +: (MEM_BLOCK_SIZE)]; memory[ADDR_BUS_WIDTH/2]='0; end end end endtask initial begin state=IDLE; wait_cyc_limit=$urandom_range(MIN_RAND_WAIT_CYC,MAX_RAND_WAIT_CYC); end always @(posedge PCLK or PRESETn) begin if(!PRESETn) begin PREADY=0; PSLVERR=0; PRDATA=0; reset_ram(RESET_VAL); end else begin if(!PSEL&&!PENABLE) begin PREADY=0; PSLVERR=0; end else if(PSEL&&!PENABLE) begin if(EN_WAIT_DELAY_FUNC==1) begin PREADY=0; PSLVERR=0; end else begin PREADY=1; PSLVERR=0; end end else if(PSEL&&PENABLE) begin if(EN_WAIT_DELAY_FUNC) begin repeat(wait_cyc_limit) @(posedge PCLK); PREADY=1; end if(PWRITE==WRITE) begin if(PADDR<MEMSIZE) begin wr_data2mem(MEM_BLOCK_SIZE,DATA_BUS_WIDTH); PSLVERR=0; end else begin PSLVERR=1; end end else if(PWRITE==READ) begin if(PADDR<MEMSIZE) begin PRDATA=memory[PADDR]; PSLVERR=0; end else begin PSLVERR=1; end end @(posedge PCLK); PREADY=0; end end end

endmodule
