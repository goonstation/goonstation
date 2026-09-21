/datum/computer/file/text
	name = "text"
	extension = "TXT"
	size = 2
	/// The text data of this file.
	var/data = null

/datum/computer/file/text/asText()
	return "[src.data]|n"
