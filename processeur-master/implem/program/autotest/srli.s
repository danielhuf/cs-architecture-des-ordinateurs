# TAG = srli
	.text

	lui x30, 0xfffff       

	srli x31, x30, 4		# 0x00fffff0

	srli x31, x30, 8		# 0x0fffff00

	# max_cycle 50
	# pout_start
	# 0fffff00
	# 00fffff0
	# pout_end
