// // write the damm top_tb in iverilog.... 

// // that't is a lot of work, dude...
// `timescale 1ns/1ps

// module top_tb;


//     // initialize the driver signalsssss
//     wire [31:0] im_out_ins;
//     wire [15:0] imm16;
//     wire [25:0] imm26;
//     wire [5:0] shamt;
//     wire npc_sel;
//     wire alu_zero; //要用来给infetch初始化。但同时又是control的输出... shouldn't be reg
//     wire isJump; // output from control
//     wire ctrl_dataMem2reg, ctrl_dataMem_Write, ctrl_regFile_write;
//     // reg [31:0] dm_write_data;  // 来自regFile  regB
//     // reg [31:0] dm_addr; //来自alu_out
//     wire [4:0] rAddr_dest_rtype;
//     wire [4:0] rAddr_source;
//     wire [4:0] rAddr_anotherSource_dest;
//     wire [1:0] select_aluPerformance;
//     wire select_anotherAluSource;
//     wire select_regWritten;
//     wire [31:0] aluSource1;
//     wire [31:0] aluSource2;

//     reg clk;
//     reg rst_im, rst_pc, rst_regFile;

//     wire [31:0] alu_out;

//     insfetch insfetch_unit (
//         .clk(clk),
//         .rst_im(rst_im),
//         .rst_pc(rst_pc),
//         .npc_sel(npc_sel), //
//         .isJump(isJump),
//         .alu_zero(alu_zero),
//         .npc_in_imm16(imm16),//
//         .npc_in_imm26(imm26), //
//         .im_out_ins(im_out_ins) //
//     );

    
//     controler controler_unit(
//         .instruction(im_out_ins),
//         // output:
//         .npc_sel(npc_sel),
//         .isJump(isJump),
//         .rAddr_dest_rtype(rAddr_dest_rtype),
//         .rAddr_source(rAddr_source),
//         .rAddr_anotherSource_dest(rAddr_anotherSource_dest),
//         .select_regWritten(select_regWritten),
//         .imm16(imm16),
//         .imm26(imm26),
//         .shamt(shamt),
//         .select_anotherAluSource(select_anotherAluSource),
//         .ctrl_regFile_write(ctrl_regFile_write),
//         .ctrl_dataMem_Write(ctrl_dataMem_Write),
//         .ctrl_dataMem2reg(ctrl_dataMem2reg),
//         .select_aluPerformance(select_aluPerformance)
//     );

//     regFile regFile_unit(
//         .clk(clk),.rst_regFile(rst_regFile),
//         .rAddr_dest_rtype(rAddr_dest_rtype), 
//         .rAddr_source(rAddr_source), 
//         .rAddr_anotherSource_dest(rAddr_anotherSource_dest),
//         .ctrl_regFile_write(ctrl_regFile_write),
//         .select_regWritten(select_regWritten),
//         .alu_out(alu_out),
//         .regA(aluSource1),
//         .regB(aluSource2)

//     );

//     dataMemory dataMemory_unit(
//         .clk(clk),
//         .rst_dm(rst_dm),
//         .dm_addr(dm_addr),
//         .dm_write_data(dm_write_data),
//         .ctrl_dataMem_Write(ctrl_dataMem_Write),
//         .ctrl_dataMem2reg(ctrl_dataMem2reg),
//         .dm_read_data(aluSource2)
//     );

//     alu alu_unit(
//         .select_aluPerformance(select_aluPerformance),
//         .select_anotherAluSource(select_anotherAluSource),
//         .aluSource1(aluSource1),
//         .aluSource2(aluSource2),
//         .imm16(imm16),
//         .alu_out(alu_out),
//         .alu_zero(alu_zero)
    
//     );

//     always #5 clk = ~clk;

//     initial begin

//         // initialization all the control signals, address to zero!
//         // let's fuck do it!
//         reg [31:0] im_out_ins;
//         reg [15:0] imm16;
//         reg [25:0] imm26;
//         reg [5:0] shamt;
//         reg npc_sel;
//         reg alu_zero;
//         reg isJump;
//         reg ctrl_dataMem2reg, ctrl_dataMem_Write, ctrl_regFile_write;
//         reg [31:0] dm_write_data;
//         reg [31:0] dm_addr;
//         reg [4:0] rAddr_dest_rtype, rAddr_source, rAddr_anotherSource_dest;
//         reg [1:0] select_aluPerformance;
//         reg select_anotherAluSource;
//         reg select_regWritten;
//         reg [31:0] aluSource1;
//         reg [31:0] aluSource2;

//         reg clk;
//         reg rst_im, rst_pc, rst_regFile;

//     end


//         // generate waves
//         initial begin
//             $dumpfile("output/top_tb");
//             $dumpvars(3,alu_unit); 
//             $dumpvars(3,controler_unit); 
//             $dumpvars(3,insfetch_unit); 
//             $dumpvars(3,regFile_unit); 
//             $dumpvars(3,dataMemory_unit); 

//         end

// endmodule