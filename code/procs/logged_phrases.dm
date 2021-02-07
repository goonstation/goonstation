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
 */

var/global/datum/phrase_log/phrase_log = new

/datum/phrase_log
	var/list/phrases
	var/max_length = 200
	var/filename = "data/logged_phrases.json"

	New()
		..()
		src.load()

	proc/load()
		if(fexists(src.filename))
			src.phrases = json_decode(file2text(src.filename))
		else
			src.phrases = list()

	/// Gets a random logged phrase from a selected category duh
	proc/random_phrase(category)
		if(length(src.phrases[category]))
			return pick(src.phrases[category])
		return null

	/// Logs a phrase to a selected category duh
	proc/log(category, phrase)
		if(category in src.phrases)
			src.phrases[category] += phrase
		else
			src.phrases[category] = list(phrase)

	proc/save()
		if(isnull(src.phrases))
			return
		for(var/category in src.phrases)
			var/list/phrases = src.phrases[category]
			if(length(phrases) > src.max_length)
				for(var/i in 1 to length(phrases))
					// bias towards old phrases so we don't get a new "say" category every round basically
					if(i <= src.max_length && prob(80))
						phrases.Swap(i, rand(i, src.max_length))
					else
						phrases.Swap(i, rand(i, length(phrases)))
				src.phrases[category] = phrases.Copy(1, src.max_length)
		fdel(src.filename)
		text2file(json_encode(src.phrases), src.filename)
