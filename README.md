# 使用make


tb dumpfile命令：需要加上前缀：waveform_。 对tbfile的要求：放到output文件夹中。


```bash

# 编译所有 testbench
make


# 编译tb, 并使用vvp生成vcd，用gtkwave打开vcd文件查看波形。
make wave TB=ins_fetch_tb

# 清理输出
make clean

```