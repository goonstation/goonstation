/// argument for a spacebee command, a singleton (should be created through get_singleton())
/datum/command_argument
	var/regex/regex

	/// should process the matched regex into a value for the command, null to fail
	proc/process_match()
		return src.regex.match

	/// formatting of the argument in the ;;help command given the argument name
	proc/format_help(name)
		return name

/// a quoted or unquoted string argument
/datum/command_argument/string
	regex = new(@{"([^ \n\t"]+)|"((?:[^"\\]|\\.)*)""})
	process_match()
		if(src.regex.group[1])
			return src.regex.group[1]
		else
			. = src.regex.group[2]
			. = replacetext(., "\\\\", "✌🤣😂😭")
			. = replacetext(., "\\\"", "\"")
			. = replacetext(., "✌🤣😂😭", "\\")

/// a quoted or unquoted string argument that gets `ckey` applied to it
/datum/command_argument/string/ckey
	process_match()
		return ckey(..())

/// a string argument that doesn't have to exist (only supported as either the only argument or having another arg after it weirdly)
/datum/command_argument/string/optional
	regex = new(@{"(?:([^ \n\t"]+)|"((?:[^"\\]|\\.)*)")?"})
	process_match()
		if(src.regex.group[1] || src.regex.group[2])
			return ..()
		else
			return ""
	format_help(name)
		return "\[[name]\]"

/// a number, not necessarily an integer
/datum/command_argument/number
	regex = new(@{"-?[0-9]+(\\.[0-9]*)?"})
	process_match()
		return text2num(..())

/// an integer
/datum/command_argument/number/integer
	regex = new(@{"-?[0-9]+"})

/// the whole rest of the command (only supported as the last argument for obvious reasons)
/datum/command_argument/the_rest
	regex = new(@{"(?:.|\n)*"})
	format_help(name)
		return "[name]..."

/// anything at all until the next space
/datum/command_argument/until_space
	regex = new(@{"[^ ]*"})
