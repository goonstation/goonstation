/datum/computer/file/signal
	name = "signal"
	extension = "SIG"
	size = 2

	var/list/data = null
	var/encryption = null
	var/datum/computer/file/data_file = null

/datum/computer/file/signal/New()
	. = ..()
	src.data = list()

/datum/computer/file/signal/disposing()
	src.data = null
	src.encryption = null
	if (src.data_file)
		src.data_file.dispose()
		src.data_file = null

	. = ..()

/datum/computer/file/signal/asText()
	for (var/x in src.data)
		if (isnull(src.data[x]))
			. += "\[[x]\] = NULL|n"
		else
			. += "\[[x]\] = [src.data[x]]|n"
