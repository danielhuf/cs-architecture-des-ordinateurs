# TAG = sltu
	.text
	lui x30, 0xf0fff 
	lui x29, 0x00f0f
	sltu x31, x29, x30
	sltu x31, x30, x29

	# max_cycle 50
	# pout_start
	# 00000001
	# 00000000
	# pout_end

