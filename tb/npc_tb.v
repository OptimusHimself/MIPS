// test npc calculation scheme
// 测试三种情况下jump, beq , +4，npc_out_address是否符合预期

// make clean && make && make wave TB=npc_tb
`timescale 1ns/1ps;

module npc_tb;

    // declaration drivers
    reg [15:0] npc_in_imm16;
    reg [25:0] npc_in_imm26;
    reg [9:0] im_out_addr;
    reg npc_sel;
    reg alu_zero;
    reg isJump;
    wire [31:0] npc_out_addr;

    // initialize uut
    NextPCcalculator npc_uut(
        .npc_in_imm16(npc_in_imm16),
        .npc_in_imm26(npc_in_imm26),
        .im_out_addr(im_out_addr),
        .npc_sel(npc_sel),
        .alu_zero(alu_zero),
        .isJump(isJump),
        .npc_out_addr(npc_out_addr)
    );

    // comb logic
    initial begin
        // test normal case, check extender
        im_out_addr = 10'b0;
        npc_sel = 0;
        alu_zero = 0;
        npc_in_imm16 = 16'b0;
        npc_in_imm26 = 26'b0;
        isJump = 0;

        #5 npc_in_imm16 = 16'h24;

        #10 npc_in_imm26 = 26'h2;
        
        // test beq, expect: npc_out_addr = 
        npc_sel = 1;
        alu_zero = 1;

        // #5 im_out_addr = im_out_addr + ext_imm16;
        #5 npc_sel = 0; // back to normal. npc_out_addr += 4

        // jump
        
        #5 isJump = 1;
        // im_out_addr = im_out_addr + 

        #5 isJump = 0;

        #10 $finish;

    
    
    end

    

    // generate waveform data 
    initial begin
        $dumpfile("output/waveform_npc_tb");
        $dumpvars(2,npc_tb);
    end

endmodule