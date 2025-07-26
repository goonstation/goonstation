ABSTRACT_TYPE(/datum/speech_module/modifier/mutantrace)
/datum/speech_module/modifier/mutantrace
	id = "mutantrace_base"
	priority = SPEECH_MODIFIER_PRIORITY_MUTANTRACES


ABSTRACT_TYPE(/datum/speech_module/modifier/mutantrace/repeated_letter)
/datum/speech_module/modifier/mutantrace/repeated_letter
	var/target_letter = null
	var/regex/letter_regex = null

/datum/speech_module/modifier/mutantrace/repeated_letter/New(datum/speech_module_tree/parent)
	src.letter_regex = regex("([src.target_letter])(.?)", "ig")
	. = ..()

/datum/speech_module/modifier/mutantrace/repeated_letter/process(datum/say_message/message)
	APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(src.letter_regex, TYPE_PROC_REF(/regex, Replace), /datum/speech_module/modifier/mutantrace/repeated_letter/proc/letter_replacement))
	. = message

/datum/speech_module/modifier/mutantrace/repeated_letter/proc/letter_replacement(match, letter, letter_after)
	var/double_letter = "[letter][letter]"

	if (is_uppercase_letter(letter) && is_lowercase_letter(letter_after))
		return capitalize(stutter(lowertext(double_letter))) + letter_after

	return stutter(double_letter) + letter_after
