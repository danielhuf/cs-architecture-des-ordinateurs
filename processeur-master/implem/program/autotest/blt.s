# TAG = blt
	.text
	lui x30, 0xf0f0f
	lui x29, 0x0ff0f
	blt x30, x29, lower
	lui x31, 0x00001
		
	lower:
	lui x31, 0xfffff
	

	# max_cycle 50
	# pout_start
	# fffff000
	# pout_end
