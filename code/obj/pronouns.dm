/proc/pronouns_filter_is_choosable(var/P)
	var/datum/pronouns/pronouns = get_singleton(P)
	return pronouns.choosable

ABSTRACT_TYPE(/datum/pronouns)
/datum/pronouns
	var/name
	var/preferredGender
	var/subjective
	var/objective
	var/possessive
	var/posessivePronoun
	var/reflexive
	var/pluralize = FALSE
	var/choosable = TRUE

/datum/pronouns/theyThem
	name = "they/them"
	preferredGender = "person"
	subjective = "they"
	objective = "them"
	possessive = "their"
	posessivePronoun = "theirs"
	reflexive = "themself"
	pluralize = TRUE

/datum/pronouns/heHim
	name = "he/him"
	preferredGender = "man"
	subjective = "he"
	objective = "him"
	possessive = "his"
	posessivePronoun = "his"
	reflexive = "himself"

/datum/pronouns/sheHer
	name = "she/her"
	preferredGender = "woman"
	subjective = "she"
	objective = "her"
	possessive = "her"
	posessivePronoun = "hers"
	reflexive = "herself"

/datum/pronouns/abomination
	name = "abomination"
	preferredGender = "abomination"
	subjective = "we"
	objective = "us"
	possessive = "our"
	posessivePronoun = "ours"
	reflexive = "ourself"
	pluralize = TRUE
	choosable = FALSE
