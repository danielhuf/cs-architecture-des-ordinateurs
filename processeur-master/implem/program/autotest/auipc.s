# TAG = auipc
	.text
	auipc x29, 0		# pc
	auipc x30, 4		# pc + 0x00004004 (x30 <- pc + 4 + (4<<12))
	sub x31, x30 ,x29	# 0x00004004
	
	# max_cycle 50
	# pout_start
	# 00004004
	# pout_end
