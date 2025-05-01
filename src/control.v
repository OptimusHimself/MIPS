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
    
    output select_anotherAluSource // alu another source select siganl 
    output select_aluPerformance, // 控制alu的行为
    output isJump,  // 让alu做拓展：26->32

    // npc, jump..., beq
    output ctrl_regWrite, select_regWritten

 
);

    wire [5:0] funct = instruction[5:0];
    
    assign opcode = instruction[31:26];
    assign rAddr_source = instruction[25:21];
    assign rAddr_anotherSource_dest = instruction[20:16];
    assign rAddr_dest_rtype = instruction[15:11],
    assign imm16 = instruction[15:0];
    assign imm26 = instruction[25:0];
    assign shmnt = instruction[10:6]; // 形同虚设

// 对一些控制信号初始化
    assign isJump = 1'b0;
    assign npc_sel = 1'b0;
    assign 
    // conditions: -> rs rd rt
    /* 
    1. addu 
    2. subu
    3. lw
    4. sw
    5. beq
    6. jp
    7. lui/lhi
    8. ori 

    */
    // R FORMAT INSTRUCTION
    if (opcode == 6'b0 && funct == 6'b100000) begin
        select_anotherAluSource = 1'b0;
        assign select_aluPerformance = 2'b00 ; // alu addition  // 要不要写assign?, 如果前面assign 过了，之后还能不能用assign赋值？
        assign ctrl_regWrite = 1'b1 ; // enable to write the regFile
    end
    else if (opcode == 6'b0 && funct == 6'b100000) begin
        assign select_aluPerformance = 2'b10; // alu subtraction
        assign ctrl_regWrite = 1'b1
    end
    // jump
    else if (opcode == 6'b00010) begin
        assign isJump = 1'b1; 
    end
    // beq 
    else if (opcode == 6'b000100) begin
        npc_sel = 1'b1;
        select_aluPerformance = 2'b10; 

    end

    // lw   sw
    else if (opcode == 6'b100011) begin
        select_aluPerformance = 2'b00;
        select_anotherAluSource = 

    end
    else if (opcode == 6'b101011) begin
        select_aluPerformance = 2'b00; // alu做加法，可以加负数。
    end



endmodule



module regFile(
    input clk,
    input [4:0] rAddr_dest_rtype, rAddr_source, rAddr_anotherSource_dest,
    input ctrl_regWrite,     //  high effective
    input select_regWritten, // 选择被写的寄存器的地址来源：R-Format的rd 还是 I-Format的rt
    input [31:0] alu_out, // addu, subu,把计算结果回写regFile

    output [31:0] regA, regB
 );

    assign regA = regFile_[rAddr_source];

    reg [31:0] regFile_32 [7:0] ;  // 寄存器组 32个reg
    always (@posedge clk) begin

        // R-type alu结果写入寄存器组 , 用rAddr_dest_rtype的地址
        if (ctrl_regWrite == 1 && select_regWritten == 1  ) begin
            regFile_[rAddr_dest_rtype] = alu_out;
            regB = regFile_[rAddr_anotherSource_dest]; 
        end 
        // I type lui, ori 结果写入寄存器组 , 用地址rAddr_anotherSource_dest
        if (ctrl_regWrite == 1 && select_regWritten ==  0 ) begin
            regFile_[rAddr_anotherSource_dest] = alu_out;
           // regB
        end
        if ()

    end

   

endmodule












