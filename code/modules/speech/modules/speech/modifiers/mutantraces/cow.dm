/datum/speech_module/modifier/mutantrace/cow
	id = SPEECH_MODIFIER_MUTANTRACE_COW
	var/static/regex/m_regex = regex(@"(m)(.?)", "ig")

/datum/speech_module/modifier/mutantrace/cow/process(datum/say_message/message)
	. = message

	message.content = replacetext(message.content, "cow", "human")
	message.content = src.m_regex.Replace(message.content, /datum/speech_module/modifier/mutantrace/cow/proc/letter_m_replacement)

/datum/speech_module/modifier/mutantrace/cow/proc/letter_m_replacement(match, m, letter_after)
	if (is_lowercase_letter(m))
		return stutter("mm") + letter_after
	else if (is_lowercase_letter(letter_after))
		return capitalize(stutter("mm")) + letter_after
	else
		return stutter("MM") + letter_after
