/datum/computer/file/lrt_data
	name = "Galactic Position Record"
	extension = "GPR"
	size = 8
	/// The name of the target position.
	var/place_name = null

/datum/computer/file/lrt_data/asText()
	var/md5 = md5(src.place_name)
	return "[copytext(md5, 1, 16)]l[copytext(md5, 17, 32)]b|n"
