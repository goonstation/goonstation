/obj/item/artifact/archivist
	name = "artifact archivist"
	associated_datum = /datum/artifact/archivist

	afterattack(atom/target, mob/user, reach, params)
		var/datum/artifact/compass/art = src.artifact
		if (!art.activated)
			return ..()
		. = ..()
		var/obj/O = target
		if (!istype(O) || !O.artifact)
			src.say("[O] is not an artifact, results inconclusive.")
		else if (O.artifact.activated)
			var/datum/artifact_trigger/activating_trigger = O.artifact.triggers[1]
			var/list/art_faults = list()
			for (var/datum/artifact_fault/fault in O.artifact.faults)
				art_faults += fault.type_name
			src.say("Analysis results:")
			sleep(0.1 SECONDS)
			src.say("Origin disguised: [O.artifact.disguised ? "Yes" : "No"]")
			sleep(0.1 SECONDS)
			src.say("Activation method: [art.trigger_names_assoc[activating_trigger.type]]")
			sleep(0.1 SECONDS)
			src.say("Faults: [length(art_faults) ? english_list(art_faults) : "None"]")
			sleep(0.1 SECONDS)
			//src.say("Artifacts combined: [length(O.combined_artifacts) || 0]"))
		else
			if ("\ref[O]" in art.scanned_artifacts)
				for (var/str in art.scanned_artifacts["\ref[O]"])
					src.say(str)
					sleep(0.1 SECONDS)
			else
				if (length(O.artifact.triggers))
					var/datum/artifact_trigger/activating_trigger = O.artifact.triggers[1]
					var/list/possible_triggers = list(activating_trigger.type_name)
					var/list/other_triggers = art.trigger_names.Copy() - list(activating_trigger.type_name)
					for (var/i in 1 to 2)
						var/trigger = pick(other_triggers)
						other_triggers -= trigger
						possible_triggers += trigger
					shuffle_list(possible_triggers)
					art.scanned_artifacts["\ref[O]"] = list("Analysis results:",
						"Possible activation methods: [english_list(possible_triggers)]")
				else
					art.scanned_artifacts["\ref[O]"] = list("Analysis results:",
						"Possible activation methods: None")
				for (var/str in art.scanned_artifacts["\ref[O]"])
					src.say(str)
					sleep(0.1 SECONDS)

/datum/artifact/archivist
	associated_object = /obj/item/artifact/archivist
	type_name = "Archivist"
	type_size = ARTIFACT_SIZE_MEDIUM
	rarity_weight = 200
	validtypes = list("precursor")
	validtriggers = list(/datum/artifact_trigger/language)
	react_xray = list(16, 45, 95, 8, "ANOMALOUS")
	examine_hint = "It seems to have a handle you're supposed to hold it by."
	var/static/list/trigger_names = list()
	var/static/list/trigger_names_assoc = list()
	var/list/scanned_artifacts = list()

	New()
		..()
		if (!length(src.trigger_names))
			for (var/datum/artifact_trigger/trigger_type as anything in concrete_typesof(/datum/artifact_trigger))
				if (initial(trigger_type.used))
					src.trigger_names += initial(trigger_type.type_name)
					src.trigger_names_assoc[trigger_type] = initial(trigger_type.type_name)
