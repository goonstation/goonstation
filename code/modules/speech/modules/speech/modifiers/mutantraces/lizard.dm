/datum/speech_module/modifier/mutantrace/lizard
	id = SPEECH_MODIFIER_MUTANTRACE_LIZARD
	var/static/regex/s_regex = regex(@"(s)(.?)", "ig")

/datum/speech_module/modifier/mutantrace/lizard/process(datum/say_message/message)
	. = message

	message.content = src.s_regex.Replace(message.content, /datum/speech_module/modifier/mutantrace/lizard/proc/letter_s_replacement)

/datum/speech_module/modifier/mutantrace/lizard/proc/letter_s_replacement(match, s, letter_after)
	if (is_lowercase_letter(s))
		return stutter("ss") + letter_after
	else if (is_lowercase_letter(letter_after))
		return capitalize(stutter("ss")) + letter_after
	else
		return stutter("SS") + letter_after
