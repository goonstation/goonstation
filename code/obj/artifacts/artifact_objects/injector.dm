/obj/artifact/injector
	name = "artifact injector"
	associated_datum = /datum/artifact/injector

/datum/artifact/injector
	associated_object = /obj/artifact/injector
	type_name = "Injector"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 350
	validtypes = list("ancient","martian","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch,
	/datum/artifact_trigger/cold, /datum/artifact_trigger/language,/datum/artifact_trigger/credits)
	fault_blacklist = list(ITEM_ONLY_FAULTS)
	activ_text = "opens up, revealing an array of strange needles!"
	deact_text = "closes itself up."
	react_xray = list(8,60,75,11,"SEGMENTED")
	var/list/injection_reagents = list()
	var/injection_amount = 10

	post_setup()
		. = ..()
		var/list/potential_reagents = list()
		switch(artitype.name)
			if ("ancient")
				// industrial heavy machinery kinda stuff
				potential_reagents = list("nanites","liquid plasma","mercury","lithium","plasma","radium","uranium","cryostylane")
			if ("martian")
				// medicine, some poisons, some gross stuff
				potential_reagents = list("charcoal","salbutamol","anti_rad","synaptizine","omnizine","synthflesh",
				"cyanide","ketamine","toxin","neurotoxin","solipsizine","neurodepressant","mutagen","fake_initropidril",
				"toxic_slurry","space_fungus","blood","meat_slurry")
			if ("eldritch")
				// all the worst stuff. all of it
				potential_reagents = list("chlorine","hyper_vomitium","fluorine","lithium","mercury","plasma","radium","uranium","strange_reagent",
				"amanitin","coniine","cyanide","curare",
				"formaldehyde","lipolicide","initropidril","cholesterol","itching","pancuronium","polonium",
				"sodium_thiopental","ketamine","sulfonal","toxin","cytotoxin","neurotoxin","mutagen","wolfsbane",
				"toxic_slurry","histamine","saxitoxin","hemotoxin","ricin","tetrodotoxin")
			else
				// absolutely everything
				potential_reagents = all_functional_reagent_ids

		if (length(potential_reagents) > 0)
			var/looper = rand(1,3)
			while (looper > 0)
				looper--
				injection_reagents += pick(potential_reagents)

		injection_amount = rand(3,25)

	effect_touch(var/obj/O,var/mob/living/user)
		if (..())
			return
		if (user.reagents && length(injection_reagents) > 0)
			var/turf/T = get_turf(O)
			T.visible_message("<b>[O]</b> jabs [user] with a needle and injects something!")
			for (var/X in injection_reagents)
				ArtifactLogs(user, null, O, "touched by [user.real_name]", "injecting [X]", 0) // Added (Convair880).
				user.reagents.add_reagent(X,injection_amount)
		O.ArtifactFaultUsed(user)
