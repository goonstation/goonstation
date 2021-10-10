var/global/obj/pronouns/theyThem/pronouns_theyThem = new /obj/pronouns/theyThem
var/global/obj/pronouns/heHim/pronouns_heHim = new /obj/pronouns/heHim
var/global/obj/pronouns/sheHer/pronouns_sheHer = new /obj/pronouns/sheHer
var/global/obj/pronouns/abomination/pronouns_abomination = new /obj/pronouns/abomination

/obj/pronouns
	var/preferredGender
	var/subjective
	var/objective
	var/possessive
	var/posessivePronoun
	var/reflexive
	var/pluralize = FALSE

/obj/pronouns/theyThem
	name = "they/them"
	preferredGender = "person"
	subjective = "they"
	objective = "them"
	possessive = "their"
	posessivePronoun = "theirs"
	reflexive = "themself"
	pluralize = TRUE

/obj/pronouns/heHim
	name = "he/him"
	preferredGender = "man"
	subjective = "he"
	objective = "him"
	possessive = "his"
	posessivePronoun = "his"
	reflexive = "himself"

/obj/pronouns/sheHer
	name = "she/her"
	preferredGender = "woman"
	subjective = "she"
	objective = "her"
	possessive = "her"
	posessivePronoun = "hers"
	reflexive = "herself"

/obj/pronouns/abomination
	name = "abomination"
	preferredGender = "abomination"
	subjective = "we"
	objective = "us"
	possessive = "our"
	posessivePronoun = "ours"
	reflexive = "ourself"
	pluralize = TRUE
