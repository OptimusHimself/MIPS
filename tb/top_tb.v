`timescale 1ns / 1ns

module top_tb;
    // Testbench signals
    reg clk;
    reg rst, rst_regFile;
    wire [31:0] alu_out;

    // DUT instantiation
    top top_unt (
        .clk(clk),
        .rst(rst),
        .rst_regFile(rst_regFile),
        .alu_out(alu_out)
    );

    // top_unt.insfetch.npc_in_imm16 = 16'b0;
    //does iverilog supports hierarchical references.
  


    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Reset sequence
    initial begin
        rst = 1;
        rst_regFile = 1;
        // #10;
        rst = 0;
        rst_regFile = 0;
    end

    // Test sequence
    initial begin
        #500
        $finish;
    end

    // Waveform dump
    initial begin
        $dumpfile("output/waveform_top_tb.vcd");
        $dumpvars(4, top_tb);
    end
endmodule
