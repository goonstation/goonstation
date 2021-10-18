/datum/validation_error
	var/message
	var/key

	New(message)
		..()
		src.message = message
