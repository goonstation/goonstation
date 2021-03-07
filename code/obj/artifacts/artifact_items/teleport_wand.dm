/obj/item/artifact/teleport_wand
	name = "artifact teleport wand"
	artifact = 1
	associated_datum = /datum/artifact/telewand
	flags =  FPRINT | CONDUCT | EXTRADELAY
	module_research_no_diminish = 1

	// this is necessary so that this returns null
	// else afterattack will not be called when out of range
	pixelaction(atom/target, params, mob/user, reach)
		..()

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
		if (!src.ArtifactSanityCheck())
			return
		var/datum/artifact/telewand/A = src.artifact
		if (!istype(A))
			return

		var/turf/U = (istype(target, /atom/movable) ? target.loc : target)
		//var/turf/T = get_turf(target)
		if (A.activated)
			if (A.can_teleport_here(U))
				A.effect_click_tile(src,user,U)
			else
				boutput(user, "<b>[src]</b> [A.error_phrase]")
			src.ArtifactFaultUsed(user)

/datum/artifact/telewand
	associated_object = /obj/item/artifact/teleport_wand
	type_name = "Teleportation Wand"
	rarity_weight = 200
	validtypes = list("wizard","eldritch","precursor")
	react_xray = list(10,75,90,11,"ANOMALOUS")
	var/sound/wand_sound = 'sound/effects/mag_warp.ogg'
	var/on_cooldown = 0
	var/cooldown_delay = 0
	var/particle_color = "#000000"
	var/particle_sprite = ""
	var/recharge_phrase = ""
	var/error_phrase = ""
	examine_hint = "It seems to have a handle you're supposed to hold it by."
	module_research = list("energy" = 15, "engineering" = 3, "science" = 8)
	module_research_insight = 4

	New()
		..()
		particle_color = copytext(random_color(),1,0)
		particle_sprite = pick("8x8circle","8x8ring","8x8triangle","8x8square","8x8bubblegrid")
		wand_sound = pick('sound/effects/mag_warp.ogg','sound/effects/mag_teleport.ogg','sound/effects/mag_phase.ogg','sound/effects/teleport.ogg','sound/effects/warp2.ogg','sound/weapons/ACgun2.ogg',
		'sound/weapons/laserultra.ogg','sound/weapons/radxbow.ogg','sound/machines/ArtifactWiz1.ogg','sound/machines/ArtifactPre1.ogg','sound/machines/ArtifactAnc1.ogg','sound/machines/engine_alert3.ogg', 'sound/voice/wizard/BlinkLoud.ogg')
		recharge_phrase = pick("crackles with static.","emits a quiet tone.","shakes violently!","heats up.")
		error_phrase = pick("shudders briefly.","grows heavy for a moment.","emits a quiet buzz.","makes a small pop sound.")
		cooldown_delay = rand(1,20) * 10
		if (prob(5))
			cooldown_delay = 0

	effect_click_tile(var/obj/O,var/mob/living/user,var/turf/T)
		if (..())
			return
		if (on_cooldown)
			return

		on_cooldown = 1
		SPAWN_DBG(cooldown_delay)
			if (O.loc == user)
				boutput(user, "<b>[O]</b> [recharge_phrase]")
			on_cooldown = 0

		user.set_loc(T)

		var/turf/start_loc = get_turf(user)
		playsound(start_loc, wand_sound, 50, 1, -1)
		particleMaster.SpawnSystem(new /datum/particleSystem/tele_wand(T,particle_sprite,particle_color))
		return

	proc/can_teleport_here(var/turf/T)
		if (!istype(T,/turf/simulated/floor/))
			return 0
		if (T.density)
			return 0
		for(var/atom/X in T.contents)
			if (X.density)
				return 0
		return 1
