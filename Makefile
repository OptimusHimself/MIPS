# 顶层Makefile

# 所有源文件和测试文件
SRC := $(wildcard src/*.v)
TBS := $(wildcard tb/*.v)

# 编译输出目录
BUILD_DIR := build

# .out 编译目标
OUTS := $(patsubst tb/%.v, $(BUILD_DIR)/%.out, $(TBS))

# 默认目标：编译所有 testbench
all: $(OUTS)

# 编译规则，每个 testbench 编译为 .out 文件
$(BUILD_DIR)/%.out: tb/%.v $(SRC)
	@mkdir -p $(BUILD_DIR)
	iverilog -o $@ $^
	@echo "Compiled $@"

# 运行指定 testbench 并生成 vcd 文件（默认文件名 waveform.vcd）
run:
	vvp $(BUILD_DIR)/$(TB).out

# 运行并查看波形：默认查找 waveform.vcd
wave: run
	gtkwave waveform.vcd &

# 清除所有中间和输出文件
clean:
	rm -rf $(BUILD_DIR) *.vcd
