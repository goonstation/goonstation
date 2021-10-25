var/global/datum/controller/radio/radio_controller

/datum/controller/radio
	var/list/datum/radio_frequency/frequencies = list()

	proc/get_frequency(freq)
		RETURN_TYPE(/datum/radio_frequency)
		if(isnum(freq))
			freq = "[freq]"
		. = frequencies[freq]
		if(!.)
			. = new/datum/radio_frequency(freq)
			frequencies[freq] = .
