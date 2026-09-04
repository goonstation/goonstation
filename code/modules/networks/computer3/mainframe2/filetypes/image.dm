/datum/computer/file/image
	extension = "IMG"
	size = 8
	var/image/ourImage = null
	var/icon/ourIcon = null
	var/ascii = null
	var/img_name = null
	var/img_desc = null

/datum/computer/file/image/asText()
	if (src.ascii)
		return src.ascii

	if (!src.ourImage?.icon && !src.ourIcon)
		return ""

	var/icon/source = src.ourIcon || icon(src.ourImage.icon)
	src.ascii = ""
	for (var/py in 32 to 1 step -1)
		for (var/px in 1 to 32)
			var/colour = copytext(source.GetPixel(px, py), 2) || "000000"
			switch (hex2num(colour))
				if (0x000000 to 0x555555)
					ascii += "."
				if (0x555556 to 0xAAAAAA)
					ascii += "+"
				if (0xAAAAAB to 0xFFFFFF)
					ascii += "@"

		ascii += "|n"

	return ascii
