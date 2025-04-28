`timescale 1ns / 1ps

//iverilog -o ins_fetch_tb InsFetch_n32.v InsFetch_n32_tb.v
//vvp ins_fetch_tb
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
    
    // Helper task for reset
    task reset_system;
        begin
            rst_im = 1;
            rst_pc = 1;
            #20;
            rst_im = 0;
            rst_pc = 0;
            #10;
        end
    endtask
    
    // Helper task for displaying instruction and control signals
    task display_state;
        begin
            $display("Time: %0t", $time);
            $display("Instruction: 0x%08x", im_out_ins);
            $display("Control Signals - npc_sel: %0d, alu_zero: %0d, isJump: %0d", npc_sel, alu_zero, isJump);
            $display("Immediate values - imm16: 0x%04x, imm26: 0x%07x", npc_in_imm16, npc_in_imm26);
            $display("-----------------------------------------");
        end
    endtask
    
    // Initialize memory with provided instructions
    initial begin
        // Initialize code.txt file with the provided bytes
        integer file, i;
        reg [7:0] memory_data [0:47]; // 48 bytes of instruction data
        
        // Populate memory data array with provided instructions
        memory_data[0] = 8'h34; memory_data[1] = 8'h03; memory_data[2] = 8'h00; memory_data[3] = 8'h93;
        memory_data[4] = 8'h34; memory_data[5] = 8'h06; memory_data[6] = 8'h00; memory_data[7] = 8'hae;
        memory_data[8] = 8'h00; memory_data[9] = 8'h66; memory_data[10] = 8'h40; memory_data[11] = 8'h21;
        memory_data[12] = 8'h00; memory_data[13] = 8'h66; memory_data[14] = 8'h48; memory_data[15] = 8'h23;
        memory_data[16] = 8'h01; memory_data[17] = 8'h2a; memory_data[18] = 8'h00; memory_data[19] = 8'h21;
        memory_data[20] = 8'hac; memory_data[21] = 8'h09; memory_data[22] = 8'h00; memory_data[23] = 8'h10;
        memory_data[24] = 8'h8c; memory_data[25] = 8'h0a; memory_data[26] = 8'h00; memory_data[27] = 8'h10;
        memory_data[28] = 8'h11; memory_data[29] = 8'h2a; memory_data[30] = 8'h00; memory_data[31] = 8'h02;
        memory_data[32] = 8'h3c; memory_data[33] = 8'h0b; memory_data[34] = 8'hcd; memory_data[35] = 8'hcd;
        memory_data[36] = 8'h08; memory_data[37] = 8'h00; memory_data[38] = 8'h0c; memory_data[39] = 8'h0d;
        memory_data[40] = 8'h34; memory_data[41] = 8'h0b; memory_data[42] = 8'hef; memory_data[43] = 8'hef;
        memory_data[44] = 8'h3c; memory_data[45] = 8'h09; memory_data[46] = 8'h45; memory_data[47] = 8'h67;
        
        // Write memory data to a file
        file = $fopen("code.txt", "w");
        for (i = 0; i < 48; i = i + 4) begin
            $fwrite(file, "%02x%02x%02x%02x\n", 
                memory_data[i], memory_data[i+1], memory_data[i+2], memory_data[i+3]);
        end
        $fclose(file);
    end
    
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
        reset_system();
        
        // Test 1: Sequential instruction fetch (PC+4)
        $display("Test 1: Sequential instruction fetch");
        repeat(5) begin
            @(posedge clk);
            #1; // Wait for signals to stabilize
            display_state();
        end
        
        // Test 2: Branch instruction (when branch condition is true)
        $display("Test 2: Branch instruction (taken)");
        npc_sel = 1;
        alu_zero = 1;
        npc_in_imm16 = 16'h0004; // Branch to current PC + 4 + (4 << 2)
        @(posedge clk);
        #1;
        display_state();
        
        // Return to normal execution
        npc_sel = 0;
        alu_zero = 0;
        @(posedge clk);
        #1;
        display_state();
        
        // Test 3: Branch instruction (when branch condition is false)
        $display("Test 3: Branch instruction (not taken)");
        npc_sel = 1;
        alu_zero = 0;
        npc_in_imm16 = 16'h0004;
        @(posedge clk);
        #1;
        display_state();
        
        // Test 4: Jump instruction
        $display("Test 4: Jump instruction");
        isJump = 1;
        npc_in_imm26 = 26'h0000010; // Jump to address 0x00003040
        @(posedge clk);
        #1;
        display_state();
        
        // Return to normal execution
        isJump = 0;
        @(posedge clk);
        #1;
        display_state();
        
        // Test 5: Test negative branch offset
        $display("Test 5: Negative branch offset");
        npc_sel = 1;
        alu_zero = 1;
        npc_in_imm16 = 16'hFFFE; // -2 (in two's complement), branch back 8 bytes
        @(posedge clk);
        #1;
        display_state();
        
        // Finish simulation
        #10;
        $display("Simulation complete!");
        $finish;
    end

    // Optional: Waveform dump for viewing in a waveform viewer
    initial begin
        $dumpfile("ins_fetch_tb.vcd");
        $dumpvars(0, InsFetch_n32_tb);
    end
endmodule