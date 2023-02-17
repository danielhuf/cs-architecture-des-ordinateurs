# TAG = bgeu
	.text
	lui x30, 0xfff0f
	lui x29, 0x00f0f
	bgeu x30, x29, higher
	lui x31, 0x00001
		
	higher:
	lui x31, 0xfffff
	

	# max_cycle 50
	# pout_start
	# fffff000
	# pout_end
