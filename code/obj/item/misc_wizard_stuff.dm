// Contains:
// - Teleportation scroll
// - Staves
// - Magic mirror

// // // // // // // // // // Teleportation scroll // // // // // // // // // // // //

/obj/item/teleportation_scroll
	name = "Teleportation Scroll"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll_seal"
	var/uses = 4
	flags = FPRINT | TABLEPASS
	w_class = W_CLASS_SMALL
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "paper"
	throw_speed = 4
	throw_range = 20
	desc = "This isn't that old, you just spilled mugwort tea on it the other day."

/obj/item/teleportation_scroll/attack_self(mob/user as mob)
	src.add_dialog(user)
	var/dat = ""
	if (!iswizard(user))
		src.remove_dialog(user)
		boutput(user, "<span class='alert'><b>The text is illegible!</b></span>")
		return
	if (!src.uses)
		boutput(user, "<span class='notice'><b>The depleted scroll vanishes in a puff of smoke!</b></span>")
		src.remove_dialog(user)
		user.Browse(null,"window=scroll")
		qdel(src)
		return
	dat += "<b>Teleportation Scroll:</b><br><br>"
	dat += "Charges left: [src.uses]<br><hr><br>"
	dat += "<A href='byond://?src=\ref[src];spell_teleport=1'>Teleport</A><br><br><hr>"
	user.Browse(dat,"window=scroll")
	onclose(user, "scroll")
	return

/obj/item/teleportation_scroll/Topic(href, href_list)
	..()
	if (usr.getStatusDuration("paralysis") || !isalive(usr) || usr.restrained())
		return
	var/mob/living/carbon/human/H = usr
	if (!( ishuman(H)))
		return 1
	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))))
		src.add_dialog(usr)
		if (href_list["spell_teleport"])
			if (src.uses >= 1 && usr.teleportscroll(1, 1, src, null, TRUE) == 1)
				src.uses -= 1
		if (ismob(src.loc))
			attack_self(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					src.attack_self(M)
	return

////////////////////////////////////////////////////// Staves /////////////////////////////////////////////////////

/obj/item/staff
	name = "wizard's staff"
	desc = "A magical staff used for channeling spells. It's got a little crystal ball on the end."
	icon = 'icons/obj/wizard.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "staff"
	item_state = "staff"
	force = 3
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	health = 8
	w_class = W_CLASS_SMALL
	flags = FPRINT | TABLEPASS | NOSHIELD
	object_flags = NO_ARM_ATTACH
	var/wizard_key = "" // The owner of this staff.
	var/eldritch = 0	//was for robe and wizard hat, now nothing.
	duration_remove = 10 SECONDS

	New()
		..()
		BLOCK_SETUP(BLOCK_ALL)

	// Part of the parent for convenience.
	proc/do_brainmelt(var/mob/affected_mob, var/severity = 2)
		if (!src || !istype(src) || !affected_mob || !ismob(affected_mob) || check_target_immunity(affected_mob))
			return

		switch (severity)
			if (0)
				affected_mob.visible_message("<span class='alert'>[affected_mob] is knocked off-balance by the curse upon [src]!</span>")
				affected_mob.do_disorient(30, weakened = 1 SECOND, stunned = 0, disorient = 1 SECOND, remove_stamina_below_zero = 0)
				affected_mob.stuttering += 2
				affected_mob.take_brain_damage(2)

			if (1)
				affected_mob.visible_message("<span class='alert'>[affected_mob]'s consciousness is overwhelmed by the curse upon [src]!</span>")
				affected_mob.show_text("Horrible visions of depravity and terror flood your mind!", "red")
				if (prob(50))
					affected_mob.emote("scream")

				affected_mob.do_disorient(80, weakened = 5 SECONDS, stunned = 0, paralysis = 2 SECONDS, disorient = 2 SECONDS, remove_stamina_below_zero = 0)
				affected_mob.stuttering += 10
				affected_mob.take_brain_damage(6)

			else
				elecflash(affected_mob)
				affected_mob.visible_message("<span class='alert'>The curse upon [src] rebukes [affected_mob]!</span>")
				boutput(affected_mob, "<span class='alert'>Horrible visions of depravity and terror flood your mind!</span>")
				affected_mob.emote("scream")
				affected_mob.changeStatus("paralysis", 8 SECONDS)
				affected_mob.changeStatus("stunned", 10 SECONDS)
				affected_mob.stuttering += 20
				affected_mob.take_brain_damage(25)

		return

	// Used by /datum/targetable/spell/summon_staff. Exposed for convenience (Convair880).
	proc/send_staff_to_target_mob(var/mob/living/M)
		if (!src || !istype(src) || !M || !istype(M))
			return

		src.visible_message("<span class='alert'><b>The [src.name] is suddenly warped away!</b></span>")
		elecflash(src)

		if (ismob(src.loc))
			var/mob/HH = src.loc
			HH.u_equip(src)
		if (istype(src.loc, /obj/item/storage))
			var/obj/item/storage/S_temp = src.loc
			var/datum/hud/storage/H_temp = S_temp.hud
			H_temp.remove_object(src)
		if(istype(src.loc, /mob/living/critter/small_animal/snake))
			var/atom/movable/snake = src
			while(istype(snake.loc, /mob/living/critter/small_animal/snake))
				snake = snake.loc
			snake.set_loc(get_turf(M))
			M.show_text("Staff snake summoned successfully. You can find it on the floor at your current location.", "blue")
			return

		src.set_loc(get_turf(M))
		if (!M.put_in_hand(src))
			M.show_text("Staff summoned successfully. You can find it on the floor at your current location.", "blue")
		else
			M.show_text("Staff summoned successfully. You can find it in your hand.", "blue")

		return

/obj/item/staff/crystal // goes with Gannets' purple wizard robes - it looks different, and that's about it  :I  (always b fabulous)
	name = "crystal wizard's staff"
	desc = "A magical staff used for channeling spells. It's got a big crystal on the end."
	icon_state = "staff_crystal"
	item_state = "staff_crystal"

/obj/item/staff/cthulhu
	name = "staff of cthulhu"
	desc = "A dark staff infused with eldritch power. Trying to steal this is probably a bad idea."
	icon_state = "staffcthulhu"
	item_state = "staffcthulhu"
	force = 14
	hitsound = 'sound/effects/ghost2.ogg'
	eldritch = 1

	New()
		. = ..()
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

	attack_hand(var/mob/user)
		if (user.mind)
			if (iswizard(user) || check_target_immunity(user))
				if (user.mind.key != src.wizard_key && !check_target_immunity(user))
					boutput(user, "<span class='alert'>The [src.name] is magically attuned to another wizard! You can use it, but the staff will refuse your attempts to control or summon it.</span>")
				..()
				return
			else
				src.do_brainmelt(user, 2)
				return
		else ..()

	attack(mob/M, mob/user)
		if (iswizard(user) && !iswizard(M) && !isdead(M) && !check_target_immunity(M))
			if (M?.traitHolder?.hasTrait("training_chaplain"))
				M.visible_message("<spab class='alert'>A divine light shields [M] from harm!</span>")
				playsound(M, 'sound/impact_sounds/Energy_Hit_1.ogg', 40, 1)
				JOB_XP(M, "Chaplain", 2)
				return

			if (M.get_brain_damage() >= 30 && prob(20))
				src.do_brainmelt(M, 1)
			else if (prob(35))
				src.do_brainmelt(M, 0)
		..()
		return

	mouse_drop(atom/over_object, src_location, over_location, over_control, params)
		if (iswizard(usr) || check_target_immunity(usr))
			. = ..()
		else if(isliving(usr))
			src.do_brainmelt(usr, 1)
		else
			return

	pull(mob/user)
		if(check_target_immunity(user))
			return ..()

		if (!istype(user))
			return

		if (iswizard(user))
			return ..()
		else
			src.do_brainmelt(user, 2)
			return

/obj/item/staff/thunder
	name = "staff of thunder"
	desc = "A staff sparkling with static electricty. Who's afraid of a little thunder?"
	icon_state = "staffthunder3"
	item_state = "staffthunder"
	var/thunder_charges = 3

	New()
		. = ..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		. = ..()

	pixelaction(atom/target, params, mob/user, reach)
		if(!IN_RANGE(user, target, WIDE_TILE_WIDTH / 2))
			return
		if (!user.wizard_castcheck())
			return
		var/area/A = get_area(target)
		if (istype(A, /area/station/chapel))
			boutput(user, "<span class='alert'>You cannot summon lightning on holy ground!</span>") //phrasing works if either target or mob are in chapel heh
			return
		if (A?.sanctuary || istype(A, /area/wizard_station))
			boutput(user, "<span class='alert'>You cannot summon lightning in this place!</span>")
			return
		if (thunder_charges <= 0)
			boutput(user, "<span class='alert'>[name] is out of charges! Magically recall it to restore it's power.</span>")
			return
		thunder_charges -= 1
		var/turf/T = get_turf(target)
		var/obj/lightning_target/lightning = new/obj/lightning_target(T)
		playsound(T, 'sound/effects/electric_shock_short.ogg', 70, 1)
		lightning.caster = user
		UpdateIcon()
		flick("[icon_state]_fire", src)
		..()

	attack_hand(var/mob/user)
		if (user.mind)
			if (iswizard(user) || check_target_immunity(user))
				if (user.mind.key != src.wizard_key && !check_target_immunity(user))
					boutput(user, "<span class='alert'>The [src.name] is magically attuned to another wizard! You can use it, but may not summon it magically.</span>")
				..()
				return
			else
				zap_person(user)
				return
		else ..()

	pull(mob/user)
		if(check_target_immunity(user))
			return ..()

		if (!istype(user))
			return

		if (iswizard(user))
			return ..()
		else
			zap_person(user)
			return

	mouse_drop(atom/over_object, src_location, over_location, over_control, params)
		if (iswizard(usr))
			. = ..()
		else if(isliving(usr))
			zap_person(usr)
		else
			return

	update_icon()
		if(thunder_charges > 3) //var edit only but gets a fun special sprite
			icon_state = "staffthunder_admin"
		else
			icon_state = "staffthunder[thunder_charges]"

	proc/recharge_thunder()
		if(thunder_charges <= 3) //doesn't ever reduce charge even though three is usually max
			thunder_charges = 3
		UpdateIcon()
		flick("[icon_state]_fire", src)

	proc/zap_person(var/mob/target) //purposefully doesn't do any damage, here to offer non-chat feedback when trying to pick up
		boutput(target, "<span class='alert'>Static electricity arcs from [name] to your hand when you try and touch it!</span>")
		playsound(target.loc, 'sound/effects/sparks4.ogg', 70, 1)
		if (target.bioHolder?.HasEffect("resist_electric"))
			return
		else
			target.do_disorient(stamina_damage = 0, weakened = 0, stunned = 0, disorient = 20)

/obj/item/staff/monkey_staff
	name = "staff of monke"
	desc = "A staff with a cute monkey head carved into the wood."
	icon_state = "staffmonkey"
	item_state = "staffmonkey"

	New()
		. = ..()
		src.setItemSpecial(/datum/item_special/launch_projectile/monkey_organ)

/////////////////////////////////////////////////////////// Magic mirror /////////////////////////////////////////////

/obj/magicmirror
	desc = "An old mirror. A bit eeky and ooky."
	name = "Magic Mirror"
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "wizard_mirror"
	anchored = 1
	opacity = 0
	density = 0

	get_desc(dist)
		if (!iswizard(usr))
			return "There's nothing special about it."

		var/T = null
		var/W_count = 0
		T = "<b>Dark ritual of all wizards:</b>"

		// Teamwork, perhaps? The M.is_target check that used to be here doesn't cut it in the mixed game mode (Convair880).
		for (var/datum/mind/M in ticker.minds)
			if (M?.special_role == ROLE_WIZARD && M.current)
				W_count++
				T += "<hr>"
				T += "<b>[M.current.real_name]'s objectives:</b>"
				var/i = 1
				for (var/datum/objective/O in M.objectives)
					if (istype(O, /datum/objective/crew))
						continue
					T += "<br>#[i]: [O.explanation_text]"
					i++

		if (W_count <= 0)
			return "There's nothing special about it."
		return T

		/*var/corrupt = 0
		var/count = 0
		for(var/turf/simulated/floor/T in world)
			LAGCHECK(LAG_LOW)
			if(T.z != 1) continue
			count++
			if(T.loc:corrupted) corrupt++
		var/percentage
		percentage = (corrupt / count) * 100
		if (corrupt >= 2100)
			. += "<br><span class='success'><b>The Corruption</b> is at [percentage]%!</span>"
		else
			. += "<br><span class='alert'><b>The Corruption</b> is at [percentage]%!</span>"*/
