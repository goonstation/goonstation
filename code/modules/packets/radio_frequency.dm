/datum/radio_frequency
	var/frequency
	var/datum/packet_network/radio/packet_network

	New(frequency)
		..()
		src.frequency = frequency
		packet_network = new(frequency)

	disposing()
		src.packet_network = null
		..()

	proc/post_packet_without_source(datum/signal/signal, range)
		return packet_network.post_packet(null, signal, range)
