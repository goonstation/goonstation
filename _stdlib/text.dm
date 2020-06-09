/proc/trim_left(text)
	for (var/i = 1 to length(text))
		if (text2ascii(text, i) > 32)
			return copytext(text, i)
	return ""

/proc/trim_right(text)
	for (var/i = length(text), i > 0, i--)
		if (text2ascii(text, i) > 32)
			return copytext(text, 1, i + 1)

	return ""

/proc/trim(text)
	return trim_left(trim_right(text))

/proc/capitalize(var/t as text)
	return uppertext(copytext(t, 1, 2)) + copytext(t, 2)

/proc/isVowel(var/t as text)
	return findtextEx(lowertext(t), "aeiouåäö") > 0