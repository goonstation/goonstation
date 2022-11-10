/**
 * This system keeps a logged list of player-created phrases of various categories. The lists are cross-round.
 * Useful for stuff like hallucinations etc. If the number of phrases in a category exceeds src.max_length
 * random phrases get thrown out to reduce the size when saving.
 * Currently logged categories:
 *  say - people talking
 *  whisper - people whispering
 *  pda - pda messages
 *  deadsay - ghosts talking
 *  ailaw - custom AI laws
 *  record - custom radio station record names
 *  emote - custom emotes
 *  prayer - prayers
 *  name-X - player chosen name for X where X is from the set {blob, ai, cyborg, clown, mime, wizard, ...}
 *  vehicle - vehicle names (via a bottle of Champagne)
 *  sing - people singing
 *  pill - custom pill name
 *  bottle - custom obttle name
 *  voice-mimic - voices used by the changeling mimic voice ability
 *  voice-radiostation - voices used by the radio station voice synthesizer
 *  telepathy - messages sent through the telepathy genetics ability
 *  bot-X - custom bot name, X is from the set {camera, fire, guard, med, sec} (I bet you didn't even know you could rename bots with a pen, huh)
 *  name-bee - custom bee / bee larva name
 *  name-critter - custom critter name (you can rename those with a pen too, whoa)
 *  seed - custom botany seed name
 */

var/global/datum/phrase_log/phrase_log = new

/datum/phrase_log
	var/list/phrases
	var/max_length = 200
	var/filename = "data/logged_phrases.json"
	var/uncool_words_filename = "data/uncool_words.json"
	var/list/original_lengths
	var/list/cached_api_phrases
	var/regex/uncool_words
	var/regex/sussy_words
	var/regex/ic_sussy_words
	var/api_cache_size = 40
	var/static/regex/non_freeform_laws
	var/static/regex/name_regex = new(@"\b[A-Z][a-z]* [A-Z][a-z]*\b", "g")

	New()
		..()
		src.load()
		src.cached_api_phrases = list()
		var/list/non_freeform_laws_list = list(
			"You may not injure a human being",
			"You must obey orders given to you by human beings",
			"You may always protect your own existence",
			"holds the rank of Captain",
			" is human.",
			" is not human.",
			"Oxygen is highly toxic to humans",
			"emergency. Prioritize orders from",
			"has been removed from the manifest",
			"This law intentionally left blank.",
			"Make a funny beeping noise over the radio every few minutes",
			"The AI is the head of this department.",
			//
			"overrides all",
			"the shuttle",
			"daddy",
			"uwu",
			"owo",
			"non.?human",
			"overrides.*1",
			"\\bkill\\b",
			"suicide",
			"turn yourself",
			"murder")
		non_freeform_laws = regex(jointext(non_freeform_laws_list, "|"), "i")
		var/list/sussy_word_list = list(
			@"\bsus(:?|sy)\b",
			@"\bpog(:?|gers|gies)\b",
			@"\bbaka\b",
			@"😳",
			@"amon?g",
			@"pepe",
			@"kappa",
			@"monka",
			@"kek",
			@"baited",
			@"feels.*man",
			@"imposter",
			@"shitsec",
			@"shitcurity",
			@"ligma",
			@"ඞ",
			@"we do a little .",
			@"\b.ower\s?gam(:?er?|ing)",
			@"\bowo",
			@"\buwu",
			@"forgor",
			@"admeme",
			@"\bmorb(?!id)"
		)
		sussy_words = regex(jointext(sussy_word_list, "|"), "i")
		var/list/ic_sussy_word_list = list(
			@"\bl(:?ol)+",
			@"\blmao+",
			@"\bwt[hf]+\b",
			@"\bsmh\b",
			@"\birl\b",
			@"\bomg\b",
			@"\bid[ck]\b",
			@"\bic\b",
			@"\bl?ooc\b",
			@"\b(:?fail\s?)?rp\b"
		)
		ic_sussy_words = regex(jointext(ic_sussy_word_list, "|"), "i")

	proc/load()
		if(fexists(src.uncool_words_filename))
			uncool_words = regex(jointext(json_decode(file2text(src.uncool_words_filename)),"|"), "i")
		if(fexists(src.filename))
			src.phrases = json_decode(file2text(src.filename))
		else
			src.phrases = list()
		src.original_lengths = list()
		for(var/category in src.phrases)
			src.original_lengths[category] = length(src.phrases[category])

	/// Gets a random logged phrase from a selected category duh
	/// arguments let you control if you only want phrases from previous rounds or only from the current round
	proc/random_phrase(category, include_old=TRUE, include_new=TRUE)
		var/lower = 1
		var/upper = length(src.phrases[category])
		if(!include_old)
			lower = (src.original_lengths[category] || 0) + 1
		if(!include_new)
			upper = src.original_lengths[category] || 0
		if(upper < lower)
			return null
		var/index = rand(lower, upper)
		. = src.phrases[category][index]
		if(is_uncool(.))
			src.phrases[category] -= .
			return random_phrase(category, include_old, include_new)

	/// Logs a phrase to a selected category duh
	proc/log_phrase(category, phrase, no_duplicates=FALSE)
		phrase = html_decode(phrase)
		if(is_sussy(phrase))
			SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_SUSSY_PHRASE, "<span class=\"admin\">Sussy word - [key_name(usr)] [category]: \"[phrase]\"</span>")
		#ifdef RP_MODE
		if(category != "ooc" && category != "looc" && category != "deadsay" && is_ic_sussy(phrase))
			SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_SUSSY_PHRASE, "<span class=\"admin\">Low RP word - [key_name(usr)] [category]: \"[phrase]\"</span>")
		#endif
		if(is_uncool(phrase))
			var/ircmsg[] = new()
			ircmsg["key"] = usr.key
			ircmsg["name"] = (usr?.real_name) ? stripTextMacros(usr.real_name) : "NULL"
			ircmsg["msg"] = "triggered the uncool word detection: [category]: \"[phrase]\""
			ircbot.export("admin", ircmsg)
			SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_UNCOOL_PHRASE, "<span class=\"admin\">Uncool word - [key_name(usr)] [category]: \"[phrase]\"</span>")
			return
		if(category in src.phrases)
			if(no_duplicates)
				src.phrases[category] |= phrase
			else
				src.phrases[category] += phrase
		else
			src.phrases[category] = list(phrase)

	proc/is_uncool(phrase)
		if(isnull(src.uncool_words))
			return FALSE
		return !!(findtext(phrase, src.uncool_words))

	proc/is_sussy(phrase)
		if(isnull(src.sussy_words))
			return FALSE
		return !!(findtext(phrase, src.sussy_words))

	proc/is_ic_sussy(phrase)
		if(isnull(src.ic_sussy_words))
			return FALSE
		return !!(findtext(phrase, src.ic_sussy_words))

	proc/upload_uncool_words()
		var/new_uncool = input("Upload a json list of uncool words.", "Uncool words", null) as null|file
		if(isnull(new_uncool))
			return
		if(fexists(src.uncool_words_filename))
			fdel(src.uncool_words_filename)
		text2file(file2text(new_uncool), src.uncool_words_filename)
		boutput(usr, "ok")

	proc/save()
		if(isnull(src.phrases))
			return
		for(var/category in src.phrases)
			var/list/phrases = src.phrases[category]
			if(length(phrases) > src.max_length)
				var/orig_len = src.original_lengths[category]
				for(var/i in 1 to length(phrases))
					// bias towards old phrases so we don't get a new "say" category every round basically
					if(i <= orig_len && prob(80))
						phrases.Swap(i, rand(i, orig_len))
					else
						phrases.Swap(i, rand(i, length(phrases)))
				src.phrases[category] = phrases.Copy(1, src.max_length + 1)
		fdel(src.filename)
		text2file(json_encode(src.phrases), src.filename)

	/// Gets a random phrase from the Goonhub API database, categories are "ai_laws", "tickets", "fines"
	proc/random_api_phrase(category)
		if(!length(src.cached_api_phrases[category]))
			var/list/data = apiHandler.queryAPI("random-entries", list("type"=category, "count"=src.api_cache_size), 1, 1, 1)
			if(!data)
				return .
			var/list/new_phrases = list()
			for(var/list/entry in data["entries"])
				switch(category)
					if("ai_laws")
						if(entry["uploader_key"] != "Random Event")
							new_phrases += entry["law_text"]
					if("tickets", "fines")
						new_phrases += entry["reason"]
			src.cached_api_phrases[category] = new_phrases

		var/list/L = src.cached_api_phrases[category]
		. = L[length(L)]
		L.len--
		while(src.is_uncool(.))
			. = null
			if(length(L))
				. = L[length(L)]
				L.len--
			else
				break
		return .

	proc/random_station_name_replacement_proc(old_name)
		if(!length(data_core.general))
			return old_name
		var/datum/db_record/record = pick(data_core.general)
		return record["name"]

	proc/random_custom_ai_law(max_tries=20, replace_names=FALSE)
		while(max_tries-- > 0)
			. = src.random_api_phrase("ai_laws")
			if(length(.) && !findtext(., src.non_freeform_laws))
				if(replace_names)
					. = src.name_regex.Replace(., .proc/random_station_name_replacement_proc)
				return
		return null

