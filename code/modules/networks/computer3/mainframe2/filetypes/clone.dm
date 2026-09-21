/datum/computer/file/clone
	name = "Clone Record"
	extension = "DNA"
	size = 24 // Come on, it's an entire human genome, gotta be at least 24 kilobytes.
	/// The key-value fields of this clone record.
	var/list/fields = null

/datum/computer/file/clone/New()
	. = ..()
	src.fields = list()

/datum/computer/file/clone/disposing()
	src.fields = null
	. = ..()

/datum/computer/file/clone/proc/operator[](key)
	return src.fields[key]

/datum/computer/file/clone/proc/operator[]=(key, value)
	src.fields[key] = value
