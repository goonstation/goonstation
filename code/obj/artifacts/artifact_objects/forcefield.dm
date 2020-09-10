/obj/artifact/forcefield_generator
	name = "artifact forcefield generator"
	associated_datum = /datum/artifact/forcefield_gen

/datum/artifact/forcefield_gen
	associated_object = /obj/artifact/forcefield_generator
	rarity_class = 1
	validtypes = list("wizard","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/carbon_touch,
	/datum/artifact_trigger/silicon_touch)
	activated = 0
	activ_text = "comes to life, projecting out a wall of force!"
	deact_text = "shuts down, causing the forcefield to vanish!"
	react_xray = list(13,60,95,11,"NONE")
	var/cooldown = 80
	var/field_radius = 3
	var/field_time = 80
	var/icon_state = "shieldsparkles"
	var/next_activate = 0

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
			O.visible_message("<span class='alert'>[O] emits a loud pop and lights up momentarily but nothing happens!</span>")
			return 0
		return 1

	effect_activate(var/obj/O,var/mob/living/user)
		if (..())
			return
		O.anchored = 1
		var/turf/Aloc = get_turf(O)
		var/list/forcefields = list()
		for (var/turf/T in range(field_radius,Aloc))
			if(get_dist(O,T) == field_radius)
				var/obj/forcefield/wand/FF = new /obj/forcefield/wand(T,0,src.icon_state)
				forcefields += FF
		SPAWN_DBG(field_time)
			for (var/obj/forcefield/F in forcefields)
				forcefields -= F
				qdel(F)
			next_activate = ticker.round_elapsed_ticks + cooldown
			if (O)
				O.ArtifactDeactivated()
				O.anchored = 0
