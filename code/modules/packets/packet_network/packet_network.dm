/datum/packet_network
	var/list/list/datum/component/packet_connected/devices_by_address = list()
	var/list/list/datum/component/packet_connected/devices_by_tag
	var/list/datum/component/packet_connected/all_hearing
	var/channel_name = "?"
	var/transmission_method = TRANSMISSION_INVALID
	var/in_disposing = FALSE

	var/count_current_devices = 0
	var/count_post = 0
	var/count_receive = 0
	var/count_broadcast = 0
	var/count_register = 0

/datum/packet_network/proc/can_send(datum/component/packet_connected/source, datum/signal/signal, params=null)
	return TRUE

/datum/packet_network/proc/can_receive(datum/component/packet_connected/target, datum/component/packet_connected/source, datum/signal/signal, params=null)
	return TRUE

/datum/packet_network/proc/can_receive_necessary(datum/component/packet_connected/source, datum/signal/signal, params=null)
	return FALSE

/datum/packet_network/proc/register(datum/component/packet_connected/device)
	src.count_register++
	src.count_current_devices++
	if(device.all_hearing)
		if(!islist(src.all_hearing))
			src.all_hearing = list()
		src.all_hearing[device] = 1
	if(device.net_tags)
		if(!islist(src.devices_by_tag))
			src.devices_by_tag = list()
		for(var/net_tag in device.net_tags)
			if(islist(src.devices_by_tag[net_tag]))
				src.devices_by_tag[net_tag][device] = 1
			else
				src.devices_by_tag[net_tag] = list((device) = 1)
	if(islist(src.devices_by_address[device.address]))
		src.devices_by_address[device.address][device] = 1
	else if(isnull(src.devices_by_address[device.address]))
		src.devices_by_address[device.address] = device
	else // it is a single object
		src.devices_by_address[device.address] = list((device) = 1, (src.devices_by_address[device.address]) = 1)

/datum/packet_network/proc/unregister(datum/component/packet_connected/device)
	src.count_current_devices--
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
	if(islist(src.devices_by_address[device.address]))
		src.devices_by_address[device.address] -= device
		if(length(src.devices_by_address[device.address]) == 1)
			src.devices_by_address[device.address] = src.devices_by_address[device.address][1]
	else
		src.devices_by_address -= device.address

/datum/packet_network/proc/draw_packet(datum/component/packet_connected/target, datum/component/packet_connected/source, datum/signal/signal,\
	params, datum/client_image_group/img_group)

	var/turf/sourceT = get_turf(source?.parent)
	var/turf/targetT = get_turf(target?.parent)
	if(!sourceT || !targetT || sourceT.z != targetT.z)
		return null
	// we draw twice, once anchored to source, once to target; this is so the line is visible at both ends
	var/datum/lineResult/R1 = drawLineImg(sourceT, targetT, "triangle", getCrossed = 0, mode = LINEMODE_SIMPLE)
	var/datum/lineResult/R2 = drawLineImg(targetT, sourceT, "triangle", getCrossed = 0, mode = LINEMODE_SIMPLE_REVERSED)
	. = list(R1.lineImage, R2.lineImage)
	for(var/image/img as anything in .)
		img.color = debug_color_of(src.channel_name)
		img.alpha = 0
		img.plane = PLANE_SCREEN_OVERLAYS
		animate(img, alpha = 30, time = 0.1 SECOND, easing = SINE_EASING | EASE_IN)
		animate(alpha = 50, time = 0.9 SECOND, easing = SINE_EASING | EASE_OUT)
		animate(alpha = 0, time = 1 SECONDS, easing = SINE_EASING)
		img_group.add_image(img)

/datum/packet_network/disposing()
	src.in_disposing = TRUE
	for(var/address in src.devices_by_address)
		if(islist(src.devices_by_address[address]))
			for(var/datum/component/packet_connected/device as anything in src.devices_by_address[address])
				qdel(device)
		else
			qdel(src.devices_by_address[address])
	src.devices_by_address = null
	src.devices_by_tag = null
	src.all_hearing = null
	. = ..()

#define POST_PACKET_INTERNAL(RECEIVE_PACKET) \
	if(is_broadcast) { \
		count_broadcast++; \
		count_receive += count_current_devices; \
		for(var/t_address in src.devices_by_address) { \
			if(islist(src.devices_by_address[t_address])) \
				for(var/datum/component/packet_connected/target as anything in src.devices_by_address[t_address]) { \
					if((target == source) && !source.receives_own_packets) \
						continue; \
					RECEIVE_PACKET \
				} \
			else { \
				var/datum/component/packet_connected/target = src.devices_by_address[t_address]; \
				if((target == source) && !source.receives_own_packets) \
					continue; \
				RECEIVE_PACKET \
			} \
		} \
	} \
	else { \
		var/list/datum/component/packet_connected/targets = src.all_hearing ? src.all_hearing.Copy() : list(); \
		var/list/datum/component/packet_connected/sharing_tag = src.devices_by_tag?[target_tag]; \
		if(sharing_tag) \
			targets |= sharing_tag; \
		if(src.devices_by_address?[target_address]) \
			targets |= src.devices_by_address?[target_address]; \
		if (source?.receives_own_packets) \
			targets |= source; \
		count_receive += length(targets); \
		for(var/datum/component/packet_connected/target as anything in targets) { \
			RECEIVE_PACKET \
		} \
	}

/datum/packet_network/proc/post_packet(datum/component/packet_connected/source, datum/signal/signal, params=null)
	. = TRUE

	count_post++
	if(!src.can_send(source, signal, params))
		return FALSE
	signal.transmission_method = transmission_method
	LAZYLISTADD(signal.channels_passed, src.channel_name)
	var/target_tag = signal.data["address_tag"]
	var/target_address = signal.data["address_1"]
	var/is_broadcast = target_address == "ping" || target_address == "00000000" || (isnull(target_tag) && isnull(target_address))
	var/sender = signal.data["sender"]
	//block any packet asking every device to send a ping back, trivial amplification attack that can seriously lag the server
	if (sender == "ping")
		return
	var/use_can_receive = src.can_receive_necessary(source, signal, params)
	var/datum/client_image_group/img_group = get_image_group("[CLIENT_IMAGE_GROUP_PACKETVISION][src.channel_name]")
	var/draw_packet = length(img_group?.subscribed_mobs_with_subcount)
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
					var/image/img = src.draw_packet(target, source, signal, params, img_group); \
					if(img) \
						images += img; \
				} // don't ask, it has to be like this
			POST_PACKET_INTERNAL(RECEIVE_PACKET)
			#undef RECEIVE_PACKET
		else
			POST_PACKET_INTERNAL( \
				target.receive_packet(signal, src.transmission_method, params); \
				var/image/img = src.draw_packet(target, source, signal, params, img_group); \
				if(img) \
					images += img; \
			)
		SPAWN(2 SECONDS)
			for(var/image/img as anything in images)
				img_group.remove_image(img)
				qdel(img)
	qdel(signal)


// debugging / profiling / inspection tools

/datum/packet_network/proc/brief_debug_info()
	. = list(
		"name" = channel_name,
		"device count" = count_current_devices,
		"packets sent" = count_post,
		"packets received" = count_receive,
		"received/send" = count_post ? count_receive / count_post : 0,
		"broadcast%" = count_post ? 100 * count_broadcast / count_post : 0,
		"send/minute" = count_post / (TIME / (1 MINUTE)),
		"received/minute" = count_receive / (TIME / (1 MINUTE))
	)

/datum/packet_network/proc/debug_device_text(datum/component/packet_connected/device, client/cl)
	. = list()
	. += ""
	. += "<a href='byond://?src=\ref[cl];Refresh=\ref[device.parent]'>[device.parent]</a> ([device.address])"
	. += "(<a href='byond://?src=\ref[cl];Refresh=\ref[device]'>[device.connection_id || "conn"]</a>)"
	if(device.all_hearing)
		. += " AH"
	for(var/tag in device.net_tags)
		. += " #[tag]"

/datum/packet_network/Topic(href, href_list)
	. = ..()
	if(href_list["debug_window"])
		src.display_debug_window(usr.client)

/datum/packet_network/proc/display_debug_window(client/cl)
	if(isnull(cl))
		cl = usr.client

	var/list/html = list()
	html += "<title>Packet Network [channel_name]</title>"
	html += "<a style='display:block;position:fixed;right:0;' href='byond://?src=\ref[src];debug_window=1'>🔄</a>"
	html += "<h1>[channel_name]</h1><br>"
	html += "[type]<br>"
	html += "<b>Transmission method: </b>[transmission_method]<br>"
	html += "<br>"

	html += "<b># current devices: </b>[count_current_devices]<br>"
	html += "<b># current addresses: </b>[length(devices_by_address)]<br>"
	html += "<b># current tags: </b>[length(devices_by_tag)]<br>"
	html += "<b># current all-hearing: </b>[length(all_hearing)]<br>"
	html += "<br>"

	html += "<b>packets sent: </b>[count_post]<br>"
	html += "<b>packet receive calls: </b>[count_receive]<br>"
	html += "<b>packets truly broadcasted: </b>[count_broadcast]<br>"
	html += "<b>device register calls: </b>[count_register]<br>"
	html += "<b>average receives per post: </b>[count_post ? count_receive / count_post : 0]<br>"
	html += "<b>average broadcast percentage: </b>[count_post ? 100 * count_broadcast / count_post : 0]%<br>"
	html += "<b>packets per minute: </b>[count_post / (TIME / (1 MINUTE))]<br>"
	html += "<b>receive calls per minute: </b>[count_receive / (TIME / (1 MINUTE))]<br>"
	html += "<br>"

	html += "<h3>All-Hearing</h3><br>"
	if(!length(all_hearing))
		html += "None<br>"
	for(var/d in all_hearing)
		html += debug_device_text(d, cl)

	html += "<h3>By Tag</h3><br>"
	if(!length(devices_by_tag))
		html += "None<br>"
	for(var/tag in devices_by_tag)
		html += "<b>[tag]</b>"
		html += "<ul>"
		for(var/d in devices_by_tag[tag])
			html += "<li>"
			html += debug_device_text(d, cl)
			html += "</li>"
		html += "</ul>"

	html += "<h3>By Address</h3><br>"
	if(!length(devices_by_address))
		html += "None<br>"
	for(var/address in devices_by_address)
		if(islist(devices_by_address[address]))
			html += "<b>[address]</b>"
			html += "<ul>"
			for(var/d in devices_by_address[address])
				html += "<li>"
				html += debug_device_text(d, cl)
				html += "</li>"
			html += "</ul>"
		else
			html += "<b>[address]</b> "
			html += debug_device_text(devices_by_address[address], cl)
			html += "<br>"

	cl.Browse(jointext(html, ""), "window=packet_network_\ref[src];size=500x700")

#undef POST_PACKET_INTERNAL
