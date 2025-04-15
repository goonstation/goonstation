// TRIGGERS

ABSTRACT_TYPE(/datum/artifact_trigger/)
/datum/artifact_trigger
	var/type_name = "bad artifact code"
	/// Stimulus string used in `ArtifactStimulus`
	var/stimulus_required = null
	/// If TRUE, checks the stimulus for a specific unit amount
	var/do_amount_check = 1
	/// Value needed to activate the trigger
	var/stimulus_amount = null
	/// Comparison operator used to check against stimulus
	var/stimulus_type = ">="
	/// Range +- the stimulous amount where hints will be given
	var/hint_range = 0
	/// Probability a hint will be dispensed
	var/hint_prob = 33
	/// Whether this artifact trigger is in use
	var/used = 1

/datum/artifact_trigger/carbon_touch
	// touched by a carbon lifeform
	type_name = "Carbon Touch"
	stimulus_required = "carbtouch"
	do_amount_check = 0

/datum/artifact_trigger/silicon_touch
	// touched by a silicon lifeform
	type_name = "Silicon Touch"
	stimulus_required = "silitouch"
	do_amount_check = 0

/datum/artifact_trigger/force
	type_name = "Physical Force"
	stimulus_required = "force"
	hint_range = 20
	hint_prob = 75

	New()
		..()
		stimulus_amount = rand(3,30)

/datum/artifact_trigger/heat
	type_name = "Heat"
	stimulus_required = "heat"
	hint_range = 20

	New()
		..()
		stimulus_amount = rand(320,400)

/datum/artifact_trigger/cold
	type_name = "Cold"
	stimulus_required = "heat"
	stimulus_type = "<="
	hint_range = 20

	New()
		..()
		stimulus_amount = rand(200,300)

/datum/artifact_trigger/radiation
	type_name = "Radiation"
	stimulus_required = "radiate"
	hint_range = 2
	hint_prob = 75

	New()
		..()
		stimulus_type = pick(">=","<=")
		stimulus_amount = rand(1,10)

/datum/artifact_trigger/electric
	type_name = "Electricity"
	stimulus_required = "elec"
	hint_range = 500
	hint_prob = 66

	New()
		..()
		stimulus_type = pick(">=","<=")
		stimulus_amount = rand(5,5000)

/datum/artifact_trigger/reagent
	type_name = "Chemicals"
	stimulus_required = "reagent"
	// can just use the above var as the required reagent field really
	stimulus_type = ">="
	hint_range = 50
	hint_prob = 100
	used = 0

	New()
		..()
		stimulus_amount = rand(10,100)

/datum/artifact_trigger/reagent/blood
	type_name = "Blood"
	stimulus_required = "blood"
	used = 0

/datum/artifact_trigger/data
	// touched by something that contains data (circuit board, disks) etc.
	type_name = "Data"
	stimulus_required = "data"
	do_amount_check = 0

/datum/artifact_trigger/language
	type_name = "Language"
	stimulus_required = "language"
	hint_prob = 0 // uses custom way of giving hint
	do_amount_check = FALSE
	// number of vowels in picked word
	var/num_vowels = 0
	// positions of vowels in picked word
	var/list/positions = list()
	// list of all valid words
	var/static/word_dict = null
	var/static/list/vowels = list("a", "e", "i", "o", "u")

	New()
		..()
		if (!src.word_dict)
			// need to account for words with no vowels
			src.word_dict = dd_file2list("strings/letter_words_5.txt", " ")
		var/picked_word = pick(src.word_dict)
		for (var/i = 1 to 5)
			if (picked_word[i] in src.vowels)
				src.positions += "v" // vowel
				src.num_vowels += 1
			else
				src.positions += "c" // consonant

	proc/speech_act(text)
		if (!text)
			return
		text = ckey(text[1])
		if (length(text) != 5)
			return "hint"
		if (!(text in src.word_dict))
			return "error"
		var/input_vowels = 0
		var/correct_vowels = 0
		var/misplaced_vowels = 0
		for (var/i = 1 to 5)
			if (text[i] in src.vowels)
				input_vowels += 1
				if (src.positions[i] == "v")
					correct_vowels += 1

		if (input_vowels > src.num_vowels)
			return " emits a [SPAN_BOLD("grumpy")] chime."
		if (correct_vowels == src.num_vowels)
			return "correct"
		misplaced_vowels = input_vowels - correct_vowels

		var/correct_vowel_msg = "[correct_vowels == 1 ? "a <b>high</b> chime" : "a series of [correct_vowels] <b>high</b> chimes"]"
		var/misplaced_vowel_msg = "[misplaced_vowels == 1 ? "a <b>low</b> chime" : "a series of [misplaced_vowels] <b>low</b> chimes"]"

		if (correct_vowels > 0 && misplaced_vowels > 0)
			return " emits [correct_vowel_msg] and [misplaced_vowel_msg]."
		if (correct_vowels > 0)
			return " emits [correct_vowel_msg]."
		return " emits [misplaced_vowel_msg]."

/datum/artifact_trigger/credits
	type_name = "Credits"
	stimulus_required = "credits"
	hint_range = 500

	New()
		. = ..()
		src.stimulus_amount = 100 * rand(5,15)
		src.stimulus_type = pick("<=", ">=")
