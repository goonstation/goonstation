// flockdrone door
/obj/machinery/door/feather
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "door1"
	name = "weird imposing wall"
	desc = "It sounds like it's hollow."
	var/flock_id = "Solid seal aperture"
	mat_appearances_to_ignore = list("steel","gnesis")
	mat_changename = FALSE
	mat_changedesc = FALSE
	autoclose = TRUE
	var/broken = FALSE
	health = 200
	health_max = 200
	var/repair_per_resource = 2

/obj/machinery/door/feather/New()
	..()
	setMaterial(getMaterial("gnesis"), appearance=FALSE, setname=FALSE)
	APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOCK_THING, src)
	src.AddComponent(/datum/component/flock_protection, report_unarmed=FALSE)
	if (map_settings?.auto_walls)
		for (var/turf/simulated/wall/auto/feather/W in orange(1, src))
			W.UpdateIcon()
	var/datum/component/C = src.GetComponent(/datum/component/mechanics_holder)
	C?.RemoveComponent()

/obj/machinery/door/feather/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	var/special_desc = {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received.
		<br><span class='bold'>ID:</span> [src.flock_id]
		<br><span class='bold'>System Integrity:</span> [round((src.health/src.health_max)*100)]%"}
	if(broken)
		special_desc += {"<br><span class='bold'>FUNCTION CRITICALLY IMPAIRED, REPAIRS REQUIRED</span>
			<br><span class='bold'>###=-</span></span>"}
	return special_desc

/obj/machinery/door/feather/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (src.density)
		boutput(user, "<span class='alert'>No reaction, apparently.</span>")
	return FALSE

/obj/machinery/door/feather/take_damage(var/amount, var/mob/user = 0)
	..()
	if(src.health <= (src.health_max/2) && !broken)
		playsound(src, 'sound/impact_sounds/Glass_Shatter_1.ogg', 25, 1)
		src.name = "shattered wall door thing"
		src.desc = "Well, no one's opening this thing anymore."
		src.icon_state = "door-broke"
		src.broken = TRUE

/obj/machinery/door/feather/break_me_complitely()
	var/turf/T = get_turf(src)
	playsound(T, 'sound/impact_sounds/Glass_Shatter_3.ogg', 25, 1)
	var/obj/item/raw_material/shard/S = new /obj/item/raw_material/shard
	S.set_loc(T)
	S.setMaterial(getMaterial("gnesisglass"))
	make_cleanable( /obj/decal/cleanable/flockdrone_debris, T)
	qdel(src)

/obj/machinery/door/feather/heal_damage()
	src.icon_state = "door1"
	src.broken = FALSE
	close()
	src.health = initial(health)
	src.name = initial(name)
	src.desc = initial(desc)

/obj/machinery/door/feather/proc/repair(resources_available)
	var/health_given = min(min(resources_available, FLOCK_REPAIR_COST) * src.repair_per_resource, src.health_max - src.health)
	src.health += health_given

	if (src.broken && src.health_max / 2 < src.health)
		src.name = initial(src.name)
		src.desc = initial(src.desc)
		src.broken = FALSE
		src.icon_state = initial(src.icon_state)
	return ceil(health_given / src.repair_per_resource)

/obj/machinery/door/feather/proc/deconstruct()
	var/turf/T = get_turf(src)
	playsound(T, 'sound/impact_sounds/Glass_Shatter_3.ogg', 25, 1)
	var/obj/item/raw_material/shard/S = new /obj/item/raw_material/shard(T)
	S.setMaterial(getMaterial("gnesisglass"))
	S = new /obj/item/raw_material/shard(T)
	S.setMaterial(getMaterial("gnesis"))
	qdel(src)

/obj/machinery/door/feather/play_animation(animation)
	if(broken)
		return
	switch(animation)
		if("opening")
			if(src.panel_open)
				flick("o_[icon_base]c0", src)
			else
				flick("[icon_base]c0", src)
			icon_state = "[icon_base]0"
		if("closing")
			if(src.panel_open)
				flick("o_[icon_base]c1", src)
			else
				flick("[icon_base]c1", src)
			icon_state = "[icon_base]1"
		if("deny")
			flick("[icon_base]_deny", src)
			playsound(src, 'sound/misc/flockmind/flockdrone_door_deny.ogg', 50, 1, -2)


/obj/machinery/door/feather/attack_ai(mob/user as mob)
	boutput(user, "<span class='alert'>No response. It doesn't seem compatible with your systems.</span>")
	return

/obj/machinery/door/feather/attack_hand(mob/user)
	return src.Attackby(null, user)

/obj/machinery/door/feather/bullet_act(obj/projectile/P)
	if (istype(P.proj_data, /datum/projectile/energy_bolt/flockdrone))
		return
	..()

/obj/machinery/door/feather/allowed(mob/M)
	return isflockmob(M)

/obj/machinery/door/feather/check_access()
	return FALSE

/obj/machinery/door/feather/open()
	if (src.broken)
		return FALSE
	if (..())
		playsound(src, 'sound/misc/flockmind/flockdrone_door.ogg', 30, 1, extrarange = -10)

/obj/machinery/door/feather/close()
	if(..())
		playsound(src, 'sound/misc/flockmind/flockdrone_door.ogg', 30, 1, extrarange = -10)

/obj/machinery/door/feather/isblocked()
	return FALSE // this door will not lock or be inaccessible to flockdrones

/obj/machinery/door/feather/disposing()
	..()
	if (map_settings?.auto_walls)
		for (var/turf/simulated/wall/auto/feather/W in orange(1))
			W.UpdateIcon()

// ----------------
// friendly variant
// ----------------
// everyone allowed to open
/obj/machinery/door/feather/friendly

/obj/machinery/door/feather/friendly/allowed(mob/M)
	return TRUE

/obj/machinery/door/feather/friendly/check_access()
	return TRUE
