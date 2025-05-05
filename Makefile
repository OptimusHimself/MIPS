# Top-level Makefile for MIPS Verilog Project

SRC := $(wildcard src/*.v)
TBS := $(basename $(notdir $(wildcard tb/*.v)))
BUILD := build
OUTPUT := output

# Default target
all: build

# Build all testbenches
build: $(TBS:%=$(BUILD)/%.out)

# Compile rule for each testbench
$(BUILD)/%.out: tb/%.v $(SRC)
	@mkdir -p $(BUILD)
	iverilog -o $@ $^ -I src

# Run simulation and generate VCD
wave: $(BUILD)/$(TB).out
	vvp $<
	gtkwave $(OUTPUT)/waveform_$(TB).vcd &

# Clean all intermediate files
clean:
	rm -rf $(BUILD)/* $(OUTPUT)/*

.PHONY: all build wave clean
