# TAG = sh
	.text
	lui x30, 0x0fffa
	srli x30, x30, 12	# 0x0000fffa
	
	lui x29, 0x00001
	sh x30, 0(x29)
	lh x31, 0(x29)	

	# max_cycle 50
	# pout_start
	# 0000fffa
	# pout_end
