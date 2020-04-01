/datum/targetable/spell/teleport
	name = "Teleport"
	desc = "Teleports you to an area of your choice after a short delay."
	icon_state = "phaseshift"
	targeted = 0
	cooldown = 450
	requires_robes = 1
	cooldown_staff = 1
	restricted_area_check = 1
	voice_grim = "sound/voice/wizard/TeleportGrim.ogg"
	voice_fem = "sound/voice/wizard/TeleportFem.ogg"
	voice_other = "sound/voice/wizard/TeleportLoud.ogg"

	cast()
		if (!holder)
			return 1

		if (holder.owner && ismob(holder.owner) && holder.owner.teleportscroll(0, 3) == 1)
			return 0

		return 1

// These two procs were so similar that I combined them (Convair880).
/mob/proc/teleportscroll(var/effect = 0, var/perform_check = 0, var/obj/item_to_check = null)
	if (src.getStatusDuration("paralysis") || !isalive(src))
		boutput(src, "<span style=\"color:red\">Not when you're incapacitated.</span>")
		return 0

	if (!isturf(src.loc)) // Teleport doesn't go along well with doppelgaenger or phaseshift.
		boutput(src, "<span style=\"color:red\">You can't seem to teleport from here.</span>")
		return 0

	var/turf/T = get_turf(src)
	if (!T || !isturf(T))
		boutput(src, "<span style=\"color:red\">You can't seem to teleport from here.</span>")
		return 0
	if (isrestrictedz(T.z))
		var/area/A = get_area(T)
		if (!istype(A, /area/wizard_station))
			boutput(src, "<span style=\"color:red\">You can't seem to teleport from here.</span>")
			return 0

	var/A
	var/area/wizard_station/wiz_shuttle = locate(/area/wizard_station)
	var/area/thearea = null

	// Doing it this way to avoid modifying the cached areas
	if (wiz_shuttle)
		A = input("Area to jump to", "Teleportation", A) in (get_teleareas() | wiz_shuttle.name)
		if(A == wiz_shuttle.name)
			thearea = wiz_shuttle
	else
		A = input("Area to jump to", "Teleportation", A) in get_teleareas()

	if(!thearea)
		thearea = get_telearea(A)

	if (!thearea || !istype(thearea))
		src.show_text("Invalid selection.", "red")
		return 0

	// You can keep the selection window open, so we have to do the checks again (individual item/spell procs handle the first batch).
	switch (perform_check)
		if (1)
			var/obj/item/teleportation_scroll/scroll_check = item_to_check
			if (!scroll_check || !istype(scroll_check))
				src.show_text("The scroll appears to have been destroyed.", "red")
				return 0
			if (!iswizard(src))
				boutput(src, "<span style=\"color:red\">The scroll is illegible!</span>")
				return 0
			if (scroll_check.uses < 1)
				src.show_text("The scroll is depleted!", "src")
				return 0
			if (scroll_check.loc != src && scroll_check.loc != src.back) // Pocket or backpack.
				src.show_text("You reach for the scroll, but it's just too far away.", "red")
				return 0

		if (2)
			var/obj/machinery/computer/pod/comp_check = item_to_check
			if (!comp_check || !istype(comp_check))
				src.show_text("The computer appears to have been destroyed.", "red")
				return 0
			if (comp_check.status & (NOPOWER|BROKEN))
				src.show_text("[comp_check] is out of order.", "red")
				return 0
			if (get_dist(src, comp_check) > 1)
				src.show_text("[comp_check] is too far away.", "red")
				return 0

		if (3)
			/*if (!iswizard(src))
				boutput(src, "<span style=\"color:red\">You seem to have lost all magical abilities.</span>")
				return 0*/
			if (src.wizard_castcheck() == 0)
				return 0 // Has own user feedback.

	if (src.getStatusDuration("paralysis") || !isalive(src))
		boutput(src, "<span style=\"color:red\">Not when you're incapacitated.</span>")
		return 0

	if (!isturf(src.loc))
		boutput(src, "<span style=\"color:red\">You can't seem to teleport from here.</span>")
		return 0

	var/turf/T2 = get_turf(src)
	if (!T2 || !isturf(T2))
		boutput(src, "<span style=\"color:red\">You can't seem to teleport from here.</span>")
		return 0
	if (isrestrictedz(T2.z))
		var/area/Arr = get_area(T2)
		if (!istype(Arr, /area/wizard_station))
			boutput(src, "<span style=\"color:red\">You can't seem to teleport from here.</span>")
			return 0

	switch (perform_check)
		if (1)
			src.visible_message("<span style=\"color:red\"><b>[src] magically disappears!</b></span>")

		if (2)
			src.visible_message("<span style=\"color:red\"><b>[src]</b> presses a button and teleports away.</span>")

		if (3) // Spell-specific stuff.
			src.say("SCYAR NILA [uppertext(A)]")
			..()

			src.visible_message("<span style=\"color:red\"><b>[src] begins to fade away!</b></span>")
			animate_teleport_wiz(src)
			sleep(40) // Animation.

			var/mob/living/carbon/human/H = src
			if (istype(H) && H.getStatusDuration("burning"))
				boutput(H, "<span style=\"color:blue\">The flames sputter out as you phase shift.</span>")
				H.set_burning(0)

			playsound(src.loc, "sound/effects/mag_teleport.ogg", 25, 1, -1)

	var/list/L = list()
	for (var/turf/T3 in get_area_turfs(thearea.type))
		if (!T3.density)
			var/clear = 1
			for (var/obj/O in T3)
				if (O.density)
					clear = 0
					break
			if (clear)
				L += T3

	if (effect)
		var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
		s.set_up(5, 1, src.loc)

		if (perform_check == 3)
			src.set_loc(pick(L))
			s.start() // Effect second because we had sound effects etc at the old loc.
		else
			s.start()
			src.set_loc(pick(L))

	else
		var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
		smoke.set_up(5, 0, src.loc)
		smoke.attach(src)

		if (perform_check == 3)
			src.set_loc(pick(L))
			smoke.start()
		else
			smoke.start()
			src.set_loc(pick(L))

	return 1
