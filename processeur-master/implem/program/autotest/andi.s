# TAG = andi
	.text

	addi x31, x0, 0x0ff 	#000011111111
	andi x31, x31, 0x0f0    #0f0

	# max_cycle 50
	# pout_start
	# 000000ff
	# 000000f0
	# pout_end
