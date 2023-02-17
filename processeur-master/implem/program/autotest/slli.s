# TAG = slli
	.text

	lui x30, 0xfffff       
	srli x30, x30, 12 		# 0x000fffff

	slli x31, x30, 4		# 0x00fffff0

	slli x31, x30, 8		# 0x0fffff00

	# max_cycle 50
	# pout_start
	# 00fffff0
	# 0fffff00
	# pout_end
