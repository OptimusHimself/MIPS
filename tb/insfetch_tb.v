// 其实没啥检查的必要了。。因为没有控制信号。
// 如果要让系统活起来。insfetch在rst后要把第一条命令给到control.
// make clean && make build && make wave TB=insfetch_tb

`timescale 1ns / 1ps

module insfetch_tb;
    // Testbench signals
    reg clk;
    reg rst;
    reg npc_sel, alu_zero, isJump;
    reg [15:0] npc_in_imm16;
    reg [25:0] npc_in_imm26;
    wire [31:0] im_out_ins;

   
    // DUT instantiation
    insfetch insfetch_uut (
        .clk(clk),
        .rst(rst),
        .npc_sel(npc_sel),
        .alu_zero(alu_zero),
        .isJump(isJump),
        .npc_in_imm16(npc_in_imm16),
        .npc_in_imm26(npc_in_imm26),
        .im_out_ins(im_out_ins)
    );
    
    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        // alu_zero = 0;
        // isJump = 0;  // 只要是controld的输出，都不set
        // npc_sel = 0;
        rst = 1;
        // npc_in_imm16 = 16'b0;
        // npc_in_imm26 = 26'b0;
        // im_out_ins = 0;
        // $display(">>> Dumping contents of regArr_im:"); //我们从不看终端！

        #5 rst = 0;


        #10  rst = 1;

        #5 rst = 0;


        // #5 npc_in_imm16 = 16'h4;
        // npc_in_imm26 = 26'h8;

        
       
        # 300
        $finish;
    end

    // Optional: Waveform dump for viewing in a waveform viewer
    initial begin
        $dumpfile("output/waveform_insfetch_tb.vcd"); //很重要的一行代码！尤其是用gtkwave仿真
        $dumpvars(4, insfetch_tb);
    end
endmodule

/* which make me satisfied is that we can see instruction as outputs!
however, the time didn't match. each clock will turn to a new instruction. but now, 2 clock cycle, one instruction.
and is not because of timescale this time......damn.

*/