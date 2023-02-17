# TAG = sltiu
	.text
	lui x30, 0xf0f0f
	srli x30,x30,12
	
	lui x29, 0x0000f
	srli x29,x29,12
	
	sltiu x31, x29, 0x1f 
	sltiu x31, x30, 0xff

	# max_cycle 50
	# pout_start
	# 00000001
	# 00000000
	# pout_end

