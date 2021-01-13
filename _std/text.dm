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

/// Returns true if the given string has a vowel
/proc/isVowel(var/t as text)
	return findtextEx(lowertext(t), "aeiouåäö") > 0

/**
  * Returns true if given string is just space characters
  * The explicitly defined entries are various blank unicode characters that don't get included as white space by \s
  */
var/global/regex/is_blank_string_regex = new(@{"^(\s|[\u00A0\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u2028\u205F\u3000])*$"})
/proc/is_blank_string(var/txt)
	if (is_blank_string_regex.Find(txt))
		return 1
	return 0 //not blank

var/global/regex/discord_emoji_regex = new(@{"(?:<|&lt;):([-a-zA-Z0-9_]+):(\d{18})(?:>|&gt;)"}, "g")
/proc/discord_emojify(text)
	return discord_emoji_regex.Replace(text, {"<img src="https://cdn.discordapp.com/emojis/$2.png" title="$1" width="32" height="32">"})
