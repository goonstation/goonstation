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

/datum/packet_network/proc/can_receive_necessary(datum/component/packet_connected/source, datum/signal/signal, params=null)
	return FALSE

/datum/packet_network/proc/register(datum/component/packet_connected/device)
	if(device.all_hearing)
		if(!islist(src.all_hearing))
			src.all_hearing = list()
		src.all_hearing[device] = 1
	else if(device.net_tags)
		if(!islist(src.devices_by_tag))
			src.devices_by_tag = list()
		for(var/net_tag in device.net_tags)
			if(islist(src.devices_by_tag[net_tag]))
				src.devices_by_tag[net_tag][device] = 1
			else
				src.devices_by_tag[net_tag] = list((device) = 1)
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
	if(device.net_tags)
		for(var/net_tag in device.net_tags)
			src.devices_by_tag[net_tag] -= device
			if(!length(src.devices_by_tag[net_tag]))
				src.devices_by_tag -= net_tag
			if(!length(src.devices_by_tag))
				src.devices_by_tag = null
	src.devices_by_address -= device.address
	if(!length(src.devices_by_address))
		src.devices_by_address = null

/datum/packet_network/proc/draw_packet(datum/component/packet_connected/target, datum/component/packet_connected/source, datum/signal/signal, params=null)
	var/turf/sourceT = get_turf(source.parent)
	var/turf/targetT = get_turf(target.parent)
	if(!sourceT || !targetT || sourceT.z != targetT.z)
		return null
	// we draw twice, once anchored to source, once to target; this is so the line is visible at both ends
	var/datum/lineResult/R1 = drawLine(sourceT, targetT, "triangle", getCrossed = 0, mode = LINEMODE_SIMPLE)
	var/datum/lineResult/R2 = drawLine(targetT, sourceT, "triangle", getCrossed = 0, mode = LINEMODE_SIMPLE_REVERSED)
	. = list(R1.lineImage, R2.lineImage)
	for(var/image/img as anything in .)
		img.color = debug_color_of(src.channel_name)
		img.alpha = 0
		img.plane = PLANE_SCREEN_OVERLAYS
		animate(img, alpha = 30, time = 0.1 SECOND, easing = SINE_EASING | EASE_IN)
		animate(alpha = 50, time = 0.9 SECOND, easing = SINE_EASING | EASE_OUT)
		animate(alpha = 0, time = 1 SECONDS, easing = SINE_EASING)
		get_image_group(CLIENT_IMAGE_GROUP_PACKETVISION).add_image(img)

/datum/packet_network/disposing()
	src.in_disposing = TRUE
	for(var/address in src.devices_by_address)
		var/datum/component/packet_connected/device = src.devices_by_address[address]
		qdel(device)
	src.devices_by_address = null
	src.devices_by_tag = null
	src.all_hearing = null
	. = ..()

#define POST_PACKET_INTERNAL(RECEIVE_PACKET) \
	if(is_broadcast) { \
		for(var/t_address in src.devices_by_address) { \
			var/datum/component/packet_connected/target = src.devices_by_address[t_address]; \
			if(target == source) \
				continue; \
			RECEIVE_PACKET \
		} \
	} \
	else { \
		var/list/datum/component/packet_connected/sharing_tag = src.devices_by_tag?[target_tag]; \
		var/datum/component/packet_connected/direct_target = src.devices_by_address?[target_address]; \
		if(direct_target && direct_target != source) { \
			var/datum/component/packet_connected/target = direct_target; \
			RECEIVE_PACKET \
		} \
		for(var/datum/component/packet_connected/target as anything in sharing_tag) \
			if(target != source && target != direct_target) { \
				RECEIVE_PACKET \
			} \
		for(var/datum/component/packet_connected/target as anything in src.all_hearing) \
			if(target != source && target != direct_target) { \
				RECEIVE_PACKET \
			} \
	}

/datum/packet_network/proc/post_packet(datum/component/packet_connected/source, datum/signal/signal, params=null)
	if(!src.can_send(source, signal, params))
		return
	signal.transmission_method = transmission_method
	LAZYLISTADD(signal.channels_passed, src.channel_name)
	var/target_tag = signal.data["address_tag"]
	var/target_address = signal.data["address_1"]
	var/is_broadcast = target_address == "ping" || (isnull(target_tag) && isnull(target_address))
	var/use_can_receive = src.can_receive_necessary(source, signal, params)
	var/draw_packet = length(global.client_image_groups?[CLIENT_IMAGE_GROUP_PACKETVISION]?.subscribed_mobs_with_subcount)
	if(!draw_packet)
		if(use_can_receive)
			POST_PACKET_INTERNAL( \
				if(src.can_receive(target, source, signal, params)) \
					target.receive_packet(signal, src.transmission_method, params); \
			)
		else
			POST_PACKET_INTERNAL( \
				target.receive_packet(signal, src.transmission_method, params); \
			)
	else
		var/list/image/images = list()
		if(use_can_receive)
			#define RECEIVE_PACKET \
				if(src.can_receive(target, source, signal, params)) { \
					target.receive_packet(signal, src.transmission_method, params); \
					images += src.draw_packet(target, source, signal, params); \
				} // don't ask, it has to be like this
			POST_PACKET_INTERNAL(RECEIVE_PACKET)
			#undef RECEIVE_PACKET
		else
			POST_PACKET_INTERNAL( \
				target.receive_packet(signal, src.transmission_method, params); \
				images += src.draw_packet(target, source, signal, params); \
			)
		SPAWN_DBG(2 SECONDS)
			for(var/image/img in images)
				get_image_group(CLIENT_IMAGE_GROUP_PACKETVISION).remove_image(img)
				qdel(img)
	qdel(signal)

#undef POST_PACKET_INTERNAL
