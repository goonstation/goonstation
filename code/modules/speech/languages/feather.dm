/datum/language/feather
	id = LANGUAGE_FEATHER
	var/static/regex/getWords = new("\\b\\w+\\b", "g")

/datum/language/feather/heard_not_understood(datum/say_message/message, datum/listen_module_tree/listen_tree)
	. = ..()

	APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(src.getWords, TYPE_PROC_REF(/regex, Replace), /datum/language/feather/proc/genFeatherWord))

/datum/language/feather/proc/genFeatherWord(word)
	. = ""
	var/list/assembled = list()
	var/loopIterations = max(3, length(word))
	for (var/i = 1, i <= loopIterations, i++)
		var/subChar = ""
		var/char = ""
		if (i == 1)
			subChar = "c"
		else if (i == loopIterations)
			subChar = "w"
		else
			subChar = "a"

		if (i <= length(word))
			char = copytext(word, i, i+1)
		else
			char = copytext(word, -1)
		if (isUpper(char))
			subChar = uppertext(subChar)
		assembled += subChar
	. = assembled.Join()
