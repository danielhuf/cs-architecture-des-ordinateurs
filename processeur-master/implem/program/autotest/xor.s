# TAG = xor
	.text

	addi x31, x0, 0x0f0 	#000011111111
	addi x30, x0, 0x00f 	#000011111111
	xor x31, x31, x30    #000010011001

	# max_cycle 50
	# pout_start
	# 000000f0
	# 000000ff
	# pout_end
