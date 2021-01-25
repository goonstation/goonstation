/*
Special frequency list:
On the map:
1149 for PDA messaging
1433 for hydroponics alerts
1435 for status displays
1437 for atmospherics/fire alerts
1445 for bot nav beacons
1447 for mulebot control
1449 for airlock controls
1453 for engineering access
1457 for door access request
1475 for Mail chute location
1359 for security headsets
1357 for engineering headsets
1354 for research headsets
1356 for medical headsets
1352 for syndicate headsets
*/

//moved transmission type defines to _setup.dm

var/global/datum/controller/radio/radio_controller

datum/controller/radio
	var/list/datum/radio_frequency/frequencies = list()
	var/list/active_jammers = list()

	proc/add_object(obj/device, new_frequency)
		var/datum/radio_frequency/frequency = frequencies[new_frequency]

		if(!frequency)
			frequency = new
			frequency.frequency = new_frequency
			frequencies[new_frequency] = frequency

		if( !frequency.devices.Find(device) )
			frequency.devices += device
		return frequency

	proc/remove_object(obj/device, old_frequency)
		var/datum/radio_frequency/frequency = frequencies[old_frequency]

		if(frequency)
			frequency.devices -= device

			if(frequency.devices.len < 1)
				qdel(frequency)
				frequencies -= old_frequency

		return 1

	proc/return_frequency(frequency)
		return frequencies[frequency]

/*
mob/verb/listfreq()
	boutput(world, "<span class='notice'>registered devices:</span>")
	for(var/fn in radio_controller.frequencies)
		var/datum/radio_frequency/f = radio_controller.return_frequency(fn)
		boutput(world, "<span class='notice'>[fn]</span>")
		for(var/obj/o in f.devices)
			boutput(world, "<span class='notice'>>[o]</span>")
	boutput(world, "<span class='notice'>end</span>")
*/


var/global/list/datum/signal/reusable_signals = list()
proc/get_free_signal()
	if (length(reusable_signals))
		while (. == null && reusable_signals.len)
			. = reusable_signals[reusable_signals.len]
			reusable_signals.len--
		if (. == null)
			return new /datum/signal ()
	else
		return new /datum/signal ()

datum/radio_frequency
	var/frequency
	var/list/obj/devices = list()

	//MBC : check_for_jammer proc was being called thousands of times per second.
	//Do its initial check in a define instead, because proc call overhead. Then call check_for_jammer_bare
	#define can_check_jammer (radio_controller.active_jammers.len)

	disposing()
		devices = null
		..()

	proc
		post_signal(obj/source, datum/signal/signal, range)
			var/turf/start_point
			if(range)
				start_point = get_turf(source)
				if(!start_point)
					if (length(reusable_signals) && !(signal in reusable_signals))
						signal.dispose()
					else if (signal)
						signal.wipe()
						reusable_signals += signal
					return 0

			if (can_check_jammer)
				if (check_for_jammer(source))
					return 0

			signal.channels_passed += "[src.frequency];"

			for(var/obj/device in devices)
				if(device != source)

					//MBC : Do checks here and call check_for_jammer_bare instead. reduces proc calls.
					if (can_check_jammer)
						if (check_for_jammer(device))
							continue

					if(range)
						var/turf/end_point = get_turf(device)
						if(end_point)
							if(start_point.z != end_point.z) continue
							if(max(abs(start_point.x-end_point.x), abs(start_point.y-end_point.y)) <= range)

								device.receive_signal(signal, TRANSMISSION_RADIO, frequency)
					else
						device.receive_signal(signal, TRANSMISSION_RADIO, frequency)

				LAGCHECK(LAG_REALTIME)

			if (!reusable_signals || reusable_signals.len > 10)
				signal.dispose()
			else if (signal)
				signal.wipe()
				reusable_signals |= signal
			LAGCHECK(LAG_MED)

		//assumes that list radio_controller.active_jammers is not null or empty.
		check_for_jammer(obj/source)
			.= 0
			for (var/atom in radio_controller.active_jammers) // Can be a mob or obj.
				var/atom/A = atom
				if (A && get_dist(get_turf(source), get_turf(A)) <= 6)
					return 1

obj/proc
	receive_signal(datum/signal/signal, receive_method, receive_param)
		return null

datum/signal
	var/obj/source
	var/channels_passed = "" //Param-like list of frequencies this signal has been on, for transponders and stuff.

	var/transmission_method = 0
	//0 = wire
	//1 = radio transmission

	var/data = list()
	var/encryption
	//We can carry a computer file around, why not.
	var/datum/computer/file/data_file

	proc/copy_from(datum/signal/model)
		source = model.source
		transmission_method = model.transmission_method
		data = model.data
		encryption = model.encryption

	proc/wipe()
		source = null
		channels_passed = ""
		data = list()
		encryption = null
		if (data_file)
			data_file.dispose()
		data_file = null
		return

	disposing()
		src.data_file?.dispose()

		if (reusable_signals)
			reusable_signals -= null
		..()


	// debuggging
	proc/show()
		boutput(world, "signal from \ref[source][source] on [channels_passed]")
		for(var/key in data)
			boutput(world, "[key]=[data[key]]")
		boutput(world, "end of signal")
