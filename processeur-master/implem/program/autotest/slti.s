# TAG = slti
	.text
	lui x30, 0x0ffff 
	lui x29, 0xf0f0f
	slti x31, x29, 0x1f 
	slti x31, x30, 0xff

	# max_cycle 50
	# pout_start
	# 00000001
	# 00000000
	# pout_end

