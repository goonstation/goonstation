ABSTRACT_TYPE(/datum/wraith_name_generator)
/datum/wraith_name_generator
	/// The list of possible strings to add before the name.
	var/list/prefixes = null
	/// The list of possible strings to add after the name.
	var/list/suffixes = null
	/// The list of consonants or consonant-likes that the generator may pick from.
	var/list/consonants = null
	/// The list of vowels or vowel-likes that the generator may pick from.
	var/list/vowels = null
	/// The lower bound of the name length.
	var/lower_name_length = null
	/// The upper bound of the name length.
	var/upper_name_length = null
	/// The lower bound of the vowel probability added with each letter.
	var/lower_vowel_prob = null
	/// The upper bound of the vowel probability added with each letter.
	var/upper_vowel_prob = null

/// Generate the wraith name.
/datum/wraith_name_generator/proc/generate_name()
	var/name = ""
	var/vowel_prob = 0

	for (var/i in 1 to rand(src.lower_name_length, src.upper_name_length))
		if (prob(vowel_prob))
			vowel_prob = 0
			name += pick(src.vowels)
		else
			vowel_prob += rand(src.lower_vowel_prob, src.upper_vowel_prob)
			name += pick(src.consonants)

	if (global.phrase_log.is_uncool(name))
		return src.generate_name()

	return pick(src.prefixes) + capitalize(name) + pick(src.suffixes)


/datum/wraith_name_generator/wraith
#ifndef APRIL_FOOLS
	suffixes = list(" the Impaler", " the Tormentor", " the Forsaken", " the Destroyer", " the Devourer", " the Tyrant", " the Overlord", " the Damned", " the Desolator", " the Exiled")
	consonants = list("x", "z", "n", "k", "s", "l", "t", "r", "sh", "m", "d")
#else
	suffixes = list(" the Jimpaler", " the Jormentor", " the Jorsaken", " the Jestroyer", " the Jevourer", " the Jyrant", " the Joverlord", " the Jamned", " the Jesolator", " the Jexiled")
	consonants = list("x", "z", "n", "k", "s", "l", "t", "r", "sh", "m", "d", "j", "j", "j", "j", "j", "j", "j", "j")
#endif
	vowels = list("a", "ae", "o", "u", "ou", "y")
	lower_name_length = 4
	upper_name_length = 8
	lower_vowel_prob = 15
	upper_vowel_prob = 40


/datum/wraith_name_generator/poltergeist
	suffixes = list(" the Poltergeist", " the Mischievous", " the Playful", " the Trickster", " the Sneaky", " the Child", " the Kid", " the Ass", " the Inquisitive", " the Exiled")
	consonants = list("h", "n", "k", "s", "l", "t", "r", "sh", "m", "d")
	vowels = list("a", "i", "o", "u", "ou")
	lower_name_length = 4
	upper_name_length = 6
	lower_vowel_prob = 15
	upper_vowel_prob = 40

/datum/wraith_name_generator/poltergeist/generate_name()
	if (prob(2))
		return pick(src.prefixes) + pick("Peeves", "Peevs", "Peves", "Casper") + pick(src.suffixes)

	. = ..()


/datum/wraith_name_generator/plague_rat
	prefixes = list("Rat ")
	consonants = list("nj", "sh", "gu", "h", "l", "t", "r", "m", "d")
	vowels = list("ai", "ae", "o", "u", "ou")
	lower_name_length = 3
	upper_name_length = 4
	lower_vowel_prob = 50
	upper_vowel_prob = 70


/datum/wraith_name_generator/wraith_summon
	prefixes = list("Summon ")
	consonants = list("x", "z", "n", "k", "s", "l", "t", "r", "sh", "m", "d")
	vowels = list("a", "ae", "o", "u", "ou", "y")
	lower_name_length = 4
	upper_name_length = 6
	lower_vowel_prob = 40
	upper_vowel_prob = 70


/datum/wraith_name_generator/wraith_summon/spiker
	prefixes = list("Spiker ")


/datum/wraith_name_generator/wraith_summon/hound
	prefixes = list("Hound ")


/datum/wraith_name_generator/wraith_summon/commander
	prefixes = list("Commander ")
