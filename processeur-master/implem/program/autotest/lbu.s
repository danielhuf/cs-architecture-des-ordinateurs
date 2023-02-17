# TAG = lbu
	.text
	lui x30, 0x0007a
	srli x30, x30, 12	# 0x0000007a

	lui x29, 0x00001
	sb x30, 0(x29)
	lbu x31, 0(x29)	

	# max_cycle 50
	# pout_start
	# 0000007a
	# pout_end
