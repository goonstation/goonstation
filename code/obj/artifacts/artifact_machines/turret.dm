/obj/machinery/artifact/turret
	name = "artifact turret"
	associated_datum = /datum/artifact/turret

	ArtifactDestroyed()
		var/datum/artifact/turret/A = src.artifact
		new /obj/item/gun/energy/artifact(get_turf(src), A.artitype.name, list(A.bullet))
		. = ..()


/datum/artifact/turret
	associated_object = /obj/machinery/artifact/turret
	type_name = "Turret"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 200
	validtypes = list("wizard","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch, /datum/artifact_trigger/language,
	/datum/artifact_trigger/credits)
	fault_blacklist = list(ITEM_ONLY_FAULTS)
	activated = 0
	activ_text = "uncovers an array of guns!"
	deact_text = "retracts the guns back into itself and falls quiet!"
	react_xray = list(9,40,80,8,"SEGMENTED")
	var/cycles_without_target = 0
	var/cycles_until_shutdown = 10
	var/capricious = 0
	var/shot_range = 3
	var/datum/projectile/artifact/bullet = null
	var/mob/living/friend = null
	var/mob/living/current_target = null
	examine_hint = "It is covered in very conspicuous markings."

	New()
		..()
		bullet = new /datum/projectile/artifact
		shot_range = rand(2,6)
		if (prob(20))
			capricious = 1
		bullet.randomise()

	post_setup()
		. = ..()
		bullet.turretArt = src.holder

	effect_touch(var/obj/O,var/mob/living/user)
		if (..())
			return
		O.ArtifactFaultUsed(user)
		if (src.capricious > -1)
			if (!src.friend || src.capricious)
				src.friend = user

	effect_process(var/obj/O)
		if (..())
			return
		var/turf/T = get_turf(O)
		if (!current_target)
			var/list/valid_targets = list()
			for (var/mob/living/M in view(shot_range,O))
				if (!target_is_valid(M,O))
					continue
				valid_targets += M
			if (length(valid_targets) > 0)
				current_target = pick(valid_targets)
				T.visible_message("<b>[O]</b> turns to face [current_target]!")
				cycles_without_target = 0
			else
				cycles_without_target++
				if (cycles_without_target >= cycles_until_shutdown)
					cycles_without_target = 0
					O.ArtifactDeactivated()
		else
			if (target_is_valid(current_target,O) && bullet)
				shoot_projectile_ST_pixel_spread(O, bullet, current_target)
			else
				current_target = null

	proc/target_is_valid(var/mob/living/M,var/obj/O)
		if (!M || !O)
			return FALSE
		if (isdead(M) || isintangible(M))
			return FALSE
		if (M == friend)
			return FALSE
		if (GET_DIST(M,O) > shot_range)
			return FALSE
		return TRUE
