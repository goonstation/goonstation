// flockdrone stuff

// -----
// FLOOR
// -----
/turf/simulated/floor/feather
	name = "weird floor"
	desc = "I don't like the looks of that whatever-it-is."
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "floor"
	mat_appearances_to_ignore = list("steel","gnesis")
	mat_changename = 0
	mat_changedesc = 0
	broken = 0
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED
	var/health = 50
	var/col_r = 0.1
	var/col_g = 0.7
	var/col_b = 0.6
	var/datum/light/light
	var/brightness = 0.5
	var/on = 0

/turf/simulated/floor/feather/New()
	..()
	setMaterial(getMaterial("gnesis"))
	light = new /datum/light/point
	light.set_brightness(src.brightness)
	light.set_color(col_r, col_g, col_b)
	light.attach(src)


/turf/simulated/floor/feather/special_desc(dist, mob/user)
  if(isflock(user))
    var/special_desc = "<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received."
    special_desc += "<br><span class='bold'>ID:</span> Conduit"
    special_desc += "<br><span class='bold'>System Integrity:</span> [round((src.health/50)*100)]%"
    special_desc += "<br><span class='bold'>###=-</span></span>"
    return special_desc
  else
    return null // give the standard description

/turf/simulated/floor/feather/attackby(obj/item/C as obj, mob/user as mob, params)
	// do not call parent, this is not an ordinary floor
	if(!C || !user)
		return
	if(ispryingtool(C) && src.broken)
		playsound(src, "sound/items/Crowbar.ogg", 80, 1)
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
		playsound(src.loc, "sound/impact_sounds/Crystal_Shatter_1.ogg", 25, 1)
		break_tile()
	else
		src.visible_message("<span class='alert'><span class='bold'>[user]</span> smacks [src] with [C]!</span>")
		playsound(src.loc, "sound/impact_sounds/Crystal_Hit_1.ogg", 25, 1)

/turf/simulated/floor/feather/break_tile_to_plating()
	// if the turf's on, turn it off
	off()
	var/turf/simulated/floor/F = src.ReplaceWithFloor()
	F.to_plating()

/turf/simulated/floor/feather/break_tile()
	off()
	icon_state = "floor-broken"
	broken = 1

//////////////////////////////////////////////////////////////////////////////////////////////////////
// stuff to make floorrunning possible (god i wish i could think of a better verb than "floorrunning")
/turf/simulated/floor/feather/Entered(var/mob/living/critter/flock/drone/F, atom/oldloc)
	..()
	if(!istype(F) || !oldloc)
		return
	if(F.client && F.client.check_key(KEY_RUN) && !broken && !F.floorrunning)
		F.start_floorrunning()
	if(F.floorrunning && !broken)
		if(!on)
			on()

/turf/simulated/floor/feather/Exited(var/mob/living/critter/flock/drone/F, atom/newloc)
	..()
	if(!istype(F) || !newloc)
		return
	if(on)
		off()
	if(F.floorrunning)
		if(istype(newloc, /turf/simulated/floor/feather))
			var/turf/simulated/floor/feather/T = newloc
			if(T.broken)
				F.end_floorrunning() // broken tiles won't let you continue floorrunning
		else if(!isfeathertile(newloc))
			F.end_floorrunning() // you left flocktile territory, boyo

/turf/simulated/floor/feather/proc/on()
	if(src.broken)
		return 1
	src.icon_state = "floor-on"
	src.name = "weird glowing floor"
	src.desc = "Looks like disco's not dead after all."
	on = 1
	playsound(src.loc, "sound/machines/ArtifactFea3.ogg", 25, 1)
	src.light.enable()

/turf/simulated/floor/feather/proc/off()
	if(src.broken) // i guess this could potentially happen
		src.icon_state = "floor-broken"
	else
		src.icon_state = "floor"
		src.name = initial(name)
		src.desc = initial(desc)
	src.light.disable()
	on = 0

/turf/simulated/floor/feather/proc/repair()
	src.icon_state = "floor"
	src.broken = 0
	src.health = initial(health)
	src.name = initial(name)
	src.desc = initial(desc)

/turf/simulated/floor/feather/broken
	name = "weird broken floor"
	desc = "Disco's dead, baby."
	icon_state = "floor-broken"
	broken = 1


/turf/simulated/wall/auto/feather
	name = "weird glowing wall"
	desc = "You can feel it thrumming and pulsing."
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "0"
	mat_appearances_to_ignore = list("steel","gnesis")
	connects_to = list(/turf/simulated/wall/auto/feather, /obj/machinery/door/feather)

/turf/simulated/wall/auto/feather/New()
	..()
	setMaterial(getMaterial("gnesis"))

/turf/simulated/wall/auto/feather/special_desc(dist, mob/user)
  if(isflock(user))
    var/special_desc = "<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received."
    special_desc += "<br><span class='bold'>ID:</span> Nanite Block"
    special_desc += "<br><span class='bold'>System Integrity:</span> 100%" // todo: damageable walls
    special_desc += "<br><span class='bold'>###=-</span></span>"
    return special_desc
  else
    return null // give the standard description

/turf/simulated/wall/auto/feather/Entered(var/mob/living/critter/flock/drone/F, atom/oldloc)
	..()
	if(!istype(F) || !oldloc)
		return
	if(F.client && F.client.check_key(KEY_RUN) && !F.floorrunning)
		F.start_floorrunning()

/turf/simulated/wall/auto/feather/Exited(var/mob/living/critter/flock/drone/F, atom/newloc)
	..()
	if(!istype(F) || !newloc)
		return
	if(F.floorrunning)
		if(istype(newloc, /turf/simulated/floor/feather))
			var/turf/simulated/floor/feather/T = newloc
			if(T.broken)
				F.end_floorrunning() // broken tiles won't let you continue floorrunning
		else if(!isfeathertile(newloc))
			F.end_floorrunning() // you left flocktile territory, boyo
