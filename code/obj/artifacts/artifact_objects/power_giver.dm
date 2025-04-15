/obj/artifact/power_giver
	name = "artifact power giver"
	associated_datum = /datum/artifact/power_giver

/datum/artifact/power_giver
	associated_object = /obj/artifact/power_giver
	type_name = "Mutator"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 200
	validtypes = list("martian","wizard","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch,
	/datum/artifact_trigger/cold, /datum/artifact_trigger/language, /datum/artifact_trigger/credits)
	fault_blacklist = list(ITEM_ONLY_FAULTS)
	activ_text = "begins glowing with an eerie light!"
	deact_text = "falls dark and quiet."
	react_xray = list(10,90,80,10,"NONE")
	var/power_granted = null
	var/power_time = 0
	var/recharge_time = 300
	var/ready = 1

	New()
		..()
		power_granted = pick("blind","mute","clumsy","fire_resist","cold_resist","resist_electric",
		"psy_resist","glowy","hulk","xray","horns","stinky","monkey","mattereater","jumpy","telepathy","empath",
		"immolate","eyebeams","melt","accent_uwu","accent_zalgo", "bingus")
		if(prob(2) && length(global.mutini_effects))
			power_granted = pick(global.mutini_effects)
		power_time = rand(30,180)
		if (prob(5))
			power_time = 0
		recharge_time = rand(100,600)
		if (prob(5))
			recharge_time = 0

	effect_touch(var/obj/O,var/mob/living/user)
		if (..())
			return
		if (!iscarbon(user))
			return
		if (user.bioHolder && ready)
			var/turf/T = get_turf(O)
			T.visible_message("<b>[O]</b> envelops [user] in a strange light!")
			user.bioHolder.AddEffect(power_granted,0,power_time)
			O.ArtifactFaultUsed(user)
			if (recharge_time > 0)
				ready = 0
				SPAWN(recharge_time)
					T.visible_message("<b>[O]</b> begins to glow again.")
					ready = 1
