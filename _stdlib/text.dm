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
	return findtextEx(lowertext(t), "aeiou���") > 0

/**
  * Returns true if given string is just space characters
	* [  ] is used instead of \s because apparently BYOND doesn't count non breaking spaces as whitespace AHHHHH - Sov
  */
var/static/regex/is_blank_string_regex = new(@{"^[  ]*$"})
/proc/is_blank_string(var/txt)
	if (is_blank_string_regex.Find(txt))
		return 1
	return 0 //not blank
