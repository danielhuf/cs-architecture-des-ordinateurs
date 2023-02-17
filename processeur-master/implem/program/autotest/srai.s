# TAG = srai
	.text

	lui x30, 0xfffff       
	srai x31, x30, 4		# 0xffffff00
	srai x31, x30, 7		# 0xffffffe0

	# max_cycle 50
	# pout_start
	# ffffff00
	# ffffffe0
	# pout_end
