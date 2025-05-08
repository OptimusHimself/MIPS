module alu (
    input [1:0] select_aluPerformance,  // 00:加法, 10:减法, 01:ORI, 11:LUI
    input select_anotherAluSource, // 0:来自寄存器(rAnother), 1:来自立即数(immediate) OK
    input [31:0] aluSource1, // rs的值
    input [31:0] aluSource2, // rt的值或imm值
    input [15:0] imm16,      // 16位立即数，用来ori, lui
    
    output reg [31:0] alu_out, // ALU计算结果
    output alu_zero  // beq命令，alu作差，如果为零，alu_zero===1
);
    // 当select_anotherAluSource=1时，需要对立即数进行适当处理
    wire [31:0] immediate_zero_ext = {16'b0, imm16}; // ORI用零扩展
    wire [31:0] immediate_lui = {imm16, 16'b0}; // LUI用左移16位

    wire [15:0] sign_extend = {16{imm16[15]}};
    wire [31:0] immediate_sign_ext = {sign_extend, imm16};

    // 选择第二个操作数（寄存器值或立即数）lui操作第二个立即数的拓展规则和
    wire [31:0] operand2 = select_anotherAluSource ? 
                       ((select_aluPerformance == 2'b01) ? immediate_zero_ext : 
                        (select_aluPerformance == 2'b11) ? immediate_lui : 
                        immediate_sign_ext) :
                       aluSource2;

    
    // ALU计算逻辑. 
    always @(*) begin
        case (select_aluPerformance)
            2'b00: alu_out = aluSource1 + operand2;     // 加法(add/lw/sw) 注意：lw swm, alu out是地址。
            2'b10: alu_out = aluSource1 - operand2;     // 减法(sub/beq)
            2'b01: alu_out = aluSource1 | operand2;     // 或运算(ori)
            2'b11: alu_out = operand2;                  // LUI直接输出立即数
            // default: alu_out = 32'b0;
        endcase
    end
    
    // beq 指令的零标志
    assign alu_zero = (alu_out == 32'b0) ? 1'b1 : 1'b0; // 作差为0即相等
    
endmodule


module dataMemory(
    input clk,                     // 时钟信号
    input rst_dm,                  // 复位信号
    input [31:0] dm_addr,          // 内存地址（来自ALU计算结果）
    input [31:0] dm_write_data,    // 写入数据（来自寄存器组的regB）
    input ctrl_dataMem_Write,      // 写使能信号（高电平有效）
    input ctrl_dataMem2reg,        // 从内存读取数据使能（lw指令）
    
    output reg [31:0] dm_read_data // lw读出的数据
);
    // 定义数据存储器大小（1KB = 256个字）
    reg [31:0] dm_data [0:255];
    
    // 地址计算（去掉偏移）
    wire [7:0] word_addr = dm_addr[9:2];  // 取地址的[9:2]位作为字地址。 [1:0]必为0
    
    // 同步写入
    integer i;
    always @(posedge clk or posedge rst_dm) begin
        if (rst_dm) begin
            // 复位：清空内存
            for (i = 0; i < 256; i = i + 1)
                dm_data[i] <= 32'h0;
        end else if (ctrl_dataMem_Write) begin
            // 写入操作（sw指令）
            dm_data[word_addr] <= dm_write_data;
        end
    end
    
    // 读取操作（组合逻辑）
    always @(*) begin
        if (ctrl_dataMem2reg) begin
            // lw指令：读取内存
            dm_read_data = dm_data[word_addr];
        end else begin
            // 其他指令：传递ALU结果
            dm_read_data = dm_addr;
        end
    end
    
    // 初始化数据内存（可选）
    initial begin
        for (i = 0; i < 256; i = i + 1)
            dm_data[i] = 32'h0;
        // 可以在此处添加初始化数据
    end
    
endmodule