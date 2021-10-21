var/global/datum/controller/radio/radio_controller

/datum/controller/radio
	var/list/datum/radio_frequency/frequencies = list()

	/*
	proc/add_object(obj/device, new_frequency)
		if(isnumber(new_frequency))
			new_frequency = "[new_frequency]"
		var/datum/radio_frequency/frequency = src.get_frequency(new_frequency)

		frequency.add_object(device)
		return frequency

	proc/remove_object(obj/device, old_frequency)
		if(isnumber(new_frequency))
			new_frequency = "[old_frequency]"
		var/datum/radio_frequency/frequency = frequencies[old_frequency]
		frequency?.remove_object(device)
		return TRUE
	*/

	proc/get_frequency(freq)
		RETURN_TYPE(/datum/radio_frequency)
		if(isnum(freq))
			freq = "[freq]"
		. = frequencies[freq]
		if(!.)
			. = new/datum/radio_frequency(freq)
			frequencies[freq] = .
