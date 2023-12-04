// TRIGGERS

ABSTRACT_TYPE(/datum/artifact_trigger/)
/datum/artifact_trigger
	var/type_name = "bad artifact code"
	var/stimulus_required = null
	var/do_amount_check = 1
	var/stimulus_amount = null
	var/stimulus_type = ">="
	var/hint_range = 0
	var/hint_prob = 33
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

/datum/artifact_trigger/note
	type_name = "Music"
	stimulus_required = "note"
	do_amount_check = FALSE
	hint_prob = 0 // uses custom hint
	/// musical note needed to activate the artifact
	var/triggering_note

	New()
		..()
		var/letter = pick("c", "d", "e", "f", "g")
		var/sharp = prob(75) ? null : "-"
		var/num = pick(rand(2, 7))
		if (letter == "c" && num == 7)
			sharp = null
		else if (letter != "c" && num == 7)
			num = pick(rand(2, 6))

		src.triggering_note = "[letter][sharp][num]"

	// returns similarity of a given note to the triggering note
	// returns -1 for note1 lower than src note, 0 for equal, 1 for note1 higher than src note, 2 for just a # difference
	proc/get_similarity(note1)
		var/note2 = src.triggering_note // just for readability
		// notes the same
		if (note1 == note2)
			return 0
		// notes have no sharps
		if (note1[2] != "-" && note2[2] != "-")
			return cmp_text_dsc(note1, note2)
		// only note 1 has a sharp
		if (note1[2] == "-" && note2[2] != "-")
			var/result = cmp_text_dsc("[note1[1]][note1[3]]", "[note2[1]][note2[2]]")
			if (result == 0)
				return 2
			return result
		// only note 2 has a sharp
		if (note1[2] != "-" && note2[2] == "-")
			var/result = cmp_text_dsc("[note1[1]][note1[2]]", "[note2[1]][note2[3]]")
			if (result == 0)
				return 2
			return result
		// both notes have a sharp
		return cmp_text_dsc("[note1[1]][note1[3]]", "[note2[1]][note2[3]]")
