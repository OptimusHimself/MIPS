// alu testbench :
// make clean && make && make wave TB=alu_tb

module alu_tb;

    // initialize the drivers. 
    reg [1:0] select_aluPerformance;
    reg select_anotherAluSource;
    reg [31:0] aluSource1;
    reg [31:0] aluSource2;
    reg [15:0] imm16;
    wire [31:0] alu_out;
    wire alu_zero;
     
    alu alu_uut(
        .select_aluPerformance(select_aluPerformance),
        .select_anotherAluSource(select_anotherAluSource),
        .aluSource1(aluSource1),
        .aluSource2(aluSource2),
        .imm16(imm16),
        .alu_out(alu_out),
        .alu_zero(alu_zero)
    );
    // test: alusource, aluperformance
    // subu performance.
    initial begin
        #5
        select_aluPerformance = 2'b01;
        select_anotherAluSource = 1;
        aluSource1 = 32'b0;
        imm16 = 16'h93;

        #5 // 减法
        aluSource2 = 32'h00ae;
        aluSource1 = 32'h0093;
        select_aluPerformance = 2'b10;
        select_anotherAluSource = 0;

        #5 // beq
        $finish;


    end

    // generate waveform
    initial begin
        $dumpfile("output/waveform_alu_tb.vcd");
        $dumpvars(2,alu_tb);
    end

endmodule 