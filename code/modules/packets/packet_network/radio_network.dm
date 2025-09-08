/datum/packet_network/radio
	var/frequency
	channel_name = null
	transmission_method = TRANSMISSION_RADIO

/datum/packet_network/radio/New(frequency)
	..()
	src.frequency = frequency
	src.channel_name = "[frequency]"

/datum/packet_network/radio/can_send(datum/component/packet_connected/source, datum/signal/signal, range=null)
	return isnull(source) || !(length(by_cat[TR_CAT_RADIO_JAMMERS]) && check_for_radio_jammers(source.parent, signal))

/datum/packet_network/radio/can_receive(datum/component/packet_connected/target, datum/component/packet_connected/source, datum/signal/signal, range=null)
	if(isnull(source))
		return TRUE
	if(check_for_radio_jammers(target.parent, signal))
		return FALSE
	if(!isnull(range) && !IN_RANGE(source.parent, target.parent, range))
		return FALSE
	return TRUE

/datum/packet_network/radio/can_receive_necessary(datum/component/packet_connected/source, datum/signal/signal, range=null)
	return length(by_cat[TR_CAT_RADIO_JAMMERS]) || !isnull(range)
