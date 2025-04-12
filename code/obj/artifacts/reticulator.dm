/obj/item/artifact_resonator
	name = "Artifact resonator"
	desc = "A useful device to assist in activating artifacts. It has the ability to detect disguised origin artifacts, as well as possible activation methods."
	icon = 'icons/obj/artifacts/reticulator.dmi'
	icon_state = "resonator"
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

	afterattack(atom/target, mob/user, reach, params)
		..()
		var/obj/O = target
		if (!istype(O) || !O.artifact)
			boutput(user, SPAN_NOTICE("[O] is not an artifact, results inconclusive."))
		else if (O.artifact.activated)
			var/datum/artifact_trigger/activating_trigger = O.artifact.triggers[1]
			boutput(user, SPAN_NOTICE("Analysis results:" + \
				"<br>Origin disguised: <B>[O.artifact.disguised ? "Yes" : "No"]</B>" + \
				"<br>Activation method: <B>[src.trigger_names_assoc[activating_trigger.type]]</B>" + \
				"<br>Artifacts combined: <B>[length(O.combined_artifacts) || 0]</B>"))
		else
			if ("\ref[O]" in src.scanned_artifacts)
				boutput(user, src.scanned_artifacts["\ref[O]"])
			else
				var/datum/artifact_trigger/activating_trigger = O.artifact.triggers[1]
				var/list/possible_triggers = list(activating_trigger.type_name)
				var/list/other_triggers = src.trigger_names.Copy() - list(activating_trigger.type_name)
				for (var/i in 1 to 2)
					var/trigger = pick(other_triggers)
					other_triggers -= trigger
					possible_triggers += trigger
				shuffle_list(possible_triggers)
				src.scanned_artifacts["\ref[O]"] = SPAN_NOTICE("Analysis results:" + \
					"<br>Origin disguised: <B>[O.artifact.disguised ? "Yes" : "No"]</B>" + \
					"<br>Possible activation methods: <B>[english_list(possible_triggers)]</B>")
				boutput(user, src.scanned_artifacts["\ref[O]"])

		if (!ON_COOLDOWN(src, "scan_sound", 2 SECONDS))
			playsound(get_turf(src), 'sound/items/reticulator-resonator_scan.ogg', 25, TRUE)


/obj/item/artifact_tuner
	name = "Artifact tuner"
	desc = "A device loaded with a one-time use charge that will randomly alter the faults of an activated artifact."
	icon = 'icons/obj/artifacts/reticulator.dmi'
	icon_state = "tuner"
	var/used = FALSE

	afterattack(atom/target, mob/user, reach, params)
		..()
		if (src.used)
			return
		var/obj/O = target
		if (!istype(O) || !O.artifact)
			boutput(user, SPAN_NOTICE("[O] is not an artifact, [src] will have no effect."))
			return
		if (!O.artifact.activated)
			boutput(user, SPAN_NOTICE("[O] is not activated, [src] will have no effect."))
			return
		var/datum/artifact/artifact = O.artifact
		if (length(artifact.faults))
			if (prob(90))
				artifact.faults -= pick(artifact.faults)
			if (prob(5))
				for (var/i in 1 to rand(1, 3))
					O.ArtifactDevelopFault(100)
			else
				O.ArtifactDevelopFault(100)
		else
			O.ArtifactDevelopFault(100) // bad effect guaranteed if fault didn't exist before

		playsound(get_turf(src), 'sound/items/reticulator-tuner_scramble.ogg', 30, TRUE)

		src.name = "Used artifact tuner"
		src.desc = "A used artifact tuner. It has no more use and can be thrown away."
		src.icon_state = "tuner-used"
		src.used = TRUE
