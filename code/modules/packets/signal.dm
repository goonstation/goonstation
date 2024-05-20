/datum/signal
	var/atom/movable/source
	var/list/channels_passed

	var/transmission_method = TRANSMISSION_WIRE // or TRANSMISSION_RADIO

	var/data = list()
	///Set to the error message displayed when sniffing the encrypted packet
	var/encryption
	///How obfuscated is this encryption, if sniffed by things that can read it?
	var/encryption_obfuscation = 15
	var/datum/computer/file/data_file

	var/mob/author

	New(mob/author=null)
		..()
		src.author = author || usr

	proc/copy_from(datum/signal/model)
		source = model.source
		transmission_method = model.transmission_method
		data = model.data
		encryption = model.encryption

	disposing()
		data_file?.dispose()
		data_file = null
		..()

	// debuggging
	proc/show()
		boutput(world, "signal from \ref[source][source] on [channels_passed]")
		for(var/key in data)
			boutput(world, "[key]=[data[key]]")
		boutput(world, "end of signal")


proc/get_free_signal(mob/author=null)
	return new /datum/signal(author)
