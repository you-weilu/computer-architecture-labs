# CompEng 361 - Lab 2 Student Makefile

ALU     ?= template_execute.v
VECTORS ?= test_vectors.csv
SIM_BIN  = lab2_sim
STIM_VH  = tb_stimulus.vh

.PHONY: all sim test local-test mutants check-csv clean

all: sim local-test

check-csv:
	python3 csv_to_tb.py --check -i $(VECTORS)

sim:
	python3 csv_to_tb.py -i $(VECTORS) -o $(STIM_VH)
	iverilog -o $(SIM_BIN) lab2_tb.v $(ALU)
	vvp $(SIM_BIN)

local-test mutants test:
	python3 run_local_tests.py --alu $(ALU) --vectors $(VECTORS)

clean:
	rm -f $(SIM_BIN) $(STIM_VH) lab2.vcd
