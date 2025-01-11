/obj/artifact/forcefield_generator
	name = "artifact forcefield generator"
	associated_datum = /datum/artifact/forcefield_gen

/datum/artifact/forcefield_gen
	associated_object = /obj/artifact/forcefield_generator
	type_name = "Forcefield Generator"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 450
	validtypes = list("wizard","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/carbon_touch,
	/datum/artifact_trigger/silicon_touch)
	fault_blacklist = list(ITEM_ONLY_FAULTS)
	activated = 0
	activ_text = "comes to life, projecting out a wall of force!"
	deact_text = "shuts down, causing the forcefield to vanish!"
	react_xray = list(13,60,95,11,"NONE")
	combine_flags = ARTIFACT_DOES_NOT_COMBINE
	var/cooldown = 80
	var/field_radius = 3
	var/field_time = 80
	var/icon_state = "shieldsparkles"
	var/next_activate = 0
	var/list/forcefields = list()
	shard_reward = ARTIFACT_SHARD_POWER

	New()
		..()
		src.icon_state = pick("shieldsparkles","empdisable","greenglow","enshield","energyorb","forcewall","meteor_shield")
		src.field_radius = rand(2,6) // forcefield radius
		src.field_time = rand(15,1500) // forcefield duration
		src.cooldown = rand(50, 1200)
		src.activ_sound = pick('sound/effects/mag_forcewall.ogg','sound/effects/mag_warp.ogg','sound/effects/MagShieldUp.ogg')
		src.deact_sound = pick('sound/effects/MagShieldDown.ogg','sound/effects/shielddown2.ogg','sound/effects/singsuck.ogg')

	may_activate(var/obj/O)
		if (!..())
			return 0
		if (ticker.round_elapsed_ticks < next_activate)
			O.visible_message(SPAN_ALERT("[O] emits a loud pop and lights up momentarily but nothing happens!"))
			return 0
		return 1

	effect_activate(var/obj/O,var/mob/living/user)
		if (..())
			return
		O.anchored = ANCHORED
		var/turf/Aloc = get_turf(O)
		for (var/turf/T in range(field_radius,Aloc))
			if(GET_DIST(O,T) == field_radius)
				var/obj/forcefield/wand/FF = new /obj/forcefield/wand(T,0,src.icon_state,O)
				src.forcefields += FF
		SPAWN(field_time)
			if (O)
				O.ArtifactDeactivated()

	effect_deactivate(obj/O)
		if(..())
			return
		O.anchored = UNANCHORED
		for (var/obj/forcefield/F in src.forcefields)
			src.forcefields -= F
			qdel(F)
		next_activate = ticker.round_elapsed_ticks + cooldown
