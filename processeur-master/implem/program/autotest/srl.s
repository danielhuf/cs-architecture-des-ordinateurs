# TAG = srl
	.text

	lui x30, 0xfffff     	# 0xfffff000  

	lui x29, 0x00004
	srli x29, x29, 12
	srl x31, x30, x29		# 0x0fffff00


	lui x29, 0x00008
	srli x29, x29, 12
	srl x31, x30, x29		# 0x00fffff0


	# max_cycle 50
	# pout_start
	# 0fffff00
	# 00fffff0
	# pout_end

