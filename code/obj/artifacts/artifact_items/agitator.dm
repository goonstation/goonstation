/obj/item/artifact/agitator
	name = "artifact agitator"
	associated_datum = /datum/artifact/agitator
	var/use_cd

	New()
		..()
		src.use_cd = rand(30, 60) SECONDS

/datum/artifact/agitator
	associated_object = /obj/item/artifact/agitator
	type_name = "Agitator"
	type_size = ARTIFACT_SIZE_MEDIUM
	rarity_weight = 350
	validtypes = list("lattice")
	react_xray = list(9, 55, 95, 8, "ANOMALOUS")
	examine_hint = "It seems to have a handle you're supposed to hold it by."

	effect_attack_atom(obj/art, mob/living/user, atom/A)
		if (..())
			return
		var/obj/item/artifact/agitator/agitator = art
		var/obj/O = A
		if (!istype(O) || !O.artifact)
			return
		if (!O.artifact.activated)
			return
		if (O.artifact.artitype.name == "lattice" || ON_COOLDOWN(agitator, "artifact_agitation", agitator.use_cd)) // lattice doesn't develop faults
			boutput(user, SPAN_NOTICE("[art] doesn't seem to do anything. Hm."))
			return

		var/datum/artifact/artifact = O.artifact
		if (length(artifact.faults))
			artifact.faults -= pick(artifact.faults)
			if (prob(5))
				for (var/i in 1 to rand(1, 3))
					O.ArtifactDevelopFault(100)
				boutput(user, SPAN_ALERT("[art] burns your hand! Fuck that hurt!"))
				user.TakeDamage("All", burn = rand(1, 10))
			else
				O.ArtifactDevelopFault(100)
		else
			O.ArtifactDevelopFault(100) // bad effect guaranteed if fault didn't exist before

		for (var/datum/artifact_fault/fault in artifact.faults)
			if (fault.trigger_prob == initial(fault.trigger_prob))
				fault.trigger_prob *= 10

		playsound(get_turf(art), pick(src.artitype.activation_sounds), 30, TRUE)
		boutput(user, SPAN_ALERT("[art] suddenly darkens, then returns to its regular color."))
		animate(art, 1 SECOND, color = "#000000")
		SPAWN(4 SECONDS)
			animate(art, 1 SECOND, color = null)
		SPAWN(agitator.use_cd)
			if (QDELETED(art))
				return
			var/turf/T = get_turf(art)
			T.visible_message(SPAN_ALERT("[art] vibrates alarmingly!"))
