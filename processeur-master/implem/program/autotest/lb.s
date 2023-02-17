# TAG = lb
	.text
	lui x30, 0x000fa
	srli x30, x30, 12	# 0x000000fa

	lui x29, 0x00001
	sb x30, 0(x29)
	lb x31, 0(x29)	

	# max_cycle 50
	# pout_start
	# 000000fa
	# pout_end
