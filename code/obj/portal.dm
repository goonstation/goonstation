/obj/portal
	name = "portal"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	density = 1
	var/failchance = 5
	var/obj/item/target = null
	anchored = 1
	var/portal_lums = 2
	var/datum/light/light
	event_handler_flags = USE_FLUID_ENTER

/obj/portal/New()
	..()
	light = new /datum/light/point
	light.set_color(0.1, 0.1, 0.9)
	light.set_brightness(portal_lums / 6)
	light.attach(src)
	light.enable()
	SPAWN(0)
		animate_portal_appear(src)
		playsound(src.loc, "warp", 50, 1, 0.1, 0.7)

/obj/portal/Bumped(mob/M as mob|obj)
	SPAWN(0)
		src.teleport(M)
		return
	return

/obj/portal/Crossed(atom/movable/AM as mob|obj)
	..()
	SPAWN(0)
		src.teleport(AM)

/obj/portal/attack_hand(mob/M)
	SPAWN(0)
		src.teleport(M)

/obj/portal/disposing()
	target = null
	..()

/obj/portal/proc/teleport(atom/movable/M as mob|obj)
	if( istype(M, /obj/effects)) //sparks don't teleport
		return
	if (M.anchored)
		return
	if (src.icon_state == "portal1")
		return
	if (!src.target)
		return
	if (isAIeye(M))
		return
	if (istype(M, /atom/movable))
		animate_portal_tele(src)
		playsound(src.loc, "warp", 50, 1, 0.2, 1.2)
		if (!isturf(target))
			var/turf/destination = get_turf(src.target) // Beacons and tracking implant might have been moved.
			if (destination)
				if (prob(failchance)) //oh dear a problem, put em in deep space
					src.icon_state = "portal1"
					do_teleport(M, destination, 15)
					var/part_splinched = splinch(M, 75)
					if (part_splinched)
						do_teleport(part_splinched, destination, 8)
						M.visible_message("<span class='alert'><b>[M]</b> splinches themselves and their [part_splinched] falls off!</span>")
					M.throw_at(destination, 8, 2)

					return
				if(ismob(M))
					logTheThing(LOG_STATION, M, "entered [src] at [log_loc(src)] and teleported to [src.target] at [log_loc(destination)]")
				do_teleport(M, destination, 1)
			else return
		else
			if(ismob(M))
				logTheThing(LOG_STATION, M, "entered [src] at [log_loc(src)] and teleported to [log_loc(src.target)]")
			do_teleport(M, src.target, 1) ///You will appear adjacent to the beacon

/obj/portal/wormhole
	name = "wormhole"
	desc = "Some sort of weird fold in space. It presumably leads somewhere."
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"
	density = 1
	failchance = 0

	Bumped(mob/M as mob|obj)
		//spatial interdictor: when something would enter a wormhole, it doesn't
		//consumes 400 units of charge per wormhole interdicted
		for (var/obj/machinery/interdictor/IX in by_type[/obj/machinery/interdictor])
			if (IN_RANGE(IX,src,IX.interdict_range) && IX.expend_interdict(400))
				icon = 'icons/effects/effects.dmi'
				icon_state = "sparks_attack"
				playsound(src.loc, 'sound/impact_sounds/Energy_Hit_1.ogg', 30, 1)
				density = 0
				return
		..()

/obj/portal/afterlife
	desc = "Enter this to return to your ghostly form"

	Bumped(mob/M as mob|obj)
		SPAWN(0)
			M.ghostize()
			qdel(src)
			return
		return

	Crossed(atom/movable/AM as mob|obj)
		..()
		SPAWN(0)
			if(istype(AM,/mob))
				var/mob/M = AM
				M.ghostize()
			qdel(src)

	attack_hand(mob/M)
		SPAWN(0)
			M.ghostize()
			qdel(src)
