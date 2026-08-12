# ----------------------------------------
# Vivado xsim-based Makefile
# Compile -> Elaborate -> Simulate flow
# ----------------------------------------

TEST ?= base_test

RTL_DIR   = ../RTL
TB_DIR    = .
SIM_DIR   = .

TOP       = tb_top
SNAPSHOT  = tb_top_snap

RTL_SRC   = $(RTL_DIR)/apb_v3_sram.sv
TB_SRC    = $(TB_DIR)/compile.f
.PHONY: compile elaborate simulate run clean

# Step 1: Compile RTL + testbench sources
compile:
	xvlog --sv $(RTL_SRC) -f $(TB_SRC)

# Step 2: Elaborate design into a simulation snapshot
elaborate: compile
	xelab $(TOP) -s $(SNAPSHOT)

# Step 3: Run simulation:
simulate: elaborate
	xsim $(SNAPSHOT) -runall -testplusarg $(TEST)


# Convenience target: does all three in order
all: compile elaborate simulate

clean:
	rm -rf xsim.dir *.log *.jou *.pb *.wdb .Xil xelab.pb webtalk*
