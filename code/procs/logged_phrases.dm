#define MAX_LOGGED_PHRASES 200
#define LOGGED_PHRASES_FILENAME "data/logged_phrases.json"

var/global/list/logged_phrases = null

/**
 * This system keeps a logged list of player-created phrases of various categories. The lists are cross-round.
 * Useful for stuff like hallucinations etc. If the number of phrases in a category exceeds MAX_LOGGED_PHRASES
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

proc/load_logged_phrases()
	if(fexists(LOGGED_PHRASES_FILENAME))
		global.logged_phrases = json_decode(file2text(LOGGED_PHRASES_FILENAME))
	else
		global.logged_phrases = list()

/// Gets a random logged phrase from a selected category duh
proc/random_logged_phrase(category)
	if(length(global.logged_phrases[category]))
		return pick(global.logged_phrases[category])
	return null

/// Logs a phrase to a selected category duh
proc/log_logged_phrase(category, phrase)
	if(category in global.logged_phrases)
		global.logged_phrases[category] += phrase
	else
		global.logged_phrases[category] = list(phrase)

proc/save_logged_phrases()
	for(var/category in global.logged_phrases)
		var/list/phrases = global.logged_phrases[category]
		if(length(phrases) > MAX_LOGGED_PHRASES)
			for(var/i in 1 to length(phrases))
				// bias towards old phrases so we don't get a new "say" category every round basically
				if(i <= MAX_LOGGED_PHRASES && prob(80))
					phrases.Swap(i, rand(i, MAX_LOGGED_PHRASES))
				else
					phrases.Swap(i, rand(i, length(phrases)))
			global.logged_phrases[category] = phrases.Copy(1, MAX_LOGGED_PHRASES)
	text2file(json_encode(global.logged_phrases), LOGGED_PHRASES_FILENAME)

#undef MAX_LOGGED_PHRASES
#undef LOGGED_PHRASES_FILENAME
