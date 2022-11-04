/obj/item/roboupgrade/teleport
	name = "cyborg teleporter upgrade"
	desc = "A personal teleportation device that allows a cyborg to transport itself instantly to any teleporter beacon."
	icon_state = "up-teleport"
	active = TRUE
	drainrate = 250

/obj/item/roboupgrade/teleport/upgrade_activate(var/mob/living/silicon/robot/user)
	if (is_incapacitated(user))
		user.show_text("Not when you're incapacitated.", "red")
		return
	if (!isturf(user.loc))
		user.show_text("You can't teleport from inside a container.", "red")
		return

	var/list/L = list()
	var/list/areaindex = list()

	for_by_tcl(R, /obj/item/device/radio/beacon)
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

	for_by_tcl(I, /obj/item/implant/tracking)
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

	var/desc = tgui_input_list(user, "Area to jump to","Teleportation", sortList(L, /proc/cmp_text_asc))

	if (!user || !src || src.loc != user || !isrobot(user))
		if (user)
			user.show_text("Teleportation failed.", "red")
		return
	if (user.mind && user.mind.current != src.loc) // Debrained or whatever.
		user.show_text("Teleportation failed.", "red")
		return
	if (is_incapacitated(user))
		user.show_text("Not when you're incapacitated.", "red")
		return
	if (!desc || !L[desc])
		user.show_text("Invalid selection.", "red")
		return
	if (!isturf(user.loc))
		user.show_text("You can't teleport from inside a container.", "red")
		return

	do_teleport(user, L[desc], 0)
