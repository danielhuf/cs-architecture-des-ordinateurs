# TAG = bne
	.text
	lui x30, 0x00f0f
	lui x29, 0xf0f0f
	bne x30, x29, not_equal
	lui x31, 0x00001
		
	not_equal:
	lui x31, 0xfffff
	

	# max_cycle 50
	# pout_start
	# fffff000
	# pout_end
