# TAG = add
	.text
	lui x31, 0xffff0 #ffff0000
	lui x30, 0x00001 #00001000
	add x31, x30, x31  
	
	# max_cycle 50
	# pout_start
	# ffff0000
	# ffff1000		
	# pout_end
