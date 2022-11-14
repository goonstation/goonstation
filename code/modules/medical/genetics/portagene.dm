/obj/machinery/computer/genetics/portable
	name = "Port-A-Gene"
	desc = "A mobile scanner and computer in one unit for genetics work."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "PAG_0"
	anchored = 0
	req_access = null //will revisit later
	var/mob/occupant = null
	var/datum/map_preview/character/multiclient/occupant_preview = null
	var/locked = 0
	var/homeloc = null

	New()
		..()

		if (!islist(portable_machinery))
			portable_machinery = list()
		portable_machinery.Add(src)

		src.homeloc = src.loc
		return

	disposing()
		if (islist(portable_machinery))
			portable_machinery.Remove(src)
		if(occupant)
			occupant.set_loc(get_turf(src.loc))
			occupant = null
		..()

	examine()
		. = ..()
		. += "Home turf: [get_area(src.homeloc)]."

	mouse_drop(over_object, src_location, over_location)
		..()
		if (isobserver(usr) || isintangible(usr))
			return
		if ((usr in src.contents) || !isturf(usr.loc))
			return
		if (usr.stat || usr.getStatusDuration("stunned") || usr.getStatusDuration("weakened"))
			return
		if (BOUNDS_DIST(src, usr) > 0)
			usr.show_text("You are too far away to do this!", "red")
			return
		if (BOUNDS_DIST(over_object, src) > 0)
			usr.show_text("The [src.name] is too far away from the target!", "red")
			return
		if (!istype(over_object,/turf/simulated/floor/))
			usr.show_text("You can't set this target as the home location.", "red")
			return
		var/turf/check_loc = over_object
		if (check_loc && isturf(check_loc) && isrestrictedz(check_loc.z))
			usr.show_text("You can't set this target as the home location.", "red")
			return

		if (tgui_alert(usr, "Set selected turf as home location?", "Set home location", list("Yes", "No")) == "Yes")
			src.homeloc = over_object
			usr.visible_message("<span class='notice'><b>[usr.name]</b> changes the [src.name]'s home turf.</span>", "<span class='notice'>New home turf selected: [get_area(src.homeloc)].</span>")
			// The crusher, hell fires etc. This feature enables quite a bit of mischief.
			logTheThing(LOG_STATION, usr, "sets [src.name]'s home turf to [log_loc(src.homeloc)].")
		return

	relaymove(mob/usr as mob, dir)
		if (!isalive(usr))
			return
		if (src.locked)
			boutput(usr, "<span class='alert'><b>The scanner door is locked!</b></span>")
			return

		src.go_out()
		add_fingerprint(usr)
		playsound(src.loc, 'sound/machines/sleeper_open.ogg', 50, 1)
		return

	MouseDrop_T(mob/living/target, mob/user)
		if (!istype(target) || isAI(user))
			return

		if (BOUNDS_DIST(src, user) > 0 || BOUNDS_DIST(user, target) > 0)
			return

		if (target == user)
			go_in(target)
		else if (can_operate(user,target))
			var/previous_user_intent = user.a_intent
			user.set_a_intent(INTENT_GRAB)
			user.drop_item()
			target.Attackhand(user)
			user.set_a_intent(previous_user_intent)
			SPAWN(user.combat_click_delay + 2)
				if (can_operate(user,target))
					if (istype(user.equipped(), /obj/item/grab))
						src.Attackby(user.equipped(), user)
		return

	proc/can_operate(var/mob/M, var/mob/living/target)
		if (!isalive(M))
			return 0
		if (BOUNDS_DIST(src, M) > 0)
			return 0
		if (M.getStatusDuration("paralysis") || M.getStatusDuration("stunned") || M.getStatusDuration("weakened"))
			return 0
		if (src.occupant)
			boutput(M, "<span class='notice'><B>The scanner is already occupied!</B></span>")
			return 0
		if(ismobcritter(target))
			boutput(M, "<span class='alert'><B>The scanner doesn't support this body type.</B></span>")
			return 0
		if(!iscarbon(target) )
			boutput(M, "<span class='alert'><B>The scanner supports only carbon based lifeforms.</B></span>")
			return 0
		if (src.occupant)
			boutput(M, "<span class='notice'><B>The scanner is already occupied!</B></span>")
			return 0
		if (src.locked)
			boutput(M, "<span class='alert'><B>You need to unlock the scanner first.</B></span>")
			return 0

		.= 1

	set_broken()
		if (status & BROKEN)
			return
		var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
		smoke.set_up(5, 0, src)
		smoke.start()
		src.go_out()
		icon_state = "PAG_broken"
		light.disable()
		status |= BROKEN

	attack_hand(mob/user)
		if (src.status & BROKEN)
			boutput(user, "<span class='notice'>The [src.name] is busted! You'll need at least two sheets of glass to fix it.</span>")
			return
		. = ..()

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/sheet) && (src.status & BROKEN))
			var/obj/item/sheet/S = W
			if (S.material && S.material.material_flags & MATERIAL_CRYSTAL)
				if (S.amount >= 2)
					W.change_stack_amount(-2)
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					src.status &= !BROKEN
					src.icon_state = "PAG_0"
					light.enable()
					boutput(user, "<span class='notice'>You repair the [src.name]!</span>")
				else
					boutput(user, "<span class='alert'>You need at least two sheets of glass to repair the [src.name].</span>")
			else
				boutput(user, "<span class='alert'>This is the wrong kind of material. You'll need a type of glass or crystal.</span>")

		else if (istype(W,/obj/item/genetics_injector/dna_activator))
			var/obj/item/genetics_injector/dna_activator/DNA = W
			if (DNA.expended_properly)
				user.drop_item()
				qdel(DNA)
				activated_bonus(user)
			else if (DNA.uses < 1)
				// You get nothing from these but at least let people clean em up
				boutput(user, "You dispose of the [DNA].")
				user.drop_item()
				qdel(DNA)
			else
				src.Attackhand(user)

		else if (istype(W, /obj/item/grab))
			var/obj/item/grab/G = W

			if (src.occupant)
				boutput(user, "<span class='alert'><B>The scanner is already occupied!</B></span>")
				return

			if (src.locked)
				boutput(user, "<span class='alert'><B>You need to unlock the scanner first.</B></span>")
				return

			if(!iscarbon(G.affecting))
				boutput(user, "<span class='hint'><B>The scanner supports only carbon based lifeforms.</B></span>")
				return

			var/mob/M = G.affecting
			if (user.pulling == M)
				user.remove_pulling()
			src.go_in(M)

			for(var/obj/O in src)
				O.set_loc(src.loc)

			src.add_fingerprint(user)
			qdel(G)
			return
		else
			src.Attackhand(user)
		return

	power_change()
		return

	verb/eject()
		set name = "Eject Occupant"
		set src in oview(1)
		set category = "Local"

		if (!isalive(usr) || iswraith(usr))
			return
		if (src.locked)
			boutput(usr, "<span class='alert'><b>The scanner door is locked!</b></span>")
			return

		src.go_out()
		add_fingerprint(usr)
		playsound(src.loc, 'sound/machines/sleeper_open.ogg', 50, 1)
		return

	verb/enter()
		set name = "Enter"
		set src in oview(1)
		set category = "Local"

		if (src.status & BROKEN)
			boutput(usr, "<span class='alert'>It's broken! You'll need to repair it first.</span>")
			return
		if (!isalive(usr))
			return
		if (src.locked)
			boutput(usr, "<span class='alert'><b>The scanner door is locked!</b></span>")
			return
		if (src.occupant)
			boutput(usr, "<span class='alert'>It's already occupied.</span>")
			return

		src.go_in(usr)
		add_fingerprint(usr)
		return


	verb/lock()
		set name = "Scanner Lock"
		set src in oview(1)
		set category = "Local"

		if (!isalive(usr))
			return
		if (usr == src.occupant)
			boutput(usr, "<span class='alert'><b>You can't reach the scanner lock from the inside.</b></span>")
			return

		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		if (src.locked)
			src.locked = 0
			usr.visible_message("<b>[usr]</b> unlocks the scanner.")
			if (src.occupant)
				boutput(src.occupant, "<span class='alert'>You hear the scanner's lock slide out of place.</span>")
		else
			src.locked = 1
			usr.visible_message("<b>[usr]</b> locks the scanner.")
			if (src.occupant)
				boutput(src.occupant, "<span class='alert'>You hear the scanner's lock click into place.</span>")

	proc/go_out()
		if (!src.occupant)
			return

		if (src.locked)
			return

		for(var/obj/O in src)
			O.set_loc(src.loc)

		src.occupant.set_loc(src.loc)
		src.occupant = null
		src.icon_state = "PAG_0"
		return

	proc/go_in(var/mob/M)
		if (src.occupant || !M)
			return

		if (src.locked)
			return

		if (src.status & BROKEN)
			return

		src.ui_interact(M, null)

		M.set_loc(src)
		src.occupant = M
		src.icon_state = "PAG_1"
		playsound(src.loc, 'sound/machines/sleeper_close.ogg', 50, 1)
		return

	ui_status(mob/user)
		if (user in src)
			return UI_UPDATE
		return ..()

	get_scan_subject()
		if (!src)
			return null
		return occupant

	get_scanner()
		if (!src)
			return null
		return src

	get_occupant_preview()
		if (!src)
			return null
		if (!src.occupant_preview)
			src.occupant_preview = new()
			src.update_occupant_preview()
		return src.occupant_preview

	update_occupant_preview()
		var/mob/living/carbon/human/H = src.occupant
		if (istype(H))
			if (src.occupant_preview)
				src.occupant_preview.update_appearance(H.bioHolder.mobAppearance, H.mutantrace, name=H.real_name)
		else
			qdel(src.occupant_preview)
			src.occupant_preview = null
