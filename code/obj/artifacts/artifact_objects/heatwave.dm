
/obj/artifact/heatwave
	name = "artifact heatwave"
	associated_datum = /datum/artifact/heatwave

/datum/artifact/heatwave
	associated_object = /obj/artifact/heatwave
	type_name = "Heat Surge"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 365
	validtypes = list("ancient","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch,/datum/artifact_trigger/heat,
		/datum/artifact_trigger/language)
	fault_blacklist = list(ITEM_ONLY_FAULTS,TOUCH_ONLY_FAULTS)
	activ_text = "starts emitting HUGE flames!"
	deact_text = "stops emitting flames."
	react_xray = list(12,35,85,5,"POROUS") //has pores for flames idk
	examine_hint = "It is covered in very conspicuous markings."
	shard_reward = ARTIFACT_SHARD_POWER
	combine_flags = ARTIFACT_ACCEPTS_ANY_COMBINE
	var/recharge_time = 20 SECONDS
	var/fire_range = 4
	var/temperature = 7000 KELVIN
	var/fire_color

	post_setup()
		..()
		switch(artitype.name)
			if ("precursor")
				fire_range = rand(2,18) // What could possibly go wrong? (Note; chemistry might explode)
				temperature = rand(1000, 10000) KELVIN
			else
				fire_range = rand(2,6)
				temperature = rand(4000, 8900) KELVIN

		switch(artitype.name)
			if ("ancient")
				src.fire_color = pick(CHEM_FIRE_RED, CHEM_FIRE_BLACK, CHEM_FIRE_WHITE)
			if ("eldritch")
				src.fire_color = pick(CHEM_FIRE_RED, CHEM_FIRE_DARKRED, CHEM_FIRE_PURPLE)
			if ("precursor")
				src.fire_color = pick(CHEM_FIRE_RED, CHEM_FIRE_BLUE, CHEM_FIRE_GREEN)

	effect_activate(var/obj/O)
		if (..())
			return
		if (ON_COOLDOWN(O, "heatwave" , recharge_time))
			O.ArtifactDeactivated()
			return
		var/turf/T = get_turf(O)
		playsound(O.loc, 'sound/effects/mag_fireballlaunch.ogg', 50, 0)
		T.visible_message(SPAN_ALERT("<b>[O]</b> erupts into a huge column of flames! Holy shit!"))
		fireflash_melting(T, fire_range, temperature, temperature / fire_range, chemfire = src.fire_color)
		SPAWN(3 SECONDS)
			O.ArtifactDeactivated()
