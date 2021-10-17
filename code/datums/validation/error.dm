/datum/validation/error
	var/message
	var/path

	New(message)
		..()
		src.message = message
