`timescale 1ns / 1ps

module mips_single_cycle_tb;
    // Global signals
    reg clk;
    reg reset;
    
    // Top module instantiation
    wire [31:0] instruction;
    wire [31:0] alu_result;
    wire [31:0] memory_data;
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Module instantiation
    // You may need to adjust this based on your top module connections
    InsFetch_n32 ins_fetch (
        .clk(clk),
        .rst_im(reset),
        .rst_pc(reset),
        .npc_sel(npc_sel),
        .alu_zero(alu_zero),
        .isJump(isJump),
        .npc_in_imm16(imm16),
        .npc_in_imm26(imm26),
        .im_out_ins(instruction)
    );
    
    controler control_unit (
        .instruction(instruction),
        .rAddr_dest_rtype(rAddr_dest_rtype),
        .rAddr_source(rAddr_source),
        .rAddr_anotherSource_dest(rAddr_anotherSource_dest),
        .imm16(imm16),
        .imm26(imm26),
        .shamt(shamt),
        .select_anotherAluSource(select_anotherAluSource),
        .select_aluPerformance(select_aluPerformance),
        .isJump(isJump),
        .ctrl_dataMem2reg(ctrl_dataMem2reg),
        .npc_sel(npc_sel),
        .ctrl_regFile_write(ctrl_regFile_write),
        .select_regWritten(select_regWritten),
        .ctrl_dataMem_Write(ctrl_dataMem_Write)
    );
    
    regFile register_file (
        .clk(clk),
        .rst_regFile(reset),
        .rAddr_dest_rtype(rAddr_dest_rtype),
        .rAddr_source(rAddr_source),
        .rAddr_anotherSource_dest(rAddr_anotherSource_dest),
        .ctrl_regFile_write(ctrl_regFile_write),
        .select_regWritten(select_regWritten),
        .alu_out(write_data),  // This will be either from ALU or memory
        .regA(regA),
        .regB(regB)
    );
    
    alu_core alu (
        .select_aluPerformance(select_aluPerformance),
        .select_anotherAluSource(select_anotherAluSource),
        .aluSource1(regA),
        .aluSource2(regB),
        .imm16(imm16),
        .alu_out(alu_result),
        .alu_zero(alu_zero)
    );
    
    dataMemory data_mem (
        .clk(clk),
        .rst_dm(reset),
        .dm_addr(alu_result),
        .dm_write_data(regB),
        .ctrl_dataMem_Write(ctrl_dataMem_Write),
        .ctrl_dataMem_reg(ctrl_dataMem2reg),
        .dm_read_data(memory_data)
    );
    
    // Multiplexer for write data to register file
    wire [31:0] write_data = ctrl_dataMem2reg ? memory_data : alu_result;
    
    // Wire declarations for interconnections
    wire [4:0] rAddr_dest_rtype, rAddr_source, rAddr_anotherSource_dest;
    wire [15:0] imm16;
    wire [25:0] imm26;
    wire [5:0] shamt;
    wire [1:0] select_aluPerformance;
    wire select_anotherAluSource, isJump, ctrl_dataMem2reg, npc_sel;
    wire ctrl_regFile_write, select_regWritten, ctrl_dataMem_Write, alu_zero;
    wire [31:0] regA, regB;
    
    // Test procedure
    initial begin
        // Initialize
        clk = 0;
        reset = 1;
        
        // Apply reset
        #20;
        reset = 0;
        
        // Run simulation for several cycles
        #500;
        
        // End simulation
        $display("Simulation complete");
        $finish;
    end
    
    // Monitoring
    always @(posedge clk) begin
        if (!reset) begin
            $display("Time: %0t, PC: %0h", $time, ins_fetch.pc_unit.pc_out);
            $display("Instruction: %08h", instruction);
            $display("ALU inputs: A=%08h, B=%08h", regA, regB);
            $display("ALU result: %08h, Zero: %b", alu_result, alu_zero);
            $display("Control signals - RegWrite: %b, MemWrite: %b, MemToReg: %b", 
                     ctrl_regFile_write, ctrl_dataMem_Write, ctrl_dataMem2reg);
            $display("Jump: %b, Branch: %b", isJump, npc_sel & alu_zero);
            $display("----------------------------");
        end
    end
    
    // Optional: Dump waveforms
    initial begin
        $dumpfile("mips_single_cycle.vcd");
        $dumpvars(0, mips_single_cycle_tb);
    end
    
endmodule