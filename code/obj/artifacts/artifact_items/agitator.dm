/obj/item/artifact/agitator
	name = "artifact agitator"
	associated_datum = /datum/artifact/agitator

	afterattack(atom/target, mob/user, reach, params)
		var/datum/artifact/agitator/src_art = src.artifact
		if (!src_art.activated)
			return ..()
		var/obj/O = target
		if (!istype(O) || !O.artifact)
			return ..()
		if (!O.artifact.activated)
			return ..()
		. = ..()
		if (ON_COOLDOWN(src, "artifact_agitation", rand(30, 180) SECONDS))
			boutput(user, SPAN_NOTICE("[src] doesn't seem to do anything. Hm."))
			return

		var/datum/artifact/artifact = O.artifact
		if (length(artifact.faults))
			artifact.faults -= pick(artifact.faults)
			if (prob(5))
				for (var/i in 1 to rand(1, 3))
					O.ArtifactDevelopFault(100)
			else
				O.ArtifactDevelopFault(100)
		else
			O.ArtifactDevelopFault(100) // bad effect guaranteed if fault didn't exist before

		for (var/datum/artifact_fault/fault in artifact.faults)
			if (fault.trigger_prob == initial(fault.trigger_prob))
				fault.trigger_prob *= 10

		playsound(get_turf(src), pick(src_art.artitype.activation_sounds), 30, TRUE)

/datum/artifact/agitator
	associated_object = /obj/item/artifact/agitator
	type_name = "Agitator"
	type_size = ARTIFACT_SIZE_MEDIUM
	rarity_weight = 200
	validtypes = list("precursor")
	react_xray = list(9, 55, 95, 8, "ANOMALOUS")
	examine_hint = "It seems to have a handle you're supposed to hold it by."
