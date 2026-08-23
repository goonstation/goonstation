/// This value is substituted with `src` on `New()`.
#define SRC_PROC "src_proc"


ABSTRACT_TYPE(/datum/speech_module/modifier/accent)
/datum/speech_module/modifier/accent
	id = "accent_base"
	priority = SPEECH_MODIFIER_PRIORITY_ACCENTS
	var/datum/callback/accent_proc = null

/datum/speech_module/modifier/accent/New(datum/speech_module_tree/parent)
	if (src.accent_proc && (src.accent_proc.object == SRC_PROC))
		src.accent_proc.object = src

	. = ..()

/datum/speech_module/modifier/accent/process(datum/say_message/message)
	APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, src.accent_proc)
	. = message





// Dialects:
/datum/speech_module/modifier/accent/bingus
	id = SPEECH_MODIFIER_ACCENT_BINGUS
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(bingus_parse))


/datum/speech_module/modifier/accent/chav
	id = SPEECH_MODIFIER_ACCENT_CHAV
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(chavify))


/datum/speech_module/modifier/accent/elvis
	id = SPEECH_MODIFIER_ACCENT_ELVIS
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(elvisfy))

/datum/speech_module/modifier/accent/elvis/process(datum/say_message/message)
	message.flags |= SAYFLAG_SINGING
	. = ..()


/datum/speech_module/modifier/accent/finnish
	id = SPEECH_MODIFIER_ACCENT_FINNISH
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(finnishify))


/datum/speech_module/modifier/accent/french
	id = SPEECH_MODIFIER_ACCENT_FRENCH
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(tabarnak))

/datum/speech_module/modifier/accent/frog
	id = SPEECH_MODIFIER_ACCENT_FROG
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(frogify))

/datum/speech_module/modifier/accent/german
	id = SPEECH_MODIFIER_ACCENT_GERMAN
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(germify))


/datum/speech_module/modifier/accent/hacker
	id = SPEECH_MODIFIER_ACCENT_HACKER
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(accent_hacker))


/datum/speech_module/modifier/accent/piglatin
	id = SPEECH_MODIFIER_ACCENT_PIGLATIN
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(accent_piglatin))


/datum/speech_module/modifier/accent/pirate
	id = SPEECH_MODIFIER_ACCENT_PIRATE
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(pirateify))


/datum/speech_module/modifier/accent/russian
	id = SPEECH_MODIFIER_ACCENT_RUSSIAN
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(russify))


/datum/speech_module/modifier/accent/scots
	id = SPEECH_MODIFIER_ACCENT_SCOTS
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(scotify))
	var/static/list/danny_lyrics = null
	var/danny_index = 1

/datum/speech_module/modifier/accent/scots/New(datum/speech_module_tree/parent)
	. = ..()
	src.danny_lyrics ||= global.dd_file2list("strings/danny.txt")

/datum/speech_module/modifier/accent/scots/process(datum/say_message/message)
	// Scots can only sing Danny Boy.
	if (message.flags & SAYFLAG_SINGING)
		src.danny_index = (src.danny_index % 16) + 1
		message.content = MAKE_CONTENT_MUTABLE(src.danny_lyrics[src.danny_index])

		return message

	. = ..()


/datum/speech_module/modifier/accent/scoob
	id = SPEECH_MODIFIER_ACCENT_SCOOB
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(scoobify))


/datum/speech_module/modifier/accent/scoob_nerf
	id = SPEECH_MODIFIER_ACCENT_SCOOB_NERF
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(scoobify), TRUE)


/datum/speech_module/modifier/accent/swedish
	id = SPEECH_MODIFIER_ACCENT_SWEDISH
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(borkborkbork))


/datum/speech_module/modifier/accent/thrall
	id = SPEECH_MODIFIER_ACCENT_THRALL
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(thrall_parse))

/datum/speech_module/modifier/accent/thrall/process(datum/say_message/message)
	message.say_verb = "gurgles"
	. = ..()


/datum/speech_module/modifier/accent/tommy
	id = SPEECH_MODIFIER_ACCENT_TOMMY
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(tommify))


/datum/speech_module/modifier/accent/tyke
	id = SPEECH_MODIFIER_ACCENT_TYKE
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(yorkify))


/datum/speech_module/modifier/accent/uwu
	id = SPEECH_MODIFIER_ACCENT_UWU
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(uwutalk))





// Speech Effects:
/datum/speech_module/modifier/accent/loud
	id = SPEECH_MODIFIER_ACCENT_LOUD
	accent_proc = CALLBACK(SRC_PROC, PROC_REF(make_loud))

/datum/speech_module/modifier/accent/loud/process(datum/say_message/message)
	. = ..()

	message.content += MAKE_CONTENT_MUTABLE("!!!")
	message.say_verb = "bellows"
	message.loudness += 1

/datum/speech_module/modifier/accent/loud/proc/make_loud(string)
	string = replacetext(string, "!", "!!!")
	string = replacetext(string, ".", "!!!")
	string = replacetext(string, "?", "???")
	return uppertext(string)


/datum/speech_module/modifier/accent/quiet
	id = SPEECH_MODIFIER_ACCENT_QUIET
	accent_proc = CALLBACK(SRC_PROC, PROC_REF(make_quiet))

/datum/speech_module/modifier/accent/quiet/process(datum/say_message/message)
	. = ..()

	message.content += MAKE_CONTENT_MUTABLE("...")
	message.say_verb = "murmurs"
	message.loudness -= 1

/datum/speech_module/modifier/accent/quiet/proc/make_quiet(string)
	string = replacetext(string, "!", "...")
	string = replacetext(string, "?", "..?")
	return lowertext(string)


/datum/speech_module/modifier/accent/slurring
	id = SPEECH_MODIFIER_ACCENT_SLURRING
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(say_drunk))


/datum/speech_module/modifier/accent/stutter
	id = SPEECH_MODIFIER_ACCENT_STUTTER
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(stutter))


/datum/speech_module/modifier/accent/unintelligible
	id = SPEECH_MODIFIER_ACCENT_UNINTELLIGIBLE
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(say_superdrunk))

/datum/speech_module/modifier/accent/unintelligible/process(datum/say_message/message)
	message.say_verb = "splutters"
	. = ..()





// Miscellaneous:
/datum/speech_module/modifier/accent/admin_bad
	id = SPEECH_MODIFIER_ACCENT_ADMIN_BAD

/datum/speech_module/modifier/accent/admin_bad/process(datum/say_message/message)
	. = message

	message.maptext_css_values["font-family"] = "'XFont 6x9'"
	message.maptext_css_values["font-size"] = "6px"
	message.maptext_css_values["color"] = "red !important"
	message.maptext_css_values["text-shadow"] = "0px 0px 3px black"
	message.maptext_css_values["-dm-text-outline"] = "2px black"


/datum/speech_module/modifier/accent/admin_good
	id = SPEECH_MODIFIER_ACCENT_ADMIN_GOOD

/datum/speech_module/modifier/accent/admin_good/process(datum/say_message/message)
	. = message

	message.maptext_css_values["color"] = "white !important"
	message.maptext_css_values["text-shadow"] = "0px 0px 3px white"
	message.maptext_css_values["-dm-text-outline"] = "1px black"


/datum/speech_module/modifier/accent/admin_good/rainbow
	id = SPEECH_MODIFIER_ACCENT_ADMIN_RAINBOW

/datum/speech_module/modifier/accent/admin_good/rainbow/process(datum/say_message/message)
	. = ..()

	message.maptext_animation_colours = list(
		"#FF0000",
		"#FFFF00",
		"#00FF00",
		"#00FFFF",
		"#0000FF",
		"#FF00FF",
	)


/datum/speech_module/modifier/accent/admin_rainglow
	id = SPEECH_MODIFIER_ACCENT_ADMIN_RAINGLOW

/datum/speech_module/modifier/accent/admin_rainglow/process(datum/say_message/message)
	. = message

	message.maptext_css_values["color"] = "black !important"
	message.maptext_css_values["text-shadow"] = "0px 0px 3px white"
	message.maptext_css_values["-dm-text-outline"] = "1px white"
	message.maptext_animation_colours = list(
		"#FF0000",
		"#FFFF00",
		"#00FF00",
		"#00FFFF",
		"#0000FF",
		"#FF00FF",
	)

ABSTRACT_TYPE(/datum/speech_module/modifier/accent/word_replacement)
/datum/speech_module/modifier/accent/word_replacement
	accent_proc = CALLBACK(SRC_PROC, PROC_REF(replace_words))
	var/guaranteed_replacements = 1 // The minimum number of words to replace per message

	proc/replace_words(string)
		var/list/speech_list = splittext(string, " ")
		var/list_length = length(speech_list)

		if (list_length <= 0)
			return

		// this will capture leading punctuation, the word itself(or at least the first part of it), and then any trailing punctuation or
		// multi-barrelled parts
		var/regex/punct_regex = regex("^(\\W*)(\[^\\s\\W\]+)(.*)$")
		var/max_replacements = min(6, ceil(list_length / 2))

		var/list/indices = list()

		for(var/i = 1 to list_length)
			indices += i

		var/replacements = 0

		var/number_of_attempts = 0
		while (length(indices) > 0 && number_of_attempts < max_replacements)
			var/word_index = pick(indices)
			indices -= word_index
			var/old_word = speech_list[word_index]
			if(!punct_regex.Find(old_word))
				// If the word doesn't match the regex it's probably all punctuation, so skip it
				continue
			// force replacements if we're running out of attempts and haven't hit the guaranteed replacement count yet. This affects the
			// distribution less than just replacing the first N words, I *think*
			else if((replacements < src.guaranteed_replacements && (max_replacements - number_of_attempts) <= src.guaranteed_replacements) || prob(50))
				var/replacement_word = src.get_preserved_word(punct_regex.group[2], src.get_replacement_word())
				speech_list[word_index] = "[punct_regex.group[1]][replacement_word][punct_regex.group[3]]" //preserve leading and trailing punctuation
				replacements++
			number_of_attempts++

		return jointext(speech_list, " ")

	/// Returns the replacement word with caps preservation.
	proc/get_preserved_word(var/old_word, var/replacement_word)
		if(uppertext(old_word) == old_word) //preserve all-caps
			replacement_word = uppertext(replacement_word)
		else
			var/ascii_val = text2ascii(copytext(old_word, 1, 2))//preserve capitalisation
			if(ascii_val >= 65 && ascii_val <= 90)
				replacement_word = capitalize(replacement_word)
		return replacement_word

	proc/get_replacement_word()
		return ""

/datum/speech_module/modifier/accent/word_replacement/butt
	id = SPEECH_MODIFIER_ACCENT_BUTT

	get_replacement_word()
		return "butt"

/datum/speech_module/modifier/accent/word_replacement/clack
	id = SPEECH_MODIFIER_ACCENT_CLACK

	get_replacement_word()
		return "clack"

/datum/speech_module/modifier/accent/cluwne
	id = SPEECH_MODIFIER_ACCENT_CLUWNE
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(honk))

/datum/speech_module/modifier/accent/cluwne/process(datum/say_message/message)
	if (!ON_COOLDOWN(message.speaker, "cluwne laugh", CLUWNE_NOISE_COOLDOWN))
		message.say_sound = pick('sound/voice/cluwnelaugh1.ogg','sound/voice/cluwnelaugh2.ogg','sound/voice/cluwnelaugh3.ogg')

	. = ..()


/datum/speech_module/modifier/accent/comic
	id = SPEECH_MODIFIER_ACCENT_COMIC

/datum/speech_module/modifier/accent/comic/process(datum/say_message/message)
	message.format_content_style_prefix = "<font face='Comic Sans MS'>"
	message.format_content_style_suffix = "</font>"
	message.maptext_css_values["font-size"] = "8px"
	. = message


/datum/speech_module/modifier/accent/emoji
	id = SPEECH_MODIFIER_ACCENT_EMOJI
	accent_proc = CALLBACK(SRC_PROC, PROC_REF(replace_words))
	var/static/regex/word_regex = regex("(\[a-zA-Z0-9-\]*)")
	var/static/list/word_to_emoji = null
	var/static/list/suffixes = list("", "ing", "s", "ed", "er", "ings")

/datum/speech_module/modifier/accent/emoji/New(datum/speech_module_tree/parent)
	. = ..()
	src.word_to_emoji ||= json_decode(file2text("strings/word_to_emoji.json"))

/datum/speech_module/modifier/accent/emoji/proc/replace_words(string)
	var/list/words = splittext_char(string, src.word_regex)
	var/list/out_words = list()

	for (var/word in words)
		var/found = FALSE

		for (var/suffix in src.suffixes)
			if ((suffix != "") && ((length(word) <= 3) || !endswith(word, suffix)))
				continue

			var/modword = suffix == "" ? word : copytext(word, 1, length(word) - length(suffix))
			var/list/emojis = src.word_to_emoji[lowertext(modword)]

			if (length(emojis))
				out_words += pick(emojis)
				found = TRUE
				break

		if (!found)
			out_words += word

	return jointext(out_words, "")


/datum/speech_module/modifier/accent/emoji/only
	id = SPEECH_MODIFIER_ACCENT_EMOJI_ONLY
	accent_proc = CALLBACK(SRC_PROC, PROC_REF(replace_words))

/datum/speech_module/modifier/accent/emoji/only/replace_words(string)
	var/processed = ..()
	var/list/output = list()

	for (var/i in 1 to length(processed))
		var/char = text2ascii_char(processed, i)
		if (char == 0)
			break
		else if (char > 127)
			output += ascii2text(char)

	return jointext(output, "") || "😶"


/datum/speech_module/modifier/accent/error
	id = SPEECH_MODIFIER_ACCENT_ERROR
	accent_proc = CALLBACK(SRC_PROC, PROC_REF(corrupt_text))
	var/static/max_font_size = 110
	var/static/min_font_size = 80
	var/static/rate_of_change = 5

/datum/speech_module/modifier/accent/error/proc/corrupt_text(string)
	var/font_size = 100
	var/fontIncreasing = TRUE

	var/list/characters = explode_string(string)
	var/processed_content = MAKE_CONTENT_IMMUTABLE("<b>")

	for (var/character as anything in characters)
		processed_content += MAKE_CONTENT_IMMUTABLE("<span style='font-size: [font_size]%;'>")
		processed_content += character
		processed_content += MAKE_CONTENT_IMMUTABLE("</span>")

		if (fontIncreasing)
			font_size = min(font_size + src.rate_of_change, src.max_font_size)

			if (font_size >= src.max_font_size)
				fontIncreasing = FALSE

		else
			font_size = max(font_size - src.rate_of_change, src.min_font_size)

			if (font_size <= src.min_font_size)
				fontIncreasing = TRUE

		if (prob(10))
			processed_content += pick("%", "##A", "-", "- - -", "ERROR")

	processed_content += MAKE_CONTENT_IMMUTABLE("</b>")
	return processed_content

/datum/speech_module/modifier/accent/horse
	id = SPEECH_MODIFIER_ACCENT_HORSE
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(neigh))

/datum/speech_module/modifier/accent/horse/process(datum/say_message/message)
	if (!ON_COOLDOWN(message.speaker, "cluwne laugh", CLUWNE_NOISE_COOLDOWN))
		message.say_sound = pick('sound/voice/cluwnelaugh1.ogg','sound/voice/cluwnelaugh2.ogg','sound/voice/cluwnelaugh3.ogg')

	. = ..()


/datum/speech_module/modifier/accent/literal_owo
	id = SPEECH_MODIFIER_ACCENT_LITERAL_OWO
	accent_proc = CALLBACK(SRC_PROC, PROC_REF(replace_text))

/datum/speech_module/modifier/accent/literal_owo/proc/replace_text(string)
	var/list/speech_list = splittext(string, " ")
	var/list_length = length(speech_list)

	if (!list_length)
		return

	var/o

	for (var/i in 1 to list_length)
		o = TRUE
		var/text = speech_list[i]
		var/newtext = ""

		for (var/j in 1 to length(text))
			if (o)
				newtext += "o"
			else
				newtext += "w"

			o = !o

		speech_list[i] = newtext

	return jointext(speech_list, " ")


/datum/speech_module/modifier/accent/lol
	id = SPEECH_MODIFIER_ACCENT_LOLCAT
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(lolcat))


/datum/speech_module/modifier/accent/mocking
	id = SPEECH_MODIFIER_ACCENT_MOCKING
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(accent_mocking))


/datum/speech_module/modifier/accent/reversed_speech
	id = SPEECH_MODIFIER_ACCENT_REVERSED
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(reverse_text))


/datum/speech_module/modifier/accent/scrambled
	id = SPEECH_MODIFIER_ACCENT_SCRAMBLED
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(accent_scramble))


/datum/speech_module/modifier/accent/smile
	id = SPEECH_MODIFIER_ACCENT_SMILING
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(smilify))


/datum/speech_module/modifier/accent/transposed
	id = SPEECH_MODIFIER_ACCENT_TRANSPOSED
	accent_proc = CALLBACK(SRC_PROC, PROC_REF(transpose_text))
	var/static/max_font_size = 130
	var/static/min_font_size = 70
	var/static/rate_of_change = 5

/datum/speech_module/modifier/accent/transposed/proc/transpose_text(string)
	var/font_size = 100
	var/fontIncreasing = TRUE

	var/list/characters = explode_string(string)
	var/processed_content = ""

	for (var/character as anything in characters)
		processed_content += MAKE_CONTENT_IMMUTABLE("<span style='font-size: [font_size]%;'>")
		processed_content += character
		processed_content += MAKE_CONTENT_IMMUTABLE("</span>")

		if (fontIncreasing)
			font_size = min(font_size + src.rate_of_change, src.max_font_size)

			if (font_size >= src.max_font_size)
				fontIncreasing = FALSE

		else
			font_size = max(font_size - src.rate_of_change, src.min_font_size)

			if (font_size <= src.min_font_size)
				fontIncreasing = TRUE

	return processed_content


/datum/speech_module/modifier/accent/void
	id = SPEECH_MODIFIER_ACCENT_VOID
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(voidSpeak), TRUE)


/datum/speech_module/modifier/accent/vowelitis
	id = SPEECH_MODIFIER_ACCENT_VOWELITIS
	accent_proc = CALLBACK(SRC_PROC, PROC_REF(vowelitis))
	var/vowel_lower = null
	var/vowel_upper = null

/datum/speech_module/modifier/accent/vowelitis/New(datum/speech_module_tree/parent)
	. = ..()

	src.vowel_lower = pick("a", "e", "i", "o", "u")
	src.vowel_upper = uppertext(src.vowel_lower)

/datum/speech_module/modifier/accent/vowelitis/proc/vowelitis(string)
	string = replacetextEx(string, "a", src.vowel_lower)
	string = replacetextEx(string, "e", src.vowel_lower)
	string = replacetextEx(string, "i", src.vowel_lower)
	string = replacetextEx(string, "o", src.vowel_lower)
	string = replacetextEx(string, "u", src.vowel_lower)

	string = replacetextEx(string, "A", src.vowel_upper)
	string = replacetextEx(string, "E", src.vowel_upper)
	string = replacetextEx(string, "I", src.vowel_upper)
	string = replacetextEx(string, "O", src.vowel_upper)
	string = replacetextEx(string, "U", src.vowel_upper)

	return string


/datum/speech_module/modifier/accent/word_scrambled
	id = SPEECH_MODIFIER_ACCENT_WORD_SCRAMBLED
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(accent_shuffle_words))


/datum/speech_module/modifier/accent/yee
	id = SPEECH_MODIFIER_ACCENT_YEE
	accent_proc = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(yee_text))


/datum/speech_module/modifier/accent/zalgo
	id = SPEECH_MODIFIER_ACCENT_ZALGO
	accent_proc = CALLBACK(SRC_PROC, PROC_REF(random_zalgo))

/datum/speech_module/modifier/accent/zalgo/proc/random_zalgo(string)
	return global.zalgoify(string, rand(0, 2), rand(0, 1), rand(0, 2))


#undef SRC_PROC
