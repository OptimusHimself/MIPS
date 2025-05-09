module top (
    input clk, rst_im, rst_pc, rst_regFile, rst_dm
    output [31:0] alu_out

);
    // insfetch,  control, regFile, datamem, alu
    
    wire [31:0] im_out_ins;
    wire [15:0] imm16;
    wire [25:0] imm26;
    wire [5:0] shamt;
    wire npc_sel;
    wire alu_zero;
    wire isJump;
    wire ctrl_dataMem2reg, ctrl_dataMem_Write, ctrl_regFile_write;
    wire dm_write_data;
    wire [31:0] dm_addr;
    wire [4:0] rAddr_dest_rtype, rAddr_source, rAddr_anotherSource_dest;
    wire [1:0] [1:0] select_aluPerformance;
    wire select_anotherAluSource;
    wire select_regWritten;
    // wire [31:0] alu_out;
    wire [31:0] aluSource1, [31:0] aluSource2;
    
    InsFetch_n32 insfetch_unit (
        .clk(clk),
        .rst_im(rst_im),
        .rst_pc(rst_pc),
        .npc_sel(npc_sel), //
        .isJump(isJump),
        .alu_zero(alu_zero),
        .npc_in_imm16(imm16),//
        .npc_in_imm26(imm26), //
        .im_out_ins(im_out_ins) //
    );

    
    controler controler_unit(
        .instruction(im_out_ins),
        // output:
        .npc_sel(npc_sel),
        .isJump(isJump),
        .rAddr_dest_rtype(rAddr_dest_rtype),
        .rAddr_source(rAddr_source),
        .rAddr_anotherSource_dest(rAddr_anotherSource_dest),
        .npc_sel(npc_sel),
        .select_regWritten(select_regWritten),
        .imm16(imm16),
        .imm26(imm26),
        .shamt(shamt),
        .select_anotherAluSource(select_anotherAluSource),
        .ctrl_regFile_write(ctrl_regFile_write),
        .ctrl_dataMem_Write(ctrl_dataMem_Write),
        .ctrl_dataMem2reg(ctrl_dataMem2reg),
        .select_aluPerformance(select_aluPerformance)
    );

    regFile regFile_unit(
        .clk(clk),.rst_regFile(rst_regFile),
        .rAddr_dest_rtype(rAddr_dest_rtype), 
        .rAddr_source(rAddr_source), 
        .rAddr_anotherSource_dest(rAddr_anotherSource_dest),
        .ctrl_regFile_write(ctrl_regFile_write),
        .select_regWritten(select_regWritten),
        .alu_out(alu_out),
        // output
        .regA(aluSource1),
        .regB(aluSource2),

    );

    dataMemory dataMemory_unit(
        .clk(clk),
        .rst_dm(rst_dm),
        .dm_addr(dm_addr),
        .dm_write_data(dm_write_data),
        .ctrl_dataMem_Write(ctrl_dataMem_Write),
        .ctrl_dataMem2reg(ctrl_dataMem2reg),
        .dm_read_data(aluSource2)
    );

    alu_core alu_unit(
        .select_aluPerformance(select_aluPerformance),
        .select_anotherAluSource(select_anotherAluSource),
        .aluSource1(aluSource1),
        .aluSource2(aluSource2),
        .imm16(imm16),
        .alu_out(alu_out),
        .alu_zero(alu_zero)

    );


    



endmodule