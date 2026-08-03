//CONTENTS:
//Base computer datum
//Base Folder
//Base File
//Text files
//Records
//Signal files
//Archive files
//Folder link


//permission defines moved to _setup.dm



/datum/computer/file/text
	name = "text"
	extension = "TXT"
	size = 2
	var/data = null

	asText()
		return "[data]|n"

/datum/computer/file/record
	name = "record"
	extension = "REC"
	size = 2

	var/list/fields = list(  )

	disposing()
		fields = null
		..()

	asText()
		for (var/x in fields)
			. += "[x]"
			if (isnull(fields[x]))
				. += "|n"
			else
				. += "=[fields[x]]|n"

/datum/computer/file/signal
	name = "signal"
	extension = "SIG"
	size = 2

	var/list/data = list()
	var/encryption
	var/datum/computer/file/data_file = null

	disposing()
		data = null
		encryption = null
		if (data_file)
			data_file.dispose()
			data_file = null

		..()

	asText()
		for (var/x in data)
			. += "\[[x]]"
			if (isnull(data[x]))
				. += " = NULL|n"
			else
				. += " = [data[x]]|n"

/datum/computer/file/archive
	name = "archive"
	extension = "FAR"
	size = 8

	var/uncompressed_size = 0 //Size of files stored within.
	var/list/contained_files = list() //Generally assumed that all contained files will be expendable copies
	var/max_contained_size = 48

	proc/add_file(datum/computer/R)
		if(!R || (R.size + uncompressed_size) > max_contained_size)
			return 0

		if(istype(R, /datum/computer/file/archive))
			return 0

		contained_files += R
		uncompressed_size += R.size
		return 1

	copy_file() //Just make a replica of self
		var/datum/computer/file/archive/copy = new src.type

		for(var/V in src.vars)
			if (issaved(src.vars[V]) && V != "contained_files")
				copy.vars[V] = src.vars[V]

		if (!copy.contained_files)
			copy.contained_files = list()

		for(var/datum/computer/F in src.contained_files)
			if (istype(F, /datum/computer/file))
				copy.contained_files += F:copy_file()
			else if (istype(F, /datum/computer/folder))
				var/datum/computer/folder/fcopy = F:copy_file()
				if (fcopy)
					copy.contained_files += fcopy

		return copy

	disposing()
		if (src.contained_files)
			for (var/datum/computer/C in src.contained_files)
				C.dispose()

			src.contained_files.len = 0
			src.contained_files = null
		..()

/datum/computer/file/clone
	name = "Clone Record"
	extension = "DNA"
	size = 24 //come on, it's an entire human genome, gotta be at least 24 kilobytes
	var/list/fields = list()

/datum/computer/file/clone/proc/operator[](key)
	return src.fields[key]

/datum/computer/file/clone/proc/operator[]=(key, value)
	src.fields[key] = value

/datum/computer/file/clone/disposing()
	fields = null
	. = ..()

/datum/computer/file/lrt_data
	name = "Galactic Position Record"
	extension = "GPR"
	size = 8
	var/place_name
	var/md5_value

	asText()
		if(!md5_value)
			md5_value = md5(place_name)
		return "[copytext(md5_value, 1,16)]l[copytext(md5_value, 17,32)]b|n"

	disposing()
		place_name = null
		. = ..()


/datum/computer/folder/link
	name = "symlink"
	gen = 10
	var/datum/computer/folder/target = null

	New(var/datum/computer/folder/newtarget)
		..()
		if (gen != 10) gen = 10
		if(istype(newtarget))
			if (istype(newtarget, /datum/computer/folder/link))
				newtarget = newtarget:target
				if (!newtarget)
					return
			//qdel(src.metadata)
			src.contents = newtarget.contents
			//src.metadata = newtarget.metadata
			newtarget.linkers += src
			src.target = newtarget
		return

	/* same as above, XOXOXO. -singh
	disposing()
		src.contents = null
		if (src.target)
			src.target.linkers -= src
			src.target = null
		..()
	*/

	disposing()
		src.contents = null
		if (src.target)
			src.target.linkers -= src
			src.target = null
		..()

	add_file(datum/computer/R, misc)
		if (!target || target.holder != src.holder)
			return 0

		return target.add_file(R, misc)

	can_add_file(datum/computer/R, misc)
		if (!target || target.holder != src.holder)
			return 0

		return target.can_add_file(R, misc)

	remove_file(datum/computer/R, misc)
		if(!target || target.holder != src.holder)
			return 0

		return target.remove_file(R, misc)

	copy_file(var/depth = 0)
		if(!target || target.holder != src.holder)
			return 0

		return target.copy_file(depth)

/datum/computer/file/image
	extension = "IMG"
	size = 8
	var/image/ourImage = null
	var/icon/ourIcon = null
	var/asciiVersion = null
	var/img_name = null
	var/img_desc = null

	asText()
		if (asciiVersion)
			return asciiVersion

		if (!(ourImage && ourImage.icon) && !ourIcon)
			return ""

		asciiVersion = ""
		var/icon/sourceIcon = ourIcon ? ourIcon : icon(ourImage.icon)
		for (var/py = 32, py > 0, py--)
			for (var/px = 1, px <= 32, px++)
				. = sourceIcon.GetPixel(px, py)
				if (.)
					. = hex2num(copytext(.,2))
					switch (.)
						if (0 to 5592405)
							asciiVersion += "."

						if (5592406 to 11184810)
							asciiVersion += "+"

						if (11184811 to INFINITY)
							asciiVersion += "@"
				else
					asciiVersion += "."

			asciiVersion += "|n"

		return asciiVersion
