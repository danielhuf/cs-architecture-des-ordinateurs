# TAG = jal
	.text
	lui x28, 0x00008
	srli x28, x28, 12
	
	auipc x29, 0	
	add x29, x28, x29	# x29 <- pc(line6) + 8
	
	jal x30, jump       # x30 <- pc(line9) = pc(line6) + 4 + 4 = reg[x29]
	lui x31, 0xfffff
		
	jump:
	sub x31, x29, x30
	

	# max_cycle 50
	# pout_start
	# 00000000
	# pout_end
