# 使用make

很简单，两种常用命令分别对应常用流程：编译所有design模块和testbench模块。然后用gtkwave查看波形。
加入说你要给设计模块`transformer`, design module name: `transformer` // same as fileName
写tb：
tb file name: `transformer_tb.v`
tb module name `module transformer_tb();`
`dumpfile(output/waveform_transformer_tb.vcd);`
`dumpvars(transformer_tb);`
```bash
make clean && make && make wave TB=transformer_tb
// TB value: tb module name
```

```bash

# 编译所有 testbench
make 或 make build

# 编译tb, 并使用vvp生成vcd，用gtkwave打开vcd文件查看波形。
make wave TB=ins_fetch_tb 

# 清理输出
make clean

```

注意，在testbench中，我们要用`dumpvars`系统命令为vcd文件填充变量数据。而且本项目对tbfile存放位置的要求：放到output文件夹中。
因此：  
`dumpfile`命令：需要加上前缀:waveform_。 并放到output文件夹。
如`top_tb.v`文件的测试模块`top_tb`:  `dumpfile(output/waveform_top_tb.v)`

