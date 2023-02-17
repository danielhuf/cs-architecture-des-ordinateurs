# TAG = sll
	.text

	lui x30, 0xfffff       
	srli x30, x30, 12 		# 0x000fffff

	lui x29, 0x00004
	srli x29, x29, 12
	sll x31, x30, x29		# 0x00fffff0


	lui x29, 0x00008
	srli x29, x29, 12
	sll x31, x30, x29		# 0x0fffff00

	# max_cycle 50
	# pout_start
	# 00fffff0
	# 0fffff00
	# pout_end
