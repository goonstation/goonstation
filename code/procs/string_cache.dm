var/global/list/string_cache

/proc/strings(filename as text, key as text, var/accept_absent = 0,var/secret=0)
	var/directory = ""
	if(!secret)
		directory = "strings/"
	else
		directory = "+secret/strings/"
	if(!string_cache)
		string_cache = new
	if(!(filename in string_cache))
		if(fexists("[directory][filename]"))
			string_cache[filename] = list()
			var/list/stringsList = list()
			var/text = file2text("[directory][filename]")
			text = replacetext(text, "\\\n", "")
			text = replacetext(text, "\n\t", "@,")
			var/list/lines = splittext(text, "\n")
			var/lineCount = 0
			for(var/s in lines)
				lineCount++
				if (!s || findtext(s, "#", 1, 2) || findtext(s, "//", 1, 3))
					continue
				stringsList = splittext(s, "@=")
				if(length(stringsList) != 2)
					CRASH("Invalid string list in [directory][filename] - line: [lineCount]")
				if(findtext(stringsList[2], "@,"))
					string_cache[filename][stringsList[1]] = keep_truthy(splittext(stringsList[2], "@,"))
				else
					string_cache[filename][stringsList[1]] = stringsList[2] // Its a single string!
		else
			CRASH("file not found: [directory][filename]")
	if(isnull(key) && (filename in string_cache) && length(string_cache[filename]) == 1) // if only one key we can omit it
		key = string_cache[filename][1]
	if((filename in string_cache) && (key in string_cache[filename]))
		return string_cache[filename][key]
	else if (accept_absent) //Don't crash, just return null. It's fine. Honest
		return null
	else
		CRASH("strings list not found: [directory][filename], index=[key]")
