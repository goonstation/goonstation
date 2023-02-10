// look, I know this is uneblievably shit but if I wrote a proper parser in DM it would be horribly slow knowing DM's performance with strings
/*
how to use:

call pick_smart_string(filename, key)
or
call pick_smart_string(filename, key, list_of_additional_definitions)

the txt file is composed of sections, sections are delimited by two empty lines
each section starts with its name, the rest of the lines are the possible choices of what it can get replaced with
you can also use @, to delimit the choices
you can put the choices in quotes if you want, useful if you want to preserve whitespace at the beginning and at the end of the choice
you can use \n to get newlines, and you can also put \ at the end of a line to escape it and continue the current choice on the next line
you can use [stuff] to an extent:
	[name_of_other_section] will get replaced by a random line from that section
	[pick("string", "other string", name_of_section)] will choose one of those things randomly (and if it's a section see above)
	[key] will get replaced by list_of_additional_definitions[key], if the result is a proc it will get called
	[key(some, params)] the same thing as previous but if it's a proc it will get called with those params (but they don't get processed or anything, and quotes don't work there, why would you even use this)
	[wpick("string":10, "other string":1, name_of_section:5)] like pick but weighted (also slower)
the code is of very low quality so if you try to do fancy stuff like [pick(pick("a", "b"), "c")] it won't work, ok? keep it simple stupid
oh, and also the whole thing can work recursively, for example
	screaming
	aaa[pick("!", screaming)]
but it's probably not a good idea to use it too much because it's not gonna be very fast
oh and if you are inside [] don't use any of the following characters inside the strings: ,()"[]:
	no, escaping them doesn't work either

just look at conspiracy_theories.txt for an example
or ask pali
or even better rewrite this not to be complete trash
*/

var/global/list/smart_string_pickers = list()

/datum/smart_string_picker
	//var/static/regex/head_splitter = new(@"\s*([\l_\d]+)\s*:=\s*", "igm")
	var/static/regex/section_splitter = new(@{"(?:"?\s*\n\s*\n+\s*"?|"\s*$)"}, "m")
	var/static/regex/sentence_splitter = new(@{""?\s*(?:@,\n?|\n)\s*"?"}, "m")
	var/static/regex/bracket_splitter = new(@{"\[\s*|\s*\)?\s*\]"})
	var/static/regex/in_brackets_crap = new(@{"\s*[(,:]\s*"})

	var/list/definitions = list()

	New(input_file)
		..()
		if(!isfile(input_file))
			input_file = file(input_file)
		var/list/sections_text = splittext(replacetext(file2text(input_file), "\\\n", "\\n"), section_splitter)
		for(var/section_text in sections_text)
			var/list/section = splittext(section_text, sentence_splitter)
			if(!section.len || !section[1])
				continue
			definitions[section[1]] = section.Copy(2)

	proc/weighted_pick(var/list/params)
		var/total = 0
		for(var/i = 2; i <= params.len; i+=2)
			params[i] = text2num(params[i])
			total += params[i]
		var/weighted_num = rand(1, total)
		var/running_total = 0
		for(var/i = 1; i <= params.len; i+=2)
			running_total += params[i + 1]
			if(weighted_num <= running_total)
				return params[i]
		return

	proc/preprocess(var/line)
		line = replacetext(line, "\\n", "\n")
		line = splittext(line, bracket_splitter)
		. = list()
		var/is_bracketed = 0
		for(var/token in line)
			if(!is_bracketed)
				. += token
			else if(token == "")
				. += "[]" // so people can use the text() proc to substitute stuff maybe?
			else
				var/list/in_bracket_tokens = splittext(token, in_brackets_crap)
				. += list(list(in_bracket_tokens[1], in_bracket_tokens.Copy(2)))
			is_bracketed = !is_bracketed

	proc/parse_string_or_key(var/thing, var/params, var/additional_defs=null)
		if(thing[1] == {"""})
			return copytext(thing, 2, length(thing))
		else
			if(additional_defs && (thing in additional_defs))
				thing = additional_defs[thing]
				if(istext(thing))
					//
				else if(isnum(thing))
					thing = "[thing]"
				else if(isatom(thing))
					thing = "[thing]"
				else
					try
						thing = call(thing)(arglist(params))
					catch(var/exception/e)
						if(e.name != "bad proc")
							throw e
						else
							CRASH("invalid embedded value in smart string picker [thing]")
				return thing
			else if(thing in src.definitions)
				return src.generate(thing, additional_defs)
			else
				return ""


	proc/generate(var/key, var/additional_defs=null)
		var/list/choices = definitions[key]
		var/choice_index = rand(1, choices.len)
		var/choice = choices[choice_index]
		if(!islist(choice))
			choice = src.preprocess(choice)
			choices[choice_index] = choice
		. = list()
		for(var/token in choice)
			if(istext(token))
				. += token
				continue
			var/token_name = token[1]
			var/token_params = token[2]
			if(token_name == "pick")
				. += parse_string_or_key(pick(token_params), null, additional_defs)
			else if(token_name == "wpick")
				. += parse_string_or_key(weighted_pick(token_params), null, additional_defs)
			else
				. += parse_string_or_key(token_name, token_params, additional_defs)
		return jointext(., "")

proc/pick_smart_string(var/filename, var/key, var/additional_defs=null)
	if(!(filename in smart_string_pickers))
		smart_string_pickers[filename] = new/datum/smart_string_picker("strings/[filename]")
	var/datum/smart_string_picker/SC = smart_string_pickers[filename]
	return SC.generate(key, additional_defs)
