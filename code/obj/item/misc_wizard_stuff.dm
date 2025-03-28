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
	w_class = W_CLASS_SMALL
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "paper"
	throw_speed = 4
	throw_range = 20
	desc = "This isn't that old, you just spilled mugwort tea on it the other day."

/obj/item/teleportation_scroll/get_desc()
	. = "Charges left: [src.uses]."

/obj/item/teleportation_scroll/attack_self(mob/user as mob)
	if (!iswizard(user))
		boutput(user, SPAN_ALERT("<b>The text is illegible!</b>"))
		return

	if (usr.getStatusDuration("unconscious") || !isalive(usr) || usr.restrained())
		return

	var/mob/living/carbon/human/H = usr
	if (!( ishuman(H)))
		return 1

	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))))
		if (src.uses >= 1 && usr.teleportscroll(1, 1, src, null, TRUE) == 1)
			src.uses -= 1
			tooltip_rebuild = TRUE

	if (!src.uses)
		boutput(user, SPAN_NOTICE("<b>The depleted scroll vanishes in a puff of smoke!</b>"))
		qdel(src)


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
	flags = TABLEPASS | NOSHIELD
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
				affected_mob.visible_message(SPAN_ALERT("[affected_mob] is knocked off-balance by the curse upon [src]!"))
				affected_mob.do_disorient(30, knockdown = 1 SECOND, stunned = 0, disorient = 1 SECOND, remove_stamina_below_zero = 0)
				affected_mob.stuttering += 2
				affected_mob.take_brain_damage(2)

			if (1)
				affected_mob.visible_message(SPAN_ALERT("[affected_mob]'s consciousness is overwhelmed by the curse upon [src]!"))
				affected_mob.show_text("Horrible visions of depravity and terror flood your mind!", "red")
				if (prob(50))
					affected_mob.emote("scream")

				affected_mob.do_disorient(80, knockdown = 5 SECONDS, stunned = 0, unconscious = 2 SECONDS, disorient = 2 SECONDS, remove_stamina_below_zero = 0)
				affected_mob.stuttering += 10
				affected_mob.take_brain_damage(6)

			else
				elecflash(affected_mob)
				affected_mob.visible_message(SPAN_ALERT("The curse upon [src] rebukes [affected_mob]!"))
				boutput(affected_mob, SPAN_ALERT("Horrible visions of depravity and terror flood your mind!"))
				affected_mob.emote("scream")
				affected_mob.changeStatus("unconscious", 8 SECONDS)
				affected_mob.changeStatus("stunned", 10 SECONDS)
				affected_mob.stuttering += 20
				affected_mob.take_brain_damage(25)

		return

	// Used by /datum/targetable/spell/summon_staff. Exposed for convenience (Convair880).
	proc/send_staff_to_target_mob(var/mob/living/M)
		if (!src || !istype(src) || !M || !istype(M))
			return

		src.visible_message(SPAN_ALERT("<b>The [src.name] is suddenly warped away!</b>"))
		elecflash(src)

		if (ismob(src.loc))
			var/mob/HH = src.loc
			HH.u_equip(src)
		src.stored?.transfer_stored_item(src, get_turf(src))
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
	eldritch = 1

	New()
		. = ..()
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

	pickup(mob/user)
		. = ..()
		if(iswizard(user))
			src.force = 14
			src.hitsound = 'sound/effects/ghost2.ogg'
			src.tooltip_rebuild = TRUE

	dropped(mob/user)
		. = ..()
		src.force = src::force
		src.hitsound = src::hitsound
		src.tooltip_rebuild = TRUE

	attack_hand(var/mob/user)
		if (user.mind)
			if (iswizard(user) || check_target_immunity(user))
				if (user.mind.key != src.wizard_key && !check_target_immunity(user))
					boutput(user, SPAN_ALERT("The [src.name] is magically attuned to another wizard! You can use it, but the staff will refuse your attempts to control or summon it."))
				..()
				return
			else
				src.do_brainmelt(user, 2)
				return
		else ..()

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (iswizard(user) && !iswizard(target) && !isdead(target) && !check_target_immunity(target))
			if (target?.traitHolder?.hasTrait("training_chaplain"))
				target.visible_message("<spab class='alert'>A divine light shields [target] from harm!</span>")
				playsound(target, 'sound/impact_sounds/Energy_Hit_1.ogg', 40, TRUE)
				JOB_XP(target, "Chaplain", 2)
				return

			if (target.get_brain_damage() >= 30 && prob(20))
				src.do_brainmelt(target, 1)
			else if (prob(35))
				src.do_brainmelt(target, 0)
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
			boutput(user, SPAN_ALERT("You cannot summon lightning on holy ground!")) //phrasing works if either target or mob are in chapel heh
			return
		if (A?.sanctuary || istype(A, /area/wizard_station))
			boutput(user, SPAN_ALERT("You cannot summon lightning in this place!"))
			return
		if (thunder_charges <= 0)
			boutput(user, SPAN_ALERT("[name] is out of charges! Magically recall it to restore it's power."))
			return
		thunder_charges -= 1
		var/turf/T = get_turf(target)
		var/obj/lightning_target/lightning = new/obj/lightning_target(T)
		playsound(T, 'sound/effects/electric_shock_short.ogg', 70, TRUE)
		lightning.caster = user
		UpdateIcon()
		FLICK("[icon_state]_fire", src)
		..()

	attack_hand(var/mob/user)
		if (user.mind)
			if (iswizard(user) || check_target_immunity(user))
				if (user.mind.key != src.wizard_key && !check_target_immunity(user))
					boutput(user, SPAN_ALERT("The [src.name] is magically attuned to another wizard! You can use it, but may not summon it magically."))
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
		FLICK("[icon_state]_fire", src)

	proc/zap_person(var/mob/target) //purposefully doesn't do any damage, here to offer non-chat feedback when trying to pick up
		boutput(target, SPAN_ALERT("Static electricity arcs from [name] to your hand when you try and touch it!"))
		playsound(target.loc, 'sound/effects/sparks4.ogg', 70, 1)
		if (target.bioHolder?.HasEffect("resist_electric"))
			return
		else
			target.do_disorient(stamina_damage = 0, knockdown = 0, stunned = 0, disorient = 20)

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
	anchored = ANCHORED
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
			. += "<br>[SPAN_SUCCESS("<b>The Corruption</b> is at [percentage]%!")]"
		else
			. += "<br>[SPAN_ALERT("<b>The Corruption</b> is at [percentage]%!")]"*/
