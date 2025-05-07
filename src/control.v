// Decoder

// 输入指令，根据I-/R-/J-format输出（RegFile, ALU）控制信号和oprand
// https://student.cs.uwaterloo.ca/~isg/res/mips/opcodes
// r type: opcode + rSource + rAnother + rDest + shamt + funct = 6 5 5 5 5 6 
//    add: 100000             sub 100010
// j type: op + imm26   (opcode = 000010)
//
// i type: op + rs + rt + imm16
//   lw,    sw,     ori,    lui/lhi,    beq       
//   100011  101011  001101  011001     000100
module controler (

    input [31:0] instruction,  // ins_fetch output

    output [4:0] rAddr_dest_rtype, rAddr_source, rAddr_anotherSource_dest, // rSource: aluOprand   rAnother: aluOprandB rDest: alu_out
    output [15:0] imm16, 
    output [25:0] imm26,  
    output [5:0] shamt,
    
    output select_anotherAluSource, // alu another source select signal
    output [1:0] select_aluPerformance, // 控制alu的行为
    output isJump,  // 让alu做拓展：26->32
    output ctrl_dataMem2reg,
    output npc_sel,

    output ctrl_regFile_write, select_regWritten,
    output ctrl_dataMem_Write

 
);

    wire [5:0] funct = instruction[5:0];
    wire [5:0] opcode;
    
    assign opcode = instruction[31:26];
    assign rAddr_source = instruction[25:21];
    assign rAddr_anotherSource_dest = instruction[20:16];
    assign rAddr_dest_rtype = instruction[15:11];
    assign imm16 = instruction[15:0];
    assign imm26 = instruction[25:0];
    assign shamt = instruction[10:6]; // 形同虚设

    // xadd  isAdd 判断是否是哪个指令
    wire xadd = (opcode == 6'b000000) && (funct == 6'b100000);
    wire xsub = (opcode == 6'b000000) && (funct == 6'b100010);
    wire xbeq = (opcode == 6'b000100);
    wire xori = (opcode == 6'b001101);
    wire xlui = (opcode == 6'b011001);
    wire xlw = (opcode == 6'b100011);
    wire xsw = (opcode == 6'b101011);
    wire xjump = (opcode == 6'b000010);

    assign select_regWritten = (xadd | xsub) ? 1'b1 : 1'b0; // add sub vs ori lui
    assign npc_sel = xbeq; // beq <- npc_sel=1
    assign ctrl_regFile_write = (xadd | xsub | xori | xlui | xlw) ? 1'b1 : 1'b0; 
    assign isJump = xjump;  // jump
    assign ctrl_dataMem_Write = xsw;  // sw
    assign ctrl_dataMem2reg = xlw; // lw
    assign select_anotherAluSource = (xori | xlw | xsw | xlui) ? 1'b1 : 1'b0;
    assign select_aluPerformance = (xadd | xlw | xsw) ? 2'b00 
                                 : (xsub | xbeq) ? 2'b10 
                                 : (xori) ? 2'b01
                                 : (xlui) ? 2'b11 : 2'b00; // alu operations
    
endmodule


module regFile (
    input clk, rst_regFile,
    input [4:0] rAddr_dest_rtype, rAddr_source, rAddr_anotherSource_dest,
    input ctrl_regFile_write,     // 高电平写使能
    input select_regWritten,      // 1表示写rd，0表示写rt
    input [31:0] alu_out,         // alu计算结果

    output [31:0] regA,           // ALU operand A
    output reg [31:0] regB        // ALU operand B
);

    // 寄存器组，MIPS有32个通用寄存器
    reg [31:0] regFile_32 [31:0];

    // read port（组合逻辑，异步读取）
    assign regA = regFile_32[rAddr_source];

    // regB 可选择组合逻辑方式更新（也可以用 always）
    always @(*) begin
        regB = regFile_32[rAddr_anotherSource_dest];
    end

    // write port（同步写入）
    integer i;
    always @(posedge clk or posedge rst_regFile) begin  // 异步复位

        if (rst_regFile) begin
            for (i = 0; i < 32; i = i + 1)
                regFile_32[i] <= 0;
        end else begin
            if (ctrl_regFile_write) begin
                if (select_regWritten)
                    regFile_32[rAddr_dest_rtype] <= alu_out;           // R-type: 写 rd
                else
                    regFile_32[rAddr_anotherSource_dest] <= alu_out;   // I-type: 写 rt
            end
        end
    
    end

endmodule













