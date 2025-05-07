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
    
    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        npc_sel = 0;
        alu_zero = 0;
        isJump = 0;
        npc_in_imm16 = 16'h0000;
        npc_in_imm26 = 26'h0000000;
        
        // Apply reset
        rst_im = 1;
        rst_pc = 1;
        #20;
        rst_im = 0;
        rst_pc = 0;
        #10;
        
        // Test 1: Sequential instruction fetch (PC+4)
        $display("Test 1: Sequential instruction fetch");
        repeat(5) begin
            @(posedge clk);
            #1; // Wait for signals to stabilize
            $display("Time: %0t", $time);
            $display("Instruction: 0x%08x", im_out_ins);
            $display("Control Signals - npc_sel: %0d, alu_zero: %0d, isJump: %0d", npc_sel, alu_zero, isJump);
            $display("Immediate values - imm16: 0x%04x, imm26: 0x%07x", npc_in_imm16, npc_in_imm26);
            $display("-----------------------------------------");
        end
        
        // Test 2: Branch instruction (when branch condition is true)
        $display("Test 2: Branch instruction (taken)");
        npc_sel = 1;
        alu_zero = 1;
        npc_in_imm16 = 16'h0004; // Branch to current PC + 4 + (4 << 2)
        @(posedge clk);
        #1;
        $display("Time: %0t", $time);
        $display("Instruction: 0x%08x", im_out_ins);
        $display("Control Signals - npc_sel: %0d, alu_zero: %0d, isJump: %0d", npc_sel, alu_zero, isJump);
        $display("Immediate values - imm16: 0x%04x, imm26: 0x%07x", npc_in_imm16, npc_in_imm26);
        $display("-----------------------------------------");
        
        // Return to normal execution
        npc_sel = 0;
        alu_zero = 0;
        @(posedge clk);
        #1;
        $display("Time: %0t", $time);
        $display("Instruction: 0x%08x", im_out_ins);
        $display("Control Signals - npc_sel: %0d, alu_zero: %0d, isJump: %0d", npc_sel, alu_zero, isJump);
        $display("Immediate values - imm16: 0x%04x, imm26: 0x%07x", npc_in_imm16, npc_in_imm26);
        $display("-----------------------------------------");
        
        // Test 3: Branch instruction (when branch condition is false)
        $display("Test 3: Branch instruction (not taken)");
        npc_sel = 1;
        alu_zero = 0;
        npc_in_imm16 = 16'h0004;
        @(posedge clk);
        #1;
        $display("Time: %0t", $time);
        $display("Instruction: 0x%08x", im_out_ins);
        $display("Control Signals - npc_sel: %0d, alu_zero: %0d, isJump: %0d", npc_sel, alu_zero, isJump);
        $display("Immediate values - imm16: 0x%04x, imm26: 0x%07x", npc_in_imm16, npc_in_imm26);
        $display("-----------------------------------------");
        
        // Test 4: Jump instruction
        $display("Test 4: Jump instruction");
        isJump = 1;
        npc_in_imm26 = 26'h0000010; // Jump to address 0x00003040
        @(posedge clk);
        #1;
        $display("Time: %0t", $time);
        $display("Instruction: 0x%08x", im_out_ins);
        $display("Control Signals - npc_sel: %0d, alu_zero: %0d, isJump: %0d", npc_sel, alu_zero, isJump);
        $display("Immediate values - imm16: 0x%04x, imm26: 0x%07x", npc_in_imm16, npc_in_imm26);
        $display("-----------------------------------------");
        
        // Return to normal execution
        isJump = 0;
        @(posedge clk);
        #1;
        $display("Time: %0t", $time);
        $display("Instruction: 0x%08x", im_out_ins);
        $display("Control Signals - npc_sel: %0d, alu_zero: %0d, isJump: %0d", npc_sel, alu_zero, isJump);
        $display("Immediate values - imm16: 0x%04x, imm26: 0x%07x", npc_in_imm16, npc_in_imm26);
        $display("-----------------------------------------");
        
        // Test 5: Test negative branch offset
        $display("Test 5: Negative branch offset");
        npc_sel = 1;
        alu_zero = 1;
        npc_in_imm16 = 16'hFFFE; // -2 (in two's complement), branch back 8 bytes
        @(posedge clk);
        #1;
        $display("Time: %0t", $time);
        $display("Instruction: 0x%08x", im_out_ins);
        $display("Control Signals - npc_sel: %0d, alu_zero: %0d, isJump: %0d", npc_sel, alu_zero, isJump);
        $display("Immediate values - imm16: 0x%04x, imm26: 0x%07x", npc_in_imm16, npc_in_imm26);
        $display("-----------------------------------------");
        
        // Finish simulation
        #10;
        $display("Simulation complete!");
        $finish;
    end

    // Optional: Waveform dump for viewing in a waveform viewer
    initial begin
        $dumpfile("output/waveform_ins_fetch_tb.vcd"); //很重要的一行代码！尤其是用gtkwave仿真
        $dumpvars(0, InsFetch_n32_tb);
    end
endmodule