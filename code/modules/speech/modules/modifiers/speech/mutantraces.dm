ABSTRACT_TYPE(/datum/speech_module/modifier/mutantrace)
/datum/speech_module/modifier/mutantrace
	id = "mutantrace_base"
	priority = -5


/datum/speech_module/modifier/mutantrace/abomination
	id = SPEECH_MODIFIER_MUTANTRACE_ABOMINATION

/datum/speech_module/modifier/mutantrace/abomination/process(datum/say_message/message)
	message.content = pick("We are one...", "Join with us...", "Sssssss...")
	. = message


/datum/speech_module/modifier/mutantrace/amphibian
	id = SPEECH_MODIFIER_MUTANTRACE_AMPHIBIAN

/datum/speech_module/modifier/mutantrace/amphibian/process(datum/say_message/message)
	message.content = replacetext(message.content, "r", stutter("rrr"))
	. = message


/datum/speech_module/modifier/mutantrace/cow
	id = SPEECH_MODIFIER_MUTANTRACE_COW

/datum/speech_module/modifier/mutantrace/cow/process(datum/say_message/message)
	. = message

	message.content = replacetext(message.content, "cow", "human")
	message.content = replacetextEx(message.content, "m", stutter("mm"))
	message.content = replacetextEx(message.content, "M", stutter("MM"))


/datum/speech_module/modifier/mutantrace/flubber
	id = SPEECH_MODIFIER_MUTANTRACE_FLUBBER

/datum/speech_module/modifier/mutantrace/flubber/process(datum/say_message/message)
	message.content = pick("Wooo!!", "Whopeee!!", "Boing!!", "Čapaš!!")
	. = message


/datum/speech_module/modifier/mutantrace/lizard
	id = SPEECH_MODIFIER_MUTANTRACE_LIZARD
	var/static/regex/s_regex = regex(@"(s)(.?)", "ig")

/datum/speech_module/modifier/mutantrace/lizard/process(datum/say_message/message)
	message.content = src.s_regex.Replace(message.content, /datum/speech_module/modifier/mutantrace/lizard/proc/letter_s_replacement)
	. = message

/datum/speech_module/modifier/mutantrace/lizard/proc/letter_s_replacement(match, s, letter_after)
	if (is_lowercase_letter(s))
		return stutter("ss") + letter_after
	else if (is_lowercase_letter(letter_after))
		return capitalize(stutter("ss")) + letter_after
	else
		return stutter("SS") + letter_after


/datum/speech_module/modifier/mutantrace/pug
	id = SPEECH_MODIFIER_MUTANTRACE_PUG

/datum/speech_module/modifier/mutantrace/pug/process(datum/say_message/message)
	. = message

	message.content = replacetext(message.content, "rough", "ruff")
	message.content = replacetext(message.content, "pog", "pug")


/datum/speech_module/modifier/mutantrace/zombie
	id = SPEECH_MODIFIER_MUTANTRACE_ZOMBIE

/datum/speech_module/modifier/mutantrace/zombie/process(datum/say_message/message)
	message.content = pick("Urgh...", "Brains...", "Hungry...", "Kill...")
	. = message
