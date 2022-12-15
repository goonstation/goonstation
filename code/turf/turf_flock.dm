// -----
// FLOOR
// -----
/turf/simulated/floor/feather
	name = "weird floor"
	desc = "I don't like the looks of that whatever-it-is."
	var/flock_id = "Conduit"
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "floor"
	flags = USEDELAY
	mat_appearances_to_ignore = list("steel","gnesis")
	mat_changename = FALSE
	mat_changedesc = FALSE
	broken = FALSE
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED
	var/health = 50
	var/repair_per_resource = 1
	var/col_r = 0.1
	var/col_g = 0.7
	var/col_b = 0.6
	var/datum/light/light
	var/brightness = 0.5
	var/on = FALSE
	var/connected = FALSE //used for collector


/turf/simulated/floor/feather/New()
	..()
	setMaterial(getMaterial("gnesis"), copy = FALSE)
	light = new /datum/light/point
	light.set_brightness(src.brightness)
	light.set_color(col_r, col_g, col_b)
	light.attach(src)
	APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOCK_THING, src)
	src.AddComponent(/datum/component/flock_protection, report_unarmed=FALSE, report_thrown=FALSE, report_proj=FALSE)

/turf/simulated/floor/feather/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	return {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received.
		<br><span class='bold'>ID:</span> [src.flock_id]
		<br><span class='bold'>System Integrity:</span> [round((src.health/50)*100)]%
		<br><span class='bold'>###=-</span></span>"}

/turf/simulated/floor/feather/attackby(obj/item/C, mob/user, params)
	// do not call parent, this is not an ordinary floor
	if(!C || !user)
		return
	if (istype(C, /obj/item/grab))
		grab_smash(C, user)
		return
	if(ispryingtool(C) && src.broken)
		playsound(src, 'sound/items/Crowbar.ogg', 80, 1)
		src.break_tile_to_plating()
		return
	if(src.broken)
		boutput(user, "<span class='hint'>It's already broken, you need to pry it out with a crowbar.</span>")
		return
	src.health -= C.force
	if(src.health <= 0)
		src.visible_message("<span class='alert'><span class='bold'>[user]</span> smacks [src] with [C], shattering it!</span>")
		src.name = "weird broken floor"
		src.desc = "It's broken. You could probably use a crowbar to pull the remnants out."
		playsound(src, 'sound/impact_sounds/Crystal_Shatter_1.ogg', 25, 1)
		break_tile()
	else
		src.visible_message("<span class='alert'><span class='bold'>[user]</span> smacks [src] with [C]!</span>")
		playsound(src, 'sound/impact_sounds/Crystal_Hit_1.ogg', 25, 1)
	user.lastattacked = src

/turf/simulated/floor/feather/break_tile_to_plating()
	off()
	var/turf/simulated/floor/F = src.ReplaceWithFloor()
	F.to_plating()

/turf/simulated/floor/feather/break_tile()
	off()
	icon_state = "floor-broken"
	broken = TRUE
	for (var/mob/living/critter/flock/drone/flockdrone in src.contents)
		if (flockdrone.floorrunning)
			flockdrone.end_floorrunning()

/turf/simulated/floor/feather/proc/repair(resources_available)
	if (src.broken)
		src.name = initial(src.name)
		src.desc = initial(src.desc)
		src.icon_state = initial(src.icon_state)
		src.broken = FALSE
	var/health_given = min(min(resources_available, FLOCK_REPAIR_COST) * src.repair_per_resource, initial(src.health) - src.health)
	src.health += health_given
	return ceil(health_given / src.repair_per_resource)

/turf/simulated/floor/feather/burn_tile()
	return

/turf/simulated/floor/feather/Entered(var/mob/living/critter/flock/drone/F, atom/oldloc)
	..()
	if(!istype(F) || !oldloc)
		return
	if(F.client && F.client.check_key(KEY_RUN) && !broken && !F.floorrunning && F.can_floorrun && F.resources >= 1)
		F.start_floorrunning()

	if(F.floorrunning && !broken)
		F.pay_resources(1)
		if (F.resources < 1)
			F.end_floorrunning()
		else if(!on)
			on()

/turf/simulated/floor/feather/Exited(var/mob/living/critter/flock/drone/F, atom/newloc)
	..()
	if(!istype(F) || !newloc)
		return
	if(F.floorrunning && !connected)
		if (locate(/mob/living/critter/flock/drone) in src.contents)
			var/floorrunning_flockdrone = FALSE
			for (var/mob/living/critter/flock/drone/flockdrone in src.contents)
				if (flockdrone.floorrunning)
					floorrunning_flockdrone = TRUE
			if (!floorrunning_flockdrone)
				off()
		else
			off()
	if(F.floorrunning)
		if(istype(newloc, /turf/simulated/floor/feather))
			var/turf/simulated/floor/feather/T = newloc
			if(T.broken)
				F.end_floorrunning()
		else if(!isfeathertile(newloc))
			F.end_floorrunning()

/turf/simulated/floor/feather/proc/on()
	if(src.broken)
		return 1
	src.icon_state = "floor-on"
	src.name = "weird glowing floor"
	src.desc = "Looks like disco's not dead after all."
	on = TRUE
	//playsound(src.loc, 'sound/machines/ArtifactFea3.ogg', 25, 1)
	src.light.enable()

/turf/simulated/floor/feather/proc/off()
	if(src.broken)
		src.icon_state = "floor-broken"
	else
		src.icon_state = "floor"
		src.name = initial(name)
		src.desc = initial(desc)
	src.light.disable()
	on = FALSE

/turf/simulated/floor/feather/broken
	name = "weird broken floor"
	desc = "Disco's dead, baby."
	icon_state = "floor-broken"
	broken = TRUE



// -----
// WALL
// -----

TYPEINFO(/turf/simulated/wall/auto/feather)
TYPEINFO_NEW(/turf/simulated/wall/auto/feather)
	. = ..()
	connect_overlay = TRUE
	connect_diagonal = TRUE
	connects_to = typecacheof(list(/turf/simulated/wall/auto/feather, /obj/machinery/door, /obj/window))
	connects_with_overlay = typecacheof(list(/obj/machinery/door, /obj/window))
/turf/simulated/wall/auto/feather
	name = "weird glowing wall"
	desc = "You can feel it thrumming and pulsing."
	var/flock_id = "Nanite block"
	icon = 'icons/turf/walls_flock.dmi'
	icon_state = "flock0"
	mod = "flock"
	health = 250
	var/max_health = 250
	var/repair_per_resource = 5
	flags = USEDELAY | ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID
	mat_appearances_to_ignore = list("steel", "gnesis")
	mat_changename = FALSE
	mat_changedesc = FALSE
	var/broken = FALSE
	var/on = FALSE

	// update_icon()
	// 	..()
		//TODO animate walls and put this back
		//if (src.broken)
		//	icon_state = icon_state + "b"
		//else
		//	icon_state = icon_state + (src.on ? "on" : "")

/turf/simulated/wall/auto/feather/tutorial
	opacity = FALSE

/turf/simulated/wall/auto/feather/New()
	..()
	setMaterial(getMaterial("gnesis"), copy = FALSE)
	src.health = src.max_health
	APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOCK_THING, src)
	src.AddComponent(/datum/component/flock_protection)

/turf/simulated/wall/auto/feather/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	return {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received.
		<br><span class='bold'>ID:</span> [src.flock_id]
		<br><span class='bold'>System Integrity:</span> [round((src.health/src.max_health)*100)]%
		<br><span class='bold'>###=-</span></span>"}

/turf/simulated/wall/auto/feather/attack_hand(mob/user)
	if (user.a_intent == INTENT_HARM)
		if(src.broken)
			boutput(user, "<span class='hint'>It's already broken, you need to take the pieces apart with a crowbar.</span>")
		else
			src.takeDamage("brute", 1)
			if (src.broken)
				user.visible_message("<span class='alert'><b>[user]</b> punches the [initial(src.name)], shattering it!</span>")
			else
				user.visible_message("<span class='alert'><b>[user]</b> punches [src]! Ouch!</span>")
			user.lastattacked = src
			attack_particle(user, src)

/turf/simulated/wall/auto/feather/attackby(obj/item/C, mob/user)
	if(!C || !user)
		return
	if(ispryingtool(C) && src.broken)
		playsound(src, 'sound/items/Crowbar.ogg', 80, 1)
		src.destroy()
		return
	if(src.broken)
		boutput(user, "<span class='hint'>It's already broken, you need to take the pieces apart with a crowbar.</span>")
		return
	if (src.health > 0)
		src.takeDamage("brute", C.force)
	if(src.health <= 0)
		src.visible_message("<span class='alert'><span class='bold'>[user]</span> smacks the [initial(src.name)] with [C], shattering it!</span>")
	else
		src.visible_message("<span class='alert'><span class='bold'>[user]</span> smacks [src] with [C]!</span>")
	user.lastattacked = src
	attack_particle(user, src)

/turf/simulated/wall/auto/feather/burn_down()
	src.takeDamage("fire", 1)
	if (src.health <= 0)
		src.destroy()

/turf/simulated/wall/auto/feather/ex_act(severity)
	var/damage = 0
	var/damage_mult = 1

	switch(severity)
		if(1)
			damage = rand(30,50)
			damage_mult = 8
		if(2)
			damage = rand(25,40)
			damage_mult = 4
		if(3)
			damage = rand(10,20)
			damage_mult = 2
	src.takeDamage("mixed", damage * damage_mult)

	if (src.health <= 0)
		src.destroy()

/turf/simulated/wall/auto/feather/blob_act(power)
	var/modifier = power / 20
	var/damage = rand(modifier, 12 + 8 * modifier)

	src.takeDamage("mixed", damage, FALSE)
	src.visible_message("<span class='alert'>[initial(src.name)] is hit by the blob!/span>")

	if (src.health <= 0)
		src.destroy()

/turf/simulated/wall/auto/feather/proc/takeDamage(damageType, amount, playAttackSound = TRUE)
	src.health = max(src.health - amount, 0)
	if (src.health > 0 && playAttackSound)
		playsound(src, 'sound/impact_sounds/Crystal_Hit_1.ogg', 80, 1)

	if (!src.broken && src.health <= 0)
		src.name = "weird broken wall"
		src.desc = "It's broken. You could probably use a crowbar to break the pieces apart."
		src.broken = TRUE
		src.UpdateIcon()
		src.material.setProperty("reflective", 3)
		if (playAttackSound)
			playsound(src, 'sound/impact_sounds/Crystal_Shatter_1.ogg', 25, 1)

		for (var/mob/living/critter/flock/drone/flockdrone in src.contents)
			if (flockdrone.floorrunning)
				flockdrone.end_floorrunning()

/turf/simulated/wall/auto/feather/proc/destroy()
	var/turf/T = get_turf(src)

	var/atom/movable/B
	for (var/i = 1 to rand(3, 6))
		if (prob(70))
			B = new /obj/item/raw_material/scrap_metal(T)
			B.setMaterial(getMaterial("gnesis"), copy = FALSE)
		else
			B = new /obj/item/raw_material/shard(T)
			B.setMaterial(getMaterial("gnesisglass"), copy = FALSE)

	src.ReplaceWith("/turf/simulated/floor/feather", FALSE)

	if (map_settings?.auto_walls)
		for (var/turf/simulated/wall/auto/feather/W in orange(1))
			W.UpdateIcon()

/turf/simulated/wall/auto/feather/proc/deconstruct()
	make_cleanable(/obj/decal/cleanable/flockdrone_debris/fluid, get_turf(src))
	src.ReplaceWith("/turf/simulated/floor/feather", FALSE)

	if (map_settings?.auto_walls)
		for (var/turf/simulated/wall/auto/feather/W in orange(1, src))
			W.UpdateIcon()

/turf/simulated/wall/auto/feather/proc/repair(resources_available)
	if (src.broken)
		src.name = initial(src.name)
		src.desc = initial(src.desc)
		src.broken = FALSE
		src.UpdateIcon()
		src.setMaterial(getMaterial("gnesis"), copy = FALSE)
	var/health_given = min(min(resources_available, FLOCK_REPAIR_COST) * src.repair_per_resource, src.max_health - src.health)
	src.health += health_given
	return ceil(health_given / src.repair_per_resource)

/turf/simulated/wall/auto/feather/Entered(var/mob/living/critter/flock/drone/F, atom/oldloc)
	..()
	if(!istype(F) || !oldloc)
		return
	if(!F.floorrunning && F.resources >= 1)
		F.start_floorrunning()

	if(F.floorrunning)
		F.pay_resources(1)
		if (F.resources < 1)
			F.end_floorrunning()
		else if (!src.on)
			src.on()

/turf/simulated/wall/auto/feather/Exited(var/mob/living/critter/flock/drone/F, atom/newloc)
	..()
	if(!istype(F) || !newloc)
		return
	if(F.floorrunning)
		if (locate(/mob/living/critter/flock/drone) in src.contents)
			var/floorrunning_flockdrone = FALSE
			for (var/mob/living/critter/flock/drone/flockdrone in src.contents)
				if (flockdrone.floorrunning)
					floorrunning_flockdrone = TRUE
			if (!floorrunning_flockdrone)
				src.off()
		else
			src.off()

		if(istype(newloc, /turf/simulated/floor/feather))
			var/turf/simulated/floor/feather/T = newloc
			if(T.broken)
				F.end_floorrunning()
		else if(!isfeathertile(newloc))
			F.end_floorrunning()

/turf/simulated/wall/auto/feather/Bumped(AM)
	. = ..()
	if(istype(AM, /mob/living/critter/flock/drone))
		var/mob/living/critter/flock/drone/F = AM
		if(F.floorrunning || (F.can_floorrun && F.resources >= 1))
			if(F.is_npc || (F.client && F.client.check_key(KEY_RUN))) //ai doesn't have to hold shift to wallrun, people do
				F.start_floorrunning()
				F.set_loc(src)

/turf/simulated/wall/auto/feather/proc/on()
	src.on = TRUE
	src.UpdateIcon()

/turf/simulated/wall/auto/feather/proc/off()
	src.on = FALSE
	src.UpdateIcon()
