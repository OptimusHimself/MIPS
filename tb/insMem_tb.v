// insmem读如指令是否正常。能否跟着信号读出命令。

// TODO： 测试NPC和PC的计算长度

// TODO： 再测试insfetch，查看npc pc和 insmem的连接。

`timescale 1ns / 1ns

module insMem_tb;

    reg [9:0] pc_out;
    reg clk;
    reg rst_im;
    wire [31:0] im_out_ins;
    wire [9:0] im_out_addr;
    
    InsMem_1kB insmem_unt(
        .pc_out(pc_out),
        .clk(clk),
        .rst_im(rst_im),
        .im_out_addr(im_out_addr),
        .im_out_ins(im_out_ins)
    );

    always #5 clk = ~clk;

    initial begin
        // 
        #0 clk = 0;
        rst_im = 1;
        
        #10 rst_im = 0;
        #5  pc_out = 10'b0;

        #10 pc_out = pc_out +4;
        #10 pc_out = pc_out +4;
        #10 pc_out = pc_out +4;
        #10 pc_out = pc_out +4;
        #10 pc_out = pc_out +4;
        #10 pc_out = pc_out +4;
        #10 pc_out = pc_out +4;
        #10 pc_out = pc_out +4;
        #10 pc_out = pc_out +4;
        #10 pc_out = pc_out +4;
        #10 pc_out = pc_out +4;
        #10 pc_out = pc_out +4;
        #10 pc_out = pc_out +4;
        #10 pc_out = pc_out +4;
        #10 pc_out = pc_out +4;


        #2 $finish;

    end

    // Waveform dump
    initial begin
        $dumpfile("output/waveform_insMem_tb.vcd");
        $dumpvars(1, insMem_tb);
    end

endmodule