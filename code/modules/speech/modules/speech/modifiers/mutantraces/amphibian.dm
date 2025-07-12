/datum/speech_module/modifier/mutantrace/amphibian
	id = SPEECH_MODIFIER_MUTANTRACE_AMPHIBIAN
	var/static/regex/r_regex = regex(@"(r)(.?)", "ig")

/datum/speech_module/modifier/mutantrace/amphibian/process(datum/say_message/message)
	. = message

	message.content = src.r_regex.Replace(message.content, /datum/speech_module/modifier/mutantrace/amphibian/proc/letter_r_replacement)

/datum/speech_module/modifier/mutantrace/amphibian/proc/letter_r_replacement(match, r, letter_after)
	if (is_lowercase_letter(r))
		return stutter("rrr") + letter_after
	else if (is_lowercase_letter(letter_after))
		return capitalize(stutter("rrr")) + letter_after
	else
		return stutter("RRR") + letter_after
