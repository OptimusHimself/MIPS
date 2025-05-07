`timescale 1ps / 1ps

module top_tb;
    // Testbench signals
    reg clk;
    reg rst_im, rst_pc, rst_regFile;
    wire [31:0] alu_out;

    // DUT instantiation
    top top_unt (
        .clk(clk),
        .rst_im(rst_im),
        .rst_pc(rst_pc),
        .rst_regFile(rst_regFile),
        .alu_out(alu_out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Reset sequence
    initial begin
        // rst_im = 1;
        rst_pc = 1;
        rst_regFile = 1;
        #10;
        rst_im = 0;
        rst_pc = 0;
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
        $dumpvars(3, top_tb);
    end
endmodule
