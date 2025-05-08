// instruction fetch module
// NextPC's calculation updates PC. fetch instruction from InsMem, offer the instr out to Controler
// submodules: ProgramCounter, NextPCcalculator, InsMem

// control signals: npc_sel, zero

// InsMem size: 1KB, im_addr[9:0]
`timescale 1ns / 1ns


module InsFetch_n32 (
    input clk, rst_im, rst_pc,  // 时钟 & reset
    input npc_sel, // 控制NPC行为(跳转 or +4) 由controller给出 =0:default, =1 beq
    input alu_zero,  // 由alu_core给出
    input isJump,  //由controller给出
    input [15:0] npc_in_imm16,
    input [25:0] npc_in_imm26, // jump / beq
    output  [31:0] im_out_ins //  Output port expression must support continuous assignment.
);
     // 必须定义连接信号
    wire [9:0] pc_out;
    wire [9:0] im_out_addr;
    wire [31:0] npc_out_addr;

     InsMem_1kB im_unit(
        .pc_out(pc_out),
        .clk(clk),
        .rst_im(rst_im),
        .im_out_ins(im_out_ins), //
        .im_out_addr(im_out_addr) //
    );

     NextPCcalculator npc_unit(
        .npc_in_imm16(npc_in_imm16),
        .npc_in_imm26(npc_in_imm26),
        .im_out_addr(im_out_addr),
        .npc_sel(npc_sel),
        .alu_zero(alu_zero),
        .isJump(isJump),
        .npc_out_addr(npc_out_addr)
    );

     PC pc_unit(
        .npc_out_addr(npc_out_addr),
        .clk(clk),
        .rst_pc(rst_pc),
        .pc_out(pc_out)
    );



endmodule

// im_out_addr 没有拓展也没加偏移量：0x0000_3000。 均由NPC完成
// npc_in_imm16, npc_in_imm26 t对应内置拓展器的行为不同
// npc输出： 32位被拓展后的指令。
module NextPCcalculator(
    input [15:0] npc_in_imm16,
    input [25:0] npc_in_imm26,
    input [9:0] im_out_addr,   // 来自PC模块的当前地址偏移
    input npc_sel, alu_zero, isJump, 
    output reg [31:0] npc_out_addr
);
    // 0000_3000 -> 0000hex 0011 0000 0000 0000
    // 当前PC的完整地址（字节地址）
    wire [31:0] pc_current = 32'h00003000 + {im_out_addr, 2'b00};  // 等价于 im_out_addr * 4

    // 立即数扩展单元
    wire [31:0] ext_imm16 =  {{14{npc_in_imm16[15]}}, npc_in_imm16, 2'b00}; // 符号扩展+左移2 (beq乘四)
    wire [31:0] ext_imm26 = {pc_current[31:28], npc_in_imm26, 2'b00};      // 直接拼接

    always @(*) begin
            // always顺序执行：
            // J-type指令优先级最高
        if (isJump) begin
            /* J指令计算规则：
            - 取当前PC的高4位（已包含0x3000特征）
            - 拼接26位立即数（实际使用25:0）
            - 左移2位（地址对齐） 均在ext_imm26完成*/
            npc_out_addr = ext_imm26;
        end
        // 条件分支次之
        else if (npc_sel && alu_zero) begin
            /* BEQ指令计算规则：
            - 16位立即数符号扩展
            - 左移2位（字地址转字节地址）
            - 加PC+4的基准地址 */
            npc_out_addr = pc_current + 32'h4 + ext_imm16;
        end 
        // not beq nor jump, +4
        else begin
            npc_out_addr = pc_current + 32'h4;  // 默认 +4 前进
        end
    end
    
endmodule


// initial value for PC: 0x0000_3000, 认为：前3000的地址是给datamem。
// PC输入：32位NPC计算出来的指令。如果要观察MARS的模拟结果，可以看NPC的计算结果，和PC的输入信号
// PC输出：10位地址指令。 用于在指令寄存器组取指令
module PC (
    input [31:0] npc_out_addr, // NextPC's  output
    input clk, rst_pc,    
    output reg [9:0] pc_out  // 寄存器组大小1KB ， 10 bit
);
    wire [31:0] byte_offset = npc_out_addr - 32'h00003000;  // 字节偏移
    wire [9:0] word_addr = byte_offset[11:2];              // 字地址（右移2位）
    wire [9:0] bounded_addr = word_addr % 11'h400;         // 越界保护，限制在0-1023, 可以没有

    always @(posedge clk or posedge rst_pc) begin
        if (rst_pc) begin
            // 初始化为0x3000对应字地址（0xC00）
            pc_out <= 10'b0; // 
        end 
        else begin
            
            /* NPC的左移：
                - 立即数的规范拓展。叫做“字偏移”。
                - MIPS的beq/j指令中的立即数表示字偏移，需要转换为字节地址（×4）
               PC模块的右移：
                - 字节地址转换为字地址。用于指令存储器寻址
                - 别忘了，MIPS指令是4字节。四字节对其 0 4 8 12 ......所以字节地址的最低两位要只能是00 
            */
            pc_out <= bounded_addr;  // 确保地址在0-1023范围
        end
    end
endmodule


// 指令存储器/寄存器组
// 输入：10'b addr 
// 输出：
//  - 32位的指令，之后给controller
//  - 当前的address, 给到NPC.
module InsMem_1kB (
    input [9:0] pc_out,       // 字地址输入（已对齐）
    input clk,                // 主时钟
    input rst_im,             // 存储器复位
    output reg [31:0] im_out_ins, // 32位指令输出
    output reg [9:0] im_out_addr // 当前地址输出
);
    // 存储器定义（endian：small）
    reg [7:0] regArr_im [0:1023]; // 1024字节 = 256条指令

    // 地址计算辅助信号 --- 很重要
    // wire [10:0] byte_address = {pc_out, 2'b00}; // 转换为字节地址 ？？

    always @(posedge clk or posedge rst_im) begin
        if (rst_im) begin
            // 复位逻辑
            im_out_ins <= 32'h00000000;
            im_out_addr <= 10'h000;
            // 存储器清零（可选）
            // for (integer i=0; i<1024; i=i+1) regArr_im[i] <= 8'h00;
        end else begin
            // 输出当前地址（用于NPC计算）
            im_out_addr <= pc_out;

            // 大端序读取（按MIPS规范） --- 人类友好
            im_out_ins <= {regArr_im[pc_out],   // 最高有效字节
                          regArr_im[pc_out+1],
                          regArr_im[pc_out+2],
                          regArr_im[pc_out+3]};
        end
    end

    // 存储器初始化（示例）
    initial begin
        # 0;
        // alu_zero = 0; // cannot initialize input output wire.
        $readmemh("code.txt", regArr_im); // 从文件加载指令
    end




endmodule