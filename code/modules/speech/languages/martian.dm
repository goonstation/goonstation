/datum/language/martian
	id = LANGUAGE_MARTIAN
	var/static/list/martian_dictionary = list()

/datum/language/martian/heard_not_understood(datum/say_message/message, datum/listen_module_tree/listen_tree)
	. = ..()

	APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(src, PROC_REF(to_martian)))

/datum/language/martian/proc/to_martian(string)
	var/list/words = splittext(uppertext(string), " ")
	var/list/newwords = list()
	for (var/w in words)
		if (w == "")
			continue
		var/suf = copytext(w, length(w))
		if (suf in list("!", ".", ",", "?"))
			var/osuf = suf
			while (prob(60) && osuf != ",")
				suf += osuf
			if (length(w) == 1)
				newwords[newwords.len] += suf
				continue
			w = copytext(w, 1, length(w))
		else
			suf = ""
		if (w in src.martian_dictionary)
			newwords += src.martian_dictionary[w] + suf
		else
			var/wlen = length(w)
			var/trlen = rand(max(2, wlen - 4), min(9, wlen + 4))
			var/list/trl = list()
			for (var/i = 1, i <= trlen, i++)
				trl += pick("K", "X", "B", "Q", "U", "I", "J", "F", "D", "V", "W", "P", "Z", "R", "M", "Y", "T")
			var/tr = jointext(trl, "")
			src.martian_dictionary[w] = tr
			newwords += tr + suf
	return jointext(newwords, " ")
