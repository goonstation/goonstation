/datum/listen_module/effect/handset
	id = LISTEN_EFFECT_HANDSET

/datum/listen_module/effect/handset/process(datum/say_message/message)
	var/obj/item/phone_handset/handset = src.parent_tree.listener_parent
	if (!istype(handset) || !handset.parent.linked || !handset.parent.linked.handset)
		return

	var/datum/signal/signal = get_free_signal()
	signal.transmission_method = TRANSMISSION_RADIO
	signal.source = handset.parent
	signal.encryption = "\ref[handset.parent]"
	signal.data["message"] = message.Copy()
	signal.data["address_1"] = handset.parent.linked.net_id

	SEND_SIGNAL(handset.parent, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, null, handset.parent.frequency)

	handset.last_talk = TIME
