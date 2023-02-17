# TAG = and
	.text

	lui x31, 0xfffff       #fffff000
	lui x30, 0x0f0f0       #0f0f0000
	and x31, x31, x30      #0f0f0000

	# max_cycle 50
	# pout_start
	# FFFFF000
	# 0f0f0000
	# pout_end
