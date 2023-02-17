# TAG = slt
	.text
	lui x30, 0x0ffff 
	lui x29, 0xf0f0f
	slt x31, x29, x30
	slt x31, x30, x29

	# max_cycle 50
	# pout_start
	# 00000001
	# 00000000
	# pout_end

