/datum/computer/file/record
	name = "record"
	extension = "REC"
	size = 2
	/// The fields of this record. This can either be a standard list or a key-value list.
	var/list/fields = null

/datum/computer/file/record/New()
	. = ..()
	src.fields = list()

/datum/computer/file/record/disposing()
	src.fields = null
	. = ..()

/datum/computer/file/record/asText()
	for (var/x as anything in src.fields)
		if (isnull(src.fields[x]))
			. += "[x]|n"
		else
			. += "[x]=[src.fields[x]]|n"
