`timescale 1ns / 1ps

module InsFetch_n32_tb;
    // Testbench signals
    reg clk;
    reg rst_im, rst_pc;
    reg npc_sel, alu_zero, isJump;
    reg [15:0] npc_in_imm16;
    reg [25:0] npc_in_imm26;
    wire [31:0] im_out_ins;
    
   
    // DUT instantiation
    InsFetch_n32 dut (
        .clk(clk),
        .rst_im(rst_im),
        .rst_pc(rst_pc),
        .npc_sel(npc_sel),
        .alu_zero(alu_zero),
        .isJump(isJump),
        .npc_in_imm16(npc_in_imm16),
        .npc_in_imm26(npc_in_imm26),
        .im_out_ins(im_out_ins)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    // integer i ;
    
    initial begin
        clk = 0;
        $display(">>> Dumping contents of regArr_im:");
        
        // for ( i = 0; i < 1024; i = i + 1) begin">>> Dumping contents of regArr_im:");
        
        //     $display("regArr_im[%0d] = %02h", i, regArr_im[i]);
        // end
        # 300
        $finish;
    end

    // Optional: Waveform dump for viewing in a waveform viewer
    initial begin
        $dumpfile("output/waveform_ins_fetch_tb.vcd"); //很重要的一行代码！尤其是用gtkwave仿真
        $dumpvars(3, InsFetch_n32_tb);
    end
endmodule