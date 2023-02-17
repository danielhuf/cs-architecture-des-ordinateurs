# TAG = bge
	.text
	lui x30, 0x0ff0f
	lui x29, 0xf0f0f
	bge x30, x29, higher
	lui x31, 0x00001
		
	higher:
	lui x31, 0xfffff
	

	# max_cycle 50
	# pout_start
	# fffff000
	# pout_end
