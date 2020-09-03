/obj/item/roboupgrade/teleport
	name = "cyborg teleporter upgrade"
	desc = "A personal teleportation device that allows a cyborg to transport itself instantly to any teleporter beacon."
	icon_state = "up-teleport"
	active = 1
	drainrate = 250

/obj/item/roboupgrade/teleport/upgrade_activate(var/mob/living/silicon/robot/user as mob)
	if (!user || !src || src.loc != user || !issilicon(user) || !src.active)
		return
	if (user.getStatusDuration("stunned") > 0 || user.getStatusDuration("weakened") || user.getStatusDuration("paralysis") >  0 || !isalive(user))
		user.show_text("Not when you're incapacitated.", "red")
		return
	if (!isturf(user.loc))
		user.show_text("You can't teleport from inside a container.", "red")
		return

	var/list/L = list()
	var/list/areaindex = list()

	for (var/obj/item/device/radio/beacon/R in by_type[/obj/item/device/radio/beacon])
		if (!istype(R, /obj/item/device/radio/beacon/jones))
			LAGCHECK(LAG_LOW)
			var/turf/T = get_turf(R)
			if (!T)
				continue
			var/tmpname = T.loc.name
			if (areaindex[tmpname])
				tmpname = "[tmpname] ([++areaindex[tmpname]])"
			else
				areaindex[tmpname] = 1
			L[tmpname] = R

	for (var/obj/item/implant/tracking/I in by_type[/obj/item/implant/tracking])
		LAGCHECK(LAG_LOW)
		if (!I.implanted || !ismob(I.loc))
			continue
		else
			var/mob/M = I.loc
			if (isdead(M) && M.timeofdeath + 6000 < world.time)
				continue
			var/tmpname = M.real_name
			if (areaindex[tmpname])
				tmpname = "[tmpname] ([++areaindex[tmpname]])"
			else
				areaindex[tmpname] = 1
			L[tmpname] = I

	var/desc = input("Area to jump to","Teleportation") in L

	if (!user || !src || src.loc != user || !issilicon(user))
		if (user)
			user.show_text("Teleportation failed.", "red")
		return
	if (user.mind && user.mind.current != src.loc) // Debrained or whatever.
		user.show_text("Teleportation failed.", "red")
		return
	if (user.getStatusDuration("stunned") || getStatusDuration("weakened") || user.getStatusDuration("paralysis") >  0 || !isalive(user))
		user.show_text("Not when you're incapacitated.", "red")
		return
	if (!src.active)
		user.show_text("Cannot teleport, upgrade is inactive.", "red")
		return
	if (!desc || !L[desc])
		user.show_text("Invalid selection.", "red")
		return
	if (!isturf(user.loc))
		user.show_text("You can't teleport from inside a container.", "red")
		return

	do_teleport(user, L[desc], 0)
