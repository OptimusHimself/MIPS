ori $2, $0, 0xabab
ori $4, $0, 0xcdcd
addu $5,$2,$4
subu $6,$5,$2
sw $6,0($0)
lw $7,0($0)
addu $8, $7, $6
addu $8, $2, $8
subu $9, $8, $7
addu $10,$6,$2
lop:
beq $9,$10,f1
lw $12, 0($10)
cont:beq $11, $12,f2 		
ori $13, $0,0xdddd		
j f3
f1:
lui $0,0xcccc
ori $10, $0,0xc
sw $10, 0($10)
lw $11, 0($10)	
j lop
f2:
lui $11,0xffee
j cont
f3:
lui $14,0xefef
