/datum/component/packet_connected
	dupe_mode = COMPONENT_DUPE_SELECTIVE
	var/address
	var/list/net_tags = null
	var/all_hearing = FALSE
	var/datum/packet_network/network
	var/receive_packet_proc = null
	var/connection_id
	var/send_only = FALSE

/datum/component/packet_connected/Initialize(connection_id, datum/packet_network/network, address=null, receive_packet_proc=null, send_only=FALSE, net_tags=null, all_hearing=FALSE)
	. = ..()
	if(!istype(parent, /atom/movable))
		return COMPONENT_INCOMPATIBLE
	src.connection_id = connection_id
	src.network = network
	src.receive_packet_proc = receive_packet_proc
	if(isnull(address))
		address = generate_net_id(src.parent)
	src.address = address
	if(islist(net_tags))
		src.net_tags = net_tags
	else if(!isnull(net_tags))
		src.net_tags = list(net_tags)
	src.send_only = send_only
	src.all_hearing = all_hearing
	if(!src.send_only) src.network?.register(src)

/datum/component/packet_connected/CheckDupeComponent(datum/component/packet_connected/C, connection_id, datum/packet_network/network, address=null, receive_packet_proc=null, send_only=FALSE, net_tags=null, all_hearing=FALSE)
	. = !isnull(C?.connection_id) && C.connection_id == src.connection_id || \
			!isnull(connection_id) && connection_id == src.connection_id
	if(.)
		src.network?.unregister(src)
		src.address = C?.address || address
		src.net_tags = C?.net_tags || net_tags
		src.all_hearing = C?.all_hearing || all_hearing
		src.receive_packet_proc = C?.receive_packet_proc || receive_packet_proc
		src.network = C?.network || network
		src.send_only = C?.send_only || send_only
		if(src.send_only)
			src.network?.register(src)

/datum/component/packet_connected/proc/update_network(datum/packet_network/new_network)
	if(new_network == src.network)
		return
	if(!src.send_only) src.network?.unregister(src)
	src.network = new_network
	if(!src.send_only) src.network?.register(src)

/datum/component/packet_connected/proc/update_send_only(new_send_only)
	if(send_only == new_send_only)
		return
	src.send_only = new_send_only
	if(src.send_only)
		src.network?.register(src)
	else
		src.network?.unregister(src)

/datum/component/packet_connected/proc/update_address(new_address)
	if(new_address == src.address)
		return
	if(!src.send_only) src.network?.unregister(src)
	src.address = new_address
	if(!src.send_only) src.network?.register(src)

/datum/component/packet_connected/proc/add_tag(new_tag)
	if(new_tag in src.net_tags)
		return
	if(!src.send_only) src.network?.unregister(src)
	if(isnull(src.net_tags))
		src.net_tags = list()
	src.net_tags |= new_tag
	if(!src.send_only) src.network?.register(src)

/datum/component/packet_connected/proc/remove_tag(old_tag)
	if(!(old_tag in src.net_tags))
		return
	if(!src.send_only) src.network?.unregister(src)
	src.net_tags -= old_tag
	if(!src.send_only) src.network?.register(src)

/datum/component/packet_connected/proc/clear_tags()
	if(!src.send_only) src.network?.unregister(src)
	src.net_tags = null
	if(!src.send_only) src.network?.register(src)

/datum/component/packet_connected/proc/update_all_hearing(new_all_hearing)
	if(new_all_hearing == src.all_hearing)
		return
	if(!src.send_only) src.network?.unregister(src)
	src.all_hearing = new_all_hearing
	if(!src.send_only) src.network?.register(src)

/datum/component/packet_connected/disposing()
	if(!src.send_only)
		src.network?.unregister(src)
	src.network = null
	..()

/datum/component/packet_connected/proc/receive_packet(datum/signal/signal, transmission_method, params)
	SEND_SIGNAL(src.parent, COMSIG_MOVABLE_RECEIVE_PACKET, signal, transmission_method, params, connection_id)
	if(src.receive_packet_proc)
		call(src.parent, src.receive_packet_proc)(signal, transmission_method, params, connection_id)

/datum/component/packet_connected/proc/post_packet(datum/signal/signal, params=null)
	if(!("sender" in signal.data))
		signal.data["sender"] = src.address
	src.network?.post_packet(src, signal, params)



/datum/component/packet_connected/radio

/datum/component/packet_connected/radio/Initialize(connection_id, network, address=null, receive_packet_proc=null, send_only=FALSE, net_tags=null, all_hearing=FALSE)
	if(isnum(network) || istext(network))
		network = radio_controller.get_frequency(network).packet_network
	. = ..(connection_id, network, address, receive_packet_proc, send_only, net_tags, all_hearing)
	RegisterSignal(parent, COMSIG_MOVABLE_POST_RADIO_PACKET, PROC_REF(send_radio_packet))

/datum/component/packet_connected/radio/CheckDupeComponent(datum/component/packet_connected/C, connection_id, datum/packet_network/network, address=null, receive_packet_proc=null, send_only=FALSE, net_tags=null, all_hearing=FALSE)
	if(isnum(network) || istext(network))
		network = radio_controller.get_frequency(network).packet_network
	. = ..(C, connection_id, network, address, receive_packet_proc, send_only, net_tags, all_hearing)

/datum/component/packet_connected/radio/proc/send_radio_packet(atom/movable/sender, datum/signal/signal, range=null, frequency_or_id=null)
	var/datum/packet_network/radio/radio_network = src.network
	if(isnum(frequency_or_id))
		frequency_or_id = "[frequency_or_id]"
	if(!isnull(frequency_or_id) && frequency_or_id != radio_network?.frequency && frequency_or_id != src.connection_id)
		return FALSE
	return src.post_packet(signal, range)

/datum/component/packet_connected/radio/proc/update_frequency(frequency)
	src.update_network(radio_controller.get_frequency(frequency).packet_network)

/datum/component/packet_connected/radio/proc/get_frequency()
	var/datum/packet_network/radio/radio_network = src.network
	return radio_network?.frequency

/datum/component/packet_connected/radio/UnregisterFromParent()
	if(!src.send_only)
		src.network?.unregister(src)
	UnregisterSignal(src.parent, COMSIG_MOVABLE_POST_RADIO_PACKET)
	. = ..()
