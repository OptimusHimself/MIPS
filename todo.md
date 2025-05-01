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
