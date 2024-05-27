/datum/language/binary
	id = LANGUAGE_BINARY

/datum/language/binary/heard_not_understood(datum/say_message/message, datum/listen_module_tree/listen_tree)
	. = ..()

	message.content = src.to_binary(message.content)

/datum/language/binary/proc/to_binary(str, corr_prob = 0)
	. = ""

	for (var/i = 1, i <= min(length(str), 32), i++)
		var/l = text2ascii(str, i)

		for (var/j = 128, j >= 1, j /= 2)
			var/val = (l & j) ? 1 : 0

			if (prob(corr_prob))
				// Bit corruption error.
				if (prob(50))
					val = "E"
				// Bit flip error.
				else
					val = val ? 0 : 1

			. += "[val]"

	if (length(.) > MAX_MESSAGE_LEN)
		. = copytext(., 1, MAX_MESSAGE_LEN)

