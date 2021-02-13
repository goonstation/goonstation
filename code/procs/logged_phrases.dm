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
	var/list/original_lengths

	New()
		..()
		src.load()

	proc/load()
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
		return src.phrases[category][rand(lower, upper)]

	/// Logs a phrase to a selected category duh
	proc/log_phrase(category, phrase, no_duplicates=FALSE)
		phrase = html_decode(phrase)
		if(category in src.phrases)
			if(no_duplicates)
				src.phrases[category] |= phrase
			else
				src.phrases[category] += phrase
		else
			src.phrases[category] = list(phrase)

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
