# TAG = lhu
	.text
	lui x30, 0x07ffa
	srli x30, x30, 12	# 0x0000fffa
	
	lui x29, 0x00001
	sb x30, 0(x29)
	lhu x31, 0(x29)	

	# max_cycle 50
	# pout_start
	# 00007ffa
	# pout_end
