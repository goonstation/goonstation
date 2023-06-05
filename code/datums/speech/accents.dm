TYPEINFO(/datum/speech_module/accent/chav)
	id = "accent_chav"
/datum/speech_module/accent/chav
	id = "accent_chav"

	process(datum/say_message/message)
		message.content = chavify(message.content)
		. = message

TYPEINFO(/datum/speech_module/accent/elvis)
	id = "accent_elvis"
/datum/speech_module/accent/elvis
	id = "accent_elvis"

	process(datum/say_message/message)
		message.content = elvisfy(message.content)
		. = message

TYPEINFO(/datum/speech_module/accent/finnish)
	id = "accent_finnish"
/datum/speech_module/accent/finnish
	id = "accent_finnish"

	process(datum/say_message/message)
		message.content = finnishify(message.content)
		. = message

TYPEINFO(/datum/speech_module/accent/hacker)
	id = "accent_hacker"
/datum/speech_module/accent/hacker
	id = "accent_hacker"

	process(datum/say_message/message)
		message.content = accent_hacker(message.content)
		. = message

TYPEINFO(/datum/speech_module/accent/pirate)
	id = "accent_pirate"
/datum/speech_module/accent/pirate
	id = "accent_pirate"

	process(datum/say_message/message)
		message.content = pirateify(message.content)
		. = message

TYPEINFO(/datum/speech_module/accent/french)
	id = "accent_french"
/datum/speech_module/accent/french
	id = "accent_french"

	process(datum/say_message/message)
		message.content = tabarnak(message.content)
		. = message

TYPEINFO(/datum/speech_module/accent/russian)
	id = "accent_russian"
/datum/speech_module/accent/russian
	id = "accent_russian"

	process(datum/say_message/message)
		message.content = russify(message.content)
		. = message

TYPEINFO(/datum/speech_module/accent/scoob)
	id = "accent_scoob"
/datum/speech_module/accent/scoob
	id = "accent_scoob"

	process(datum/say_message/message)
		message.content = scoobify(message.content)
		. = message

TYPEINFO(/datum/speech_module/accent/scoob_nerf)
	id = "accent_scoob_nerf"
/datum/speech_module/accent/scoob_nerf
	id = "accent_scoob_nerf"

	process(datum/say_message/message)
		message.content = scoobify(message.content, TRUE)
		. = message

TYPEINFO(/datum/speech_module/accent/scots)
	id = "accent_scots"
/datum/speech_module/accent/scots
	id = "accent_scots"

	process(datum/say_message/message)
		message.content = scotify(message.content)
		. = message

TYPEINFO(/datum/speech_module/accent/smiling)
	id = "accent_smiling"
/datum/speech_module/accent/smiling
	id = "accent_smiling"

	process(datum/say_message/message)
		message.content = smilify(message.content)
		. = message

TYPEINFO(/datum/speech_module/accent/swedish)
	id = "accent_swedish"
/datum/speech_module/accent/swedish
	id = "accent_swedish"

	process(datum/say_message/message)
		message.content = borkborkbork(message.content)
		. = message

TYPEINFO(/datum/speech_module/accent/tommy)
	id = "accent_tommy"
/datum/speech_module/accent/tommy
	id = "accent_tommy"

	process(datum/say_message/message)
		message.content = tommify(message.content)
		. = message

TYPEINFO(/datum/speech_module/accent/uwu)
	id = "accent_uwu"
/datum/speech_module/accent/uwu
	id = "accent_uwu"

	process(datum/say_message/message)
		message.content = uwutalk(message.content)
		. = message

TYPEINFO(/datum/speech_module/accent/void)
	id = "accent_void"
/datum/speech_module/accent/void
	id = "accent_void"

	process(datum/say_message/message)
		message.content = voidSpeak(message.content)
		. = message

TYPEINFO(/datum/speech_module/accent/tyke)
	id = "accent_tyke"
/datum/speech_module/accent/tyke
	id = "accent_tyke"

	process(datum/say_message/message)
		message.content = yorkify(message.content)
		. = message

TYPEINFO(/datum/speech_module/accent/zalgo)
	id = "accent_zalgo"
/datum/speech_module/accent/zalgo
	id = "accent_zalgo"

	process(datum/say_message/message)
		message.content = zalgoify(message.content, rand(0,2), rand(0, 1), rand(0, 2))
		. = message
