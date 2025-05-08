//  test bench for PC
//  make clean && make && make wave TB=pc_tb
`timescale 1ns/1ps

module pc_tb();

    reg [31:0] npc_out_addr ;
    reg clk;
    reg rst_pc;
    wire [9:0] pc_out;

    PC pc_uut(
        .npc_out_addr(npc_out_addr),
        .clk(clk),
        .rst_pc(rst_pc),
        .pc_out(pc_out)
    );

    always #5 clk = ~clk;

    initial begin
        #0 clk = 0;
        #4.9 npc_out_addr = 32'h00003004;
        // #10 npc_out_addr = 32'h00003000;
        #10 npc_out_addr = 32'h00003004;
        #10 npc_out_addr = 32'h00003008;
        #10 npc_out_addr = npc_out_addr + 4;
        #10 npc_out_addr = npc_out_addr + 4;
        #10 npc_out_addr = npc_out_addr + 4;
        #10 npc_out_addr = npc_out_addr + 4;
        #10 npc_out_addr = npc_out_addr + 4;
        #10 npc_out_addr = npc_out_addr + 4;
        #10 npc_out_addr = npc_out_addr + 4;
        #10 npc_out_addr = npc_out_addr + 4;
        
        #10 $finish;

    end

    // waveform generate
    initial begin
        $dumpfile("output/waveform_pc_tb.vcd");
        $dumpvars(2,pc_tb);
    end

endmodule

// timescale的锅，1ns/1ps是有道理的！