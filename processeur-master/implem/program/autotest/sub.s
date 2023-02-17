# TAG = sub
	.text
	lui x31, 0xffff0 #ffff0000
	lui x30, 0x00001 #00001000
	sub x31, x31, x30  
	
	# max_cycle 50
	# pout_start
	# ffff0000
	# fffef000	
	# pout_end
