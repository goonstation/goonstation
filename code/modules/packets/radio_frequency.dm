/datum/radio_frequency
	var/frequency
	var/list/atom/movable/analog_devices // stuff that communicates through voice, not packets
	var/datum/packet_network/radio/packet_network

	New(frequency)
		..()
		src.frequency = frequency
		analog_devices = list()
		packet_network = new(frequency)

	proc/is_analog(obj/device)
		// this is a good place to refactor later in a larger speech channel rework
		return istype(device, /obj/item/device/radio) || istype(device, /obj/item/mechanics/radioscanner)

	/*
	proc/get_component(obj/device)
		RETURN_TYPE(/datum/component/packet_connected)
		for(var/datum/component/packet_connected/radio/comp as anything in device.GetComponents(/datum/component/packet_connected/radio))
			if(comp.network == packet_network)
				return comp
		return null

	proc/make_component(obj/device)
		RETURN_TYPE(/datum/component/packet_connected)
		return get_component(device) || device.AddComponent(/datum/component/packet_connected, packet_network, ) // TODO

	proc/add_object(obj/device)
		if(is_analog(device))
			src.analog_devices[device] = 1
		packet_network.register(make_component(device))

	proc/remove_object(obj/device)
		if(is_analog(device))
			src.analog_devices -= device
		packet_network.unregister(get_component(device))
	*/

	disposing()
		analog_devices = null
		..()

	proc/post_packet_without_source(datum/signal/signal, range)
		return packet_network.post_packet(null, signal, range)

	/*
	proc/post_signal(obj/source, datum/signal/signal, range)
		packet_network.post_signal(source.TODO, signal, range)
	*/


