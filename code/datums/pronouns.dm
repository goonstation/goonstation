/proc/pronouns_filter_is_choosable(var/P)
	var/datum/pronouns/pronouns = get_singleton(P)
	return pronouns.choosable

/proc/choose_pronouns(mob/user, message, title, default="None")
	RETURN_TYPE(/datum/pronouns)
	var/list/types = filtered_concrete_typesof(/datum/pronouns, /proc/pronouns_filter_is_choosable)
	var/list/choices = list()
	for(var/t in types)
		var/datum/pronouns/pronouns = get_singleton(t)
		choices[pronouns.name] = pronouns
	choices["None"] = null
	var/choice = input(user, message, title, default) as null|anything in choices
	if(isnull(choice))
		return choice
	return choices[choice]

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

	proc/next_pronouns()
		RETURN_TYPE(/datum/pronouns)
		var/list/types = filtered_concrete_typesof(/datum/pronouns, /proc/pronouns_filter_is_choosable)
		var/selected
		for (var/i = 1, i <= length(types), i++)
			var/datum/pronouns/pronouns = get_singleton(types[i])
			if (src == pronouns)
				selected = i
				break
		return get_singleton(types[selected < length(types) ? selected + 1 : 1])

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

/datum/pronouns/itIts
	name = "it/its"
	preferredGender = "neuter"
	subjective = "it"
	objective = "it"
	possessive = "its"
	posessivePronoun = "its"
	reflexive = "itself"
	choosable = TRUE
