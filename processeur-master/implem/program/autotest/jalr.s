# TAG = jalr
	.text
	jal x30, jump			# x30 = pc + 4
	lui x28, 0x00008		# pc + 8
	jal x30, end_jump
	
	jump:
	add x29, x30, x0		# x29 = pc + 12
	jalr x30, 0(x30)		
	
	end_jump:
	sub x31, x30, x29		# x31 = x30 - x29 = 0x00000008

	# max_cycle 50
	# pout_start
	# 00000008
	# pout_end
