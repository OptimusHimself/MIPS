module alu_core (
    input select_aluPerformance,  // 加减运算 / 逻辑运算
    input select_anotherAluSource, // oprand2 来自 rAnother 还是 immediate
    input [31:0] aluSource1, aluSource2,

    output alu_zero, // beq命令，alu作差，如果为零，alu_zero===1

);
    
endmodule


module dataMemory(

);

endmodule