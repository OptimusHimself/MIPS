ori $2, $0, 0xabab
ori $4, $0, 0xcdcd
nop
nop
nop
addu $5,$2,$4
nop
nop
nop
subu $6,$5,$4
nop
nop
nop
sw $6,0($0)
lw $7,0($0)
nop
nop
nop
addu $8, $7, $6
nop
nop
nop
addu $8, $2, $8
nop
nop
nop
subu $9, $8, $7
addu $10,$6,$2
nop
nop
nop
lop:
beq $9,$10,f1
nop
nop
nop		
lw $12, 0($10)
nop
nop
nop
cont:beq $11, $12, f2 
nop
nop
nop		
ori $13, $0, 0xdddd		
j f3
nop
nop
f1:
lui $0,0xcccc
nop
nop
nop
ori $10, $0, 0xc
nop
nop
nop
sw $10, 0($10)
lw $11, 0($10)	
j lop
nop
nop
f2:
lui $11,0xffee
j cont
nop
nop
f3:
lui $14,0xefef
