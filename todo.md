# task
task 用法：留给regfile 初始化


``` verilog
\\ 计划用task实现、

 // 存储器初始化（示例）
    initial begin
        $readmemh("code.txt", regArr_im); // 从文件加载指令
    end

```

# 最后优化：

Extender


~~infetch , 感觉 aluzero 有点多余。~~

学习git 切换版本。
新的插件。快速加入注释。
select_aluPerformance 从add sub的opcode看出全部是有符号的加减啊。

## 几个复位信号的命名
rst_regFile
rst_dataMem
rst_im
rst_pc

使用NPC处理Jump， beq的extend


# 总结：
输出类型可以是reg

lw sw 1KB 使用 256 * 32 最好

assign 用法：
不能用在block（if else, always）
用于给wire 且是 output赋值 中间wire变量由组合电路驱动不需要用assign


## 自动化 习惯
1. Makefile比task.json正规。因此，发布包含Makefile会更加正规。 当然，也可以发布task.json


```bash

# 编译所有 testbench
make

# 编译并运行 control_tb.v（或你指定的 TB 文件）
make run TB=control_tb

# 编译、运行，并用 GTKWave 打开 waveform.vcd
make wave TB=control_tb

# 清理输出
make clean

```