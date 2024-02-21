/datum/puzzlewizard/trap
	var/trap_delay = 20
	initialize()
		trap_delay = input("How many 1/10th seconds must pass between two trap activations?", "Trap delay", 20) as num
