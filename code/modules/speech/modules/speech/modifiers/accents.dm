ABSTRACT_TYPE(/datum/speech_module/modifier/accent)
/datum/speech_module/modifier/accent
	id = "accent_base"
	priority = SPEECH_MODIFIER_PRIORITY_ACCENTS


// Dialects:
/datum/speech_module/modifier/accent/bingus
	id = "accent_bingus"

/datum/speech_module/modifier/accent/bingus/process(datum/say_message/message)
	message.content = bingus_parse(message.content)
	. = message


/datum/speech_module/modifier/accent/chav
	id = "accent_chav"

/datum/speech_module/modifier/accent/chav/process(datum/say_message/message)
	message.content = chavify(message.content)
	. = message


/datum/speech_module/modifier/accent/elvis
	id = "accent_elvis"

/datum/speech_module/modifier/accent/elvis/process(datum/say_message/message)
	message.content = elvisfy(message.content)
	message.flags |= SAYFLAG_SINGING
	. = message


/datum/speech_module/modifier/accent/finnish
	id = "accent_finnish"

/datum/speech_module/modifier/accent/finnish/process(datum/say_message/message)
	message.content = finnishify(message.content)
	. = message


/datum/speech_module/modifier/accent/french
	id = "accent_french"

/datum/speech_module/modifier/accent/french/process(datum/say_message/message)
	message.content = tabarnak(message.content)
	. = message


/datum/speech_module/modifier/accent/german
	id = "accent_german"

/datum/speech_module/modifier/accent/german/process(datum/say_message/message)
	message.content = germify(message.content)
	. = message


/datum/speech_module/modifier/accent/hacker
	id = "accent_hacker"

/datum/speech_module/modifier/accent/hacker/process(datum/say_message/message)
	message.content = accent_hacker(message.content)
	. = message


/datum/speech_module/modifier/accent/piglatin
	id = "accent_piglatin"

/datum/speech_module/modifier/accent/piglatin/process(datum/say_message/message)
	message.content = accent_piglatin(message.content)
	. = message


/datum/speech_module/modifier/accent/pirate
	id = "accent_pirate"

/datum/speech_module/modifier/accent/pirate/process(datum/say_message/message)
	message.content = pirateify(message.content)
	. = message


/datum/speech_module/modifier/accent/russian
	id = "accent_russian"

/datum/speech_module/modifier/accent/russian/process(datum/say_message/message)
	message.content = russify(message.content)
	. = message


/datum/speech_module/modifier/accent/scots
	id = "accent_scots"
	var/danny_index = 1

/datum/speech_module/modifier/accent/scots/process(datum/say_message/message)
	if (message.flags & SAYFLAG_SINGING)
		// Scots can only sing Danny Boy
		src.danny_index = (src.danny_index % 16) + 1
		var/lyrics = dd_file2list("strings/danny.txt")
		message.content = lyrics[src.danny_index]
	else
		message.content = scotify(message.content)
	. = message


/datum/speech_module/modifier/accent/scoob
	id = "accent_scoob"

/datum/speech_module/modifier/accent/scoob/process(datum/say_message/message)
	message.content = scoobify(message.content)
	. = message


/datum/speech_module/modifier/accent/scoob_nerf
	id = "accent_scoob_nerf"

/datum/speech_module/modifier/accent/scoob_nerf/process(datum/say_message/message)
	message.content = scoobify(message.content, TRUE)
	. = message


/datum/speech_module/modifier/accent/swedish
	id = "accent_swedish"

/datum/speech_module/modifier/accent/swedish/process(datum/say_message/message)
	message.content = borkborkbork(message.content)
	. = message


/datum/speech_module/modifier/accent/thrall
	id = "accent_thrall"

/datum/speech_module/modifier/accent/thrall/process(datum/say_message/message)
	. = message

	message.content = thrall_parse(message.content)
	message.say_verb = "gurgles"


/datum/speech_module/modifier/accent/tommy
	id = "accent_tommy"

/datum/speech_module/modifier/accent/tommy/process(datum/say_message/message)
	message.content = tommify(message.content)
	. = message


/datum/speech_module/modifier/accent/tyke
	id = "accent_tyke"

/datum/speech_module/modifier/accent/tyke/process(datum/say_message/message)
	message.content = yorkify(message.content)
	. = message


/datum/speech_module/modifier/accent/uwu
	id = "accent_uwu"

/datum/speech_module/modifier/accent/uwu/process(datum/say_message/message)
	message.content = uwutalk(message.content)
	. = message





// Speech Effects:
/datum/speech_module/modifier/accent/loud
	id = "loud_voice"

/datum/speech_module/modifier/accent/loud/process(datum/say_message/message)
	. = message

	message.content = replacetext(message.content, "!", "!!!")
	message.content = replacetext(message.content, ".", "!!!")
	message.content = replacetext(message.content, "?", "???")
	message.content = uppertext(message.content)
	message.content += "!!!"

	message.say_verb = "bellows"
	message.loudness += 1


/datum/speech_module/modifier/accent/quiet
	id = "quiet_voice"

/datum/speech_module/modifier/accent/quiet/process(datum/say_message/message)
	. = message

	message.content = replacetext(message.content, "!", "...")
	message.content = replacetext(message.content, "?", "..?")
	message.content = lowertext(message.content)
	message.content += "..."

	message.say_verb = "murmurs"
	message.loudness -= 1


/datum/speech_module/modifier/accent/slurring
	id = "slurring"

/datum/speech_module/modifier/accent/slurring/process(datum/say_message/message)
	message.content = say_drunk(message.content)
	. = message


/datum/speech_module/modifier/accent/stutter
	id = "stutter"

/datum/speech_module/modifier/accent/stutter/process(datum/say_message/message)
	message.content = stutter(message.content)
	. = message


/datum/speech_module/modifier/accent/unintelligable
	id = "unintelligable"

/datum/speech_module/modifier/accent/unintelligable/process(datum/say_message/message)
	. = message

	message.content = say_superdrunk(message.content)
	message.say_verb = "splutters"





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


/datum/speech_module/modifier/accent/butt
	id = "accent_butt"

/datum/speech_module/modifier/accent/butt/process(datum/say_message/message)
	. = message

	var/list/speech_list = splittext(message.content, " ")
	var/list_length = length(speech_list)

	if (!list_length)
		return

	var/number_of_butts = rand(1, min(4, (list_length / 2)))
	for (var/i in 1 to number_of_butts)
		speech_list[rand(1, list_length)] = "butt"

	message.content = jointext(speech_list, " ")


/datum/speech_module/modifier/accent/clack
	id = "accent_clack"

/datum/speech_module/modifier/accent/clack/process(datum/say_message/message)
	. = message

	var/list/speech_list = splittext(message.content, " ")
	var/list_length = length(speech_list)

	if (!list_length)
		return

	var/number_of_clacks = rand(1, min(4, (list_length / 2)))
	for (var/i in 1 to number_of_clacks)
		speech_list[rand(1, list_length)] = "clack"

	message.content = jointext(speech_list, " ")


/datum/speech_module/modifier/accent/cluwne
	id = SPEECH_MODIFIER_ACCENT_CLUWNE

/datum/speech_module/modifier/accent/cluwne/process(datum/say_message/message)
	. = message

	message.content = honk(message.content)
	if (!ON_COOLDOWN(message.speaker, "cluwne laugh", CLUWNE_NOISE_COOLDOWN))
		message.say_sound = pick('sound/voice/cluwnelaugh1.ogg','sound/voice/cluwnelaugh2.ogg','sound/voice/cluwnelaugh3.ogg')


/datum/speech_module/modifier/accent/comic
	id = "accent_comic"

/datum/speech_module/modifier/accent/comic/process(datum/say_message/message)
	message.format_content_style_prefix = "<font face='Comic Sans MS'>"
	message.format_content_style_suffix = "</font>"
	message.maptext_css_values["font-size"] = "8px"
	. = message


/datum/speech_module/modifier/accent/emoji
	id = "emoji"
	var/static/regex/word_regex = regex("(\[a-zA-Z0-9-\]*)")
	var/static/list/word_to_emoji
	var/static/list/suffixes = list("", "ing", "s", "ed", "er", "ings")

/datum/speech_module/modifier/accent/emoji/New()
	. = ..()
	src.word_to_emoji ||= json_decode(file2text("strings/word_to_emoji.json"))

/datum/speech_module/modifier/accent/emoji/process(datum/say_message/message)
	. = message

	var/list/words = splittext_char(message.content, src.word_regex)
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

	message.content = jointext(out_words, "")


/datum/speech_module/modifier/accent/emoji/only
	id = "emojionly"

/datum/speech_module/modifier/accent/emoji/only/process(datum/say_message/message)
	var/datum/say_message/processed_message = ..(message)

	var/processed = processed_message.content
	var/list/output = list()

	for (var/i in 1 to length(processed))
		var/char = text2ascii_char(processed, i)
		if (char == 0)
			break
		else if (char > 127)
			output += ascii2text(char)

	processed_message.content = jointext(output, "")


/datum/speech_module/modifier/accent/error
	id = SPEECH_MODIFIER_ACCENT_ERROR
	var/max_font_size = 110
	var/min_font_size = 80
	var/rate_of_change = 5

/datum/speech_module/modifier/accent/error/process(datum/say_message/message)
	. = message

	var/font_size = 100
	var/fontIncreasing = TRUE

	var/list/characters = explode_string(message.content)
	var/processed_content = ""

	for (var/character as anything in characters)
		processed_content += "<span style='font-size: [font_size]%;'>[character]</span>"

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

	message.content = "<b>[processed_content]</b>"
	. = message


/datum/speech_module/modifier/accent/horse
	id = SPEECH_MODIFIER_ACCENT_HORSE

/datum/speech_module/modifier/accent/horse/process(datum/say_message/message)
	. = message

	message.content = neigh(message.content)
	if (!ON_COOLDOWN(message.speaker, "cluwne laugh", CLUWNE_NOISE_COOLDOWN))
		message.say_sound = pick('sound/voice/cluwnelaugh1.ogg','sound/voice/cluwnelaugh2.ogg','sound/voice/cluwnelaugh3.ogg')


/datum/speech_module/modifier/accent/literal_owo
	id = "accent_literalowo"

/datum/speech_module/modifier/accent/literal_owo/process(datum/say_message/message)
	. = message

	var/list/speech_list = splittext(message.content, " ")
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

	message.content = jointext(speech_list, " ")


/datum/speech_module/modifier/accent/lol
	id = "accent_lolcat"

/datum/speech_module/modifier/accent/lol/process(datum/say_message/message)
	message.content = lolcat(message.content)
	. = message


/datum/speech_module/modifier/accent/mocking
	id = "accent_mocking"

/datum/speech_module/modifier/accent/mocking/process(datum/say_message/message)
	message.content = accent_mocking(message.content)
	. = message


/datum/speech_module/modifier/accent/reversed_speech
	id = "reversed_speech"

/datum/speech_module/modifier/accent/reversed_speech/process(datum/say_message/message)
	message.content = reverse_text(message.content)
	. = message


/datum/speech_module/modifier/accent/scrambled
	id = "accent_scrambled"

/datum/speech_module/modifier/accent/scrambled/process(datum/say_message/message)
	message.content = accent_scramble(message.content)
	. = message


/datum/speech_module/modifier/accent/smile
	id = "accent_smiling"

/datum/speech_module/modifier/accent/smile/process(datum/say_message/message)
	message.content = smilify(message.content)
	. = message


/datum/speech_module/modifier/accent/transposed
	id = "accent_transposed"
	var/max_font_size = 130
	var/min_font_size = 70
	var/rate_of_change = 5

/datum/speech_module/modifier/accent/transposed/process(datum/say_message/message)
	var/font_size = 100
	var/fontIncreasing = TRUE

	var/list/characters = explode_string(message.content)
	var/processed_content = ""

	for (var/character as anything in characters)
		processed_content += "<span style='font-size: [font_size]%;'>[character]</span>"

		if (fontIncreasing)
			font_size = min(font_size + src.rate_of_change, src.max_font_size)

			if (font_size >= src.max_font_size)
				fontIncreasing = FALSE

		else
			font_size = max(font_size - src.rate_of_change, src.min_font_size)

			if (font_size <= src.min_font_size)
				fontIncreasing = TRUE

	message.content = processed_content
	. = message


/datum/speech_module/modifier/accent/void
	id = "accent_void"

/datum/speech_module/modifier/accent/void/process(datum/say_message/message)
	message.content = voidSpeak(message.content)
	. = message


/datum/speech_module/modifier/accent/vowelitis
	id = "vowelitis"
	var/vowel_lower
	var/vowel_upper

/datum/speech_module/modifier/accent/vowelitis/New()
	. = ..()

	src.vowel_lower = pick("a", "e", "i", "o", "u")
	src.vowel_lower = uppertext(src.vowel_lower)

/datum/speech_module/modifier/accent/vowelitis/process(datum/say_message/message)
	. = message

	message.content = replacetext(message.content, "a", src.vowel_lower)
	message.content = replacetext(message.content, "e", src.vowel_lower)
	message.content = replacetext(message.content, "i", src.vowel_lower)
	message.content = replacetext(message.content, "o", src.vowel_lower)
	message.content = replacetext(message.content, "u", src.vowel_lower)
	message.content = replacetext(message.content, "A", src.vowel_upper)
	message.content = replacetext(message.content, "E", src.vowel_upper)
	message.content = replacetext(message.content, "I", src.vowel_upper)
	message.content = replacetext(message.content, "O", src.vowel_upper)
	message.content = replacetext(message.content, "U", src.vowel_upper)


/datum/speech_module/modifier/accent/word_scrambled
	id = "accent_word_scrambled"

/datum/speech_module/modifier/accent/word_scrambled/process(datum/say_message/message)
	message.content = accent_shuffle_words(message.content)
	. = message


/datum/speech_module/modifier/accent/yee
	id = "accent_yee"

/datum/speech_module/modifier/accent/yee/process(datum/say_message/message)
	message.content = yee_text(message.content)
	. = message


/datum/speech_module/modifier/accent/zalgo
	id = "accent_zalgo"

/datum/speech_module/modifier/accent/zalgo/process(datum/say_message/message)
	message.content = zalgoify(message.content, rand(0,2), rand(0, 1), rand(0, 2))
	. = message
