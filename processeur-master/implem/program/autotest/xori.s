# TAG = xori
	.text

	addi x31, x0, 0x0ff 	#000011111111
	xori x31, x31, 0x099    #000010011001

	# max_cycle 50
	# pout_start
	# 000000ff
	# 00000066
	# pout_end
