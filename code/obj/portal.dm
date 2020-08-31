/obj/portal
	name = "portal"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	density = 1
	var/failchance = 5
	var/obj/item/target = null
	anchored = 1.0
	var/portal_lums = 2
	var/datum/light/light
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER

/obj/portal/New()
	..()
	light = new /datum/light/point
	light.set_color(0.1, 0.1, 0.9)
	light.set_brightness(portal_lums / 6)
	light.attach(src)
	light.enable()
	SPAWN_DBG(0)
		animate_portal_appear(src)
		playsound(src.loc, "warp", 50, 1, 0.1, 0.7)

/obj/portal/Bumped(mob/M as mob|obj)
	SPAWN_DBG(0)
		src.teleport(M)
		return
	return

/obj/portal/HasEntered(AM as mob|obj)
	SPAWN_DBG(0)
		src.teleport(AM)
		return
	return

/obj/portal/attack_hand(mob/M as mob)
	SPAWN_DBG(0)
		src.teleport(M)
		return
	return

/obj/portal/disposing()
	target = null
	..()

/obj/portal/pooled(var/poolname)
	..()
	name = initial(name)
	icon = initial(icon)
	icon_state = initial(icon_state)
	density = initial(density)
	failchance = initial(failchance)
	anchored = initial(anchored)

/obj/portal/unpooled(var/poolname)
	portal_lums = initial(portal_lums)
	light.set_brightness(portal_lums / 3)
	light.enable()
	SPAWN_DBG(0)
		animate_portal_appear(src)
		playsound(src.loc, "warp", 50, 1, 0.1, 0.7)
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
	if (istype(M, /mob/dead/aieye))
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

				do_teleport(M, destination, 1)
			else return
		else
			do_teleport(M, src.target, 1) ///You will appear adjacent to the beacon

/obj/portal/wormhole
	name = "wormhole"
	desc = "Some sort of weird fold in space. It presumably leads somewhere."
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"
	density = 1
	failchance = 0

/obj/portal/afterlife
	desc = "Enter this to return to your ghostly form"

	New()
		..()
		unpooled()

	Bumped(mob/M as mob|obj)
		SPAWN_DBG(0)
			M.ghostize()
			qdel(src)
			return
		return

	HasEntered(AM as mob|obj)
		SPAWN_DBG(0)
			if(istype(AM,/mob))
				var/mob/M = AM
				M.ghostize()
			qdel(src)
			return
		return

	attack_hand(mob/M as mob)
		SPAWN_DBG(0)
			M.ghostize()
			qdel(src)
			return
		return
