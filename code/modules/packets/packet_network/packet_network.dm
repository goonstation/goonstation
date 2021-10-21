/datum/packet_network
	var/list/devices_by_address // list of /datum/component/packet_connected
	var/list/list/datum/component/packet_connected/devices_by_tag
	var/list/datum/component/packet_connected/all_hearing
	var/channel_name = "?"
	var/transmission_method = TRANSMISSION_INVALID
	var/in_disposing = FALSE

/datum/packet_network/proc/can_send(datum/component/packet_connected/source, datum/signal/signal, params=null)
	return TRUE

/datum/packet_network/proc/can_receive(datum/component/packet_connected/target, datum/component/packet_connected/source, datum/signal/signal, params=null)
	return TRUE

/datum/packet_network/proc/register(datum/component/packet_connected/device)
	if(device.all_hearing)
		if(!islist(src.all_hearing))
			src.all_hearing = list()
		src.all_hearing[device] = 1
	else if(device.net_tag)
		if(!islist(src.devices_by_tag))
			src.devices_by_tag = list()
		if(islist(src.devices_by_tag[device.net_tag]))
			src.devices_by_tag[device.net_tag][device] = 1
		else
			src.devices_by_tag[device.net_tag] = list((device) = 1)
	if(!islist(src.devices_by_address))
		src.devices_by_address = list()
	src.devices_by_address[device.address] = device

/datum/packet_network/proc/unregister(datum/component/packet_connected/device)
	if(src.in_disposing)
		return // it gets cleaned en-masse
	if(device.all_hearing)
		src.all_hearing -= device
		if(!length(src.all_hearing))
			src.all_hearing = null
	if(device.net_tag)
		src.devices_by_tag[device.net_tag] -= device
		if(!length(src.devices_by_tag[device.net_tag]))
			src.devices_by_tag -= device.net_tag
		if(!length(src.devices_by_tag))
			src.devices_by_tag = null
	src.devices_by_address -= device.address
	if(!length(src.devices_by_address))
		src.devices_by_address = null

/datum/packet_network/disposing()
	src.in_disposing = TRUE
	for(var/address in src.devices_by_address)
		var/datum/component/packet_connected/device = src.devices_by_address[address]
		qdel(device)
	src.devices_by_address = null
	src.devices_by_tag = null
	src.all_hearing = null
	. = ..()

/datum/packet_network/proc/post_packet(datum/component/packet_connected/source, datum/signal/signal, params=null)
	if(!src.can_send(source, signal, params))
		return
	signal.transmission_method = transmission_method
	LAZYLISTADD(signal.channels_passed, src.channel_name)
	var/target_tag = signal.data["address_tag"] // unused for now
	var/target_address = signal.data["address_1"]
	var/is_broadcast = target_address == "ping" || target_address == "!BEACON!" || (isnull(target_tag) && isnull(target_address))
	if(is_broadcast)
		for(var/t_address in src.devices_by_address)
			var/datum/component/packet_connected/target = src.devices_by_address[t_address]
			if(target == source)
				continue
			if(src.can_receive(target, source, signal, params))
				target.receive_packet(signal, src.transmission_method, params)
	else
		var/list/datum/component/packet_connected/sharing_tag = src.devices_by_tag?[target_tag]
		var/datum/component/packet_connected/direct_target = src.devices_by_address?[target_address]
		if(direct_target && direct_target != source && src.can_receive(direct_target, source, signal, params))
			direct_target.receive_packet(signal, src.transmission_method, params)
		for(var/datum/component/packet_connected/target as anything in sharing_tag)
			if(target != source && target != direct_target && src.can_receive(target, source, signal, params))
				target.receive_packet(signal, src.transmission_method, params)
		for(var/datum/component/packet_connected/target as anything in src.all_hearing)
			if(target != source && target != direct_target && src.can_receive(target, source, signal, params))
				target.receive_packet(signal, src.transmission_method, params)
	qdel(signal)
