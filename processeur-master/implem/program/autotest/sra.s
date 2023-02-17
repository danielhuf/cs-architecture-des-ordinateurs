# TAG = sra
	.text

	lui x30, 0xfffff       

	lui x29, 0x00004
	srli x29, x29, 12
	sra x31, x30, x29		# 0xffffff00

	lui x29, 0x00007
	srli x29, x29, 12
	sra x31, x30, x29		# 0xffffffe0

	# max_cycle 50
	# pout_start
	# ffffff00
	# ffffffe0
	# pout_end
