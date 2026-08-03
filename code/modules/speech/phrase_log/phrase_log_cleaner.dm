ABSTRACT_TYPE(/datum/phrase_log_cleaner)
/datum/phrase_log_cleaner
	var/regex/regex
	// Returns the new cleaned phrase or null if the phrase should be removed
	proc/clean(phrase)
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

