ABSTRACT_TYPE(/datum/phrase_log_cleaner)
/datum/phrase_log_cleaner
	var/regex/regex
	// Returns the new cleaned phrase or null if the phrase should be removed
	proc/clean(phrase, category)
		return phrase

ABSTRACT_TYPE(/datum/phrase_log_cleaner/purge)
/datum/phrase_log_cleaner/purge
	clean(phrase)
		if (regex.Find(phrase))
			return null
		return phrase

ABSTRACT_TYPE(/datum/phrase_log_cleaner/clean)
/datum/phrase_log_cleaner/clean
	clean(phrase)
		return regex.Replace(phrase)

/datum/phrase_log_cleaner/clean/mutable
	New()
		. = ..()
		regex = regex(@{"\<(\/)?(im)?mutable\>"}, "g")

//https://stackoverflow.com/a/1732454
/datum/phrase_log_cleaner/html
	var/static/list/exempt_categories = list("paper")
	clean(phrase, category)
		//TODO: store this somewhere sensible
		if (category in src.exempt_categories)
			return phrase
		return strip_html_tags(phrase)
