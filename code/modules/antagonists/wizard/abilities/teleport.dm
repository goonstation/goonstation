/datum/targetable/spell/teleport
	name = "Teleport"
	desc = "Teleports you to an area of your choice after a short delay."
	icon_state = "teleport"
	targeted = 0
	cooldown = 450
	requires_robes = 1
	cooldown_staff = 1
	restricted_area_check = ABILITY_AREA_CHECK_ALL_RESTRICTED_Z
	maptext_colors = list("#39ffba", "#05bd82", "#038463", "#05bd82")

	cast()
		if (!holder)
			return 1

		if (holder.owner && ismob(holder.owner) && holder.owner.teleportscroll(1, 3, spell=src) == 1)
			return 0

		return 1

// These two procs were so similar that I combined them (Convair880).
/mob/proc/teleportscroll(var/effect = 0, var/perform_check = 0, var/obj/item_to_check = null, var/datum/targetable/spell/teleport/spell, var/abort_if_incapacitated = FALSE)
	var/voice_grim = 'sound/voice/wizard/TeleportGrim.ogg'
	var/voice_fem = 'sound/voice/wizard/TeleportFem.ogg'
	var/voice_other = 'sound/voice/wizard/TeleportLoud.ogg'

	if (src.getStatusDuration("paralysis") || !isalive(src))
		boutput(src, "<span class='alert'>Not when you're incapacitated.</span>")
		return 0

	if (!isturf(src.loc)) // Teleport doesn't go along well with doppelgaenger or phaseshift.
		boutput(src, "<span class='alert'>You can't seem to teleport from here.</span>")
		return 0

	var/turf/T = get_turf(src)
	if (!T || !isturf(T))
		boutput(src, "<span class='alert'>You can't seem to teleport from here.</span>")
		return 0
	if (isrestrictedz(T.z))
		var/area/A = get_area(T)
		if (!istype(A, /area/wizard_station))
			boutput(src, "<span class='alert'>You can't seem to teleport from here.</span>")
			return 0

	var/A
	var/area/wizard_station/wiz_shuttle = locate(/area/wizard_station)
	var/area/thearea = null
	//if you have a teleport ring, you can't go to the wizard's den. lame src istypes, but I'm too lazy and tired to care right now. It should work.
	if(ishuman(src) && istype(src:gloves, /obj/item/clothing/gloves/ring/wizard/teleport))
		wiz_shuttle = null
	else if (iscritter(src) && locate(/obj/item/clothing/gloves/ring/wizard/teleport) in src)
		wiz_shuttle = null

	// Doing it this way to avoid modifying the cached areas
	var/list/tele_areas = get_teleareas()
	if (wiz_shuttle)
		tele_areas |= wiz_shuttle.name
		A = tgui_input_list(src, "Area to jump to", "Teleportation", tele_areas)
		if(A == wiz_shuttle.name)
			thearea = wiz_shuttle
	else
		A = tgui_input_list(src, "Area to jump to", "Teleportation", tele_areas)

	if(abort_if_incapacitated && !can_act(src))
		boutput(src, "<span class='alert'>Not when you're incapacitated.</span>")
		return 0

	if(!thearea)
		if (isnull(A))
			boutput(src, "<span class='alert'>Invalid area selected.</span>")
			return 0
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
				boutput(src, "<span class='alert'>The scroll is illegible!</span>")
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
			if (BOUNDS_DIST(src, comp_check) > 0)
				src.show_text("[comp_check] is too far away.", "red")
				return 0

		if (3)
			/*if (!iswizard(src))
				boutput(src, "<span class='alert'>You seem to have lost all magical abilities.</span>")
				return 0*/
			if (src.wizard_castcheck(spell) == 0)
				return 0 // Has own user feedback.

	if (src.getStatusDuration("paralysis") || !isalive(src))
		boutput(src, "<span class='alert'>Not when you're incapacitated.</span>")
		return 0

	if (!isturf(src.loc))
		boutput(src, "<span class='alert'>You can't seem to teleport from here.</span>")
		return 0

	var/turf/T2 = get_turf(src)
	if (!T2 || !isturf(T2))
		boutput(src, "<span class='alert'>You can't seem to teleport from here.</span>")
		return 0
	if (isrestrictedz(T2.z))
		var/area/Arr = get_area(T2)
		if (!istype(Arr, /area/wizard_station))
			boutput(src, "<span class='alert'>You can't seem to teleport from here.</span>")
			return 0

	switch (perform_check)
		if (1)
			src.visible_message("<span class='alert'><b>[src] magically disappears!</b></span>")
		if (2)
			src.visible_message("<span class='alert'><b>[src]</b> presses a button and teleports away.</span>")
			var/datum/targetable/spell/teleport/tele = src.abilityHolder.getAbility(/datum/targetable/spell/teleport)
			if(istype(tele))
				boutput(src, "<span class='notice'>The teleport computer interferes with your teleport spell.</span>")
				tele.doCooldown()

		if (3) // Spell-specific stuff.
			src.say("SCYAR NILA [uppertext(A)]", FALSE, spell.maptext_style, spell.maptext_colors)
			if(ishuman(src))
				var/mob/living/carbon/human/O = src
				if(istype(O.wear_suit, /obj/item/clothing/suit/wizrobe/necro) && istype(O.head, /obj/item/clothing/head/wizard/necro))
					playsound(O.loc, voice_grim, 50, 0, -1)
				else if(O.gender == "female")
					playsound(O.loc, voice_fem, 50, 0, -1)
				else
					playsound(O.loc, voice_other, 50, 0, -1)
			src.visible_message("<span class='alert'><b>[src] begins to fade away!</b></span>")
			var/mob/living/carbon/human/H = src
			if (istype(H) && H.getStatusDuration("burning"))
				boutput(H, "<span class='notice'>The flames sputter out as you teleport.</span>")
				H.set_burning(0)

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

	var/turf/destination = pick(L)
	logTheThing(LOG_COMBAT, src, "teleported from [log_loc(src)] to [log_loc(destination)].")
	if (effect)
		animate_teleport_wiz(src)
		sleep(2 SECONDS) // Animation.
		playsound(src.loc, 'sound/effects/mag_teleport.ogg', 25, 1, -1)
		sleep(2 SECONDS) // Animation.
		var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
		smoke.set_up(5, 0, src.loc)
		smoke.attach(src)

		playsound(destination, 'sound/effects/mag_teleport.ogg', 25, 1, -1)
		src.set_loc(destination)
		smoke.start()

	return 1
