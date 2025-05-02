# 顶层Makefile

# 所有 Verilog 源文件
SRC := $(wildcard src/*.v)

# 所有 testbench 文件
TBS := $(wildcard tb/*.v)

# 输出目录
BUILD_DIR := build

# 为每个 testbench 生成对应的输出目标路径
OUTS := $(patsubst tb/%.v, $(BUILD_DIR)/%.out, $(TBS))

# 编译目标（默认）
all: $(OUTS)

# 编译规则
$(BUILD_DIR)/%.out: tb/%.v $(SRC)
	@mkdir -p $(BUILD_DIR)
	iverilog -o $@ $^
	@echo "Compiled $@"

# 运行某个 testbench（例如 make run TB=alu_tb）
run:
	vvp $(BUILD_DIR)/$(TB).out

# 清除输出文件
clean:
	rm -rf $(BUILD_DIR)
