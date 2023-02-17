# TAG = sw
	.text
	lui x30, 0xfffff

	lui x29, 0x00001
	sw x30, 0(x29)
	lw x31, 0(x29)	

	# max_cycle 50
	# pout_start
	# fffff000
	# pout_end
