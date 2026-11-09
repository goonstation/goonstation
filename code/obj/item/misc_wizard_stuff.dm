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
	// The owner of this staff.
	var/wizard_key = ""
	//was for robe and wizard hat, now nothing.
	var/eldritch = 0
	duration_remove = 10 SECONDS
	// for staffs that hurt to pick up. Override pick_up_effect for actual effect
	var/hurts_to_pick_up = FALSE
	// how many charges staff has left.
	var/charges = 0
	// how many charges staff has.
	var/max_charges = 0

	New()
		..()
		BLOCK_SETUP(BLOCK_ALL)

	attack_hand(var/mob/user)
		if(!src.hurts_to_pick_up)
			return ..()
		if(check_target_immunity(user))
			return ..()
		if(!iswizard(user))
			src.pick_up_effect(user)
			return
		if (user.mind?.key != src.wizard_key)
			boutput(user, SPAN_ALERT("The [src.name] is magically attuned to another wizard! You can use it, but may not summon it magically."))
		return ..()

	pull(mob/user)
		if(!src.hurts_to_pick_up)
			return ..()

		if(check_target_immunity(user))
			return ..()

		if (!istype(user))
			return

		if (iswizard(user))
			return ..()
		else
			src.pick_up_effect(user)

	mouse_drop(atom/over_object, src_location, over_location, over_control, params)
		if(!src.hurts_to_pick_up)
			return ..()
		if (iswizard(usr))
			. = ..()
		else if(isliving(usr))
			src.pick_up_effect(usr)
		else
			return

	attackby(obj/item/W, mob/user, params)
		if (istype(W, /obj/item/magtractor) && src.hurts_to_pick_up) // for ghost drones
			src.pick_up_effect(user)
			user.changeStatus("unconscious", 3 SECONDS)
			return
		. = ..()

	// Cthulu staff pickup/attack
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
	// for staff with charges. recharges the staff.
	proc/recharge()
		if(src.charges <= src.max_charges)
			src.charges = src.max_charges
		return

	// The actual effect for when a non wizard tries to pick up a staff that hurts. Override this on the staff.
	proc/pick_up_effect(mob/user)
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
	hurts_to_pick_up = TRUE

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

	pick_up_effect(mob/user)
		src.do_brainmelt(user, 2)
		return

/obj/item/staff/thunder
	name = "staff of thunder"
	desc = "A staff sparkling with static electricty. Who's afraid of a little thunder?"
	icon_state = "staffthunder3"
	item_state = "staffthunder"
	charges = 3
	max_charges = 3
	hurts_to_pick_up = TRUE


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
		if (charges <= 0)
			boutput(user, SPAN_ALERT("[name] is out of charges! Magically recall it to restore it's power."))
			return
		charges -= 1
		var/turf/T = get_turf(target)
		var/obj/lightning_target/lightning = new/obj/lightning_target(T)
		playsound(T, 'sound/effects/electric_shock_short.ogg', 70, TRUE)
		lightning.caster = user
		UpdateIcon()
		FLICK("[icon_state]_fire", src)
		..()

	update_icon()
		if(charges > 3) //var edit only but gets a fun special sprite
			icon_state = "staffthunder_admin"
		else
			icon_state = "staffthunder[charges]"

	recharge()
		..()
		UpdateIcon()
		FLICK("[icon_state]_fire", src)

	pick_up_effect(mob/user)
		boutput(user, SPAN_ALERT("Static electricity arcs from [name] to your hand when you try and touch it!"))
		playsound(user.loc, 'sound/effects/sparks4.ogg', 70, 1)
		if (user.bioHolder?.HasEffect("resist_electric"))
			return
		else
			user.do_disorient(stamina_damage = 0, knockdown = 0, stunned = 0, disorient = 20)
		return

/obj/item/staff/monkey_staff
	name = "staff of monke"
	desc = "A staff with a cute monkey head carved into the wood."
	icon_state = "staffmonkey"
	item_state = "staffmonkey"

	New()
		. = ..()
		src.setItemSpecial(/datum/item_special/launch_projectile/monkey_organ)


// Telekinesis staff. Drag over tiles with the staff in active hand to throw people in that direction.
/obj/item/staff/telekinesis

	name = "telekinetic staff"
	desc = "A strange staff infused with the power of throwing people into vending machines."
	force = 0
	throw_range = 10
	throw_speed = 1
	throw_return = 1
	throwforce = 1
	icon_state = "stafftelekinesis"
	item_state = "staff_telekinesis"
	hurts_to_pick_up = TRUE
	charges = 4
	max_charges = 4
	// chance for the staff to boomerang back into the wiznerds face when thrown
	var/prob_clonk = 0
	// chance to send victim flying extra hard through walls
	var/super_throw_chance = 5

	New()
		. = ..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		. = ..()

	attack(mob/target, mob/user, def_zone, is_special, params) // stop hitting yourself. infact stop hitting everyone and everything.
		visible_message(SPAN_ALERT("[user] waves the [src.name] in [target]'s face!"))
		return

	pickup(mob/user)
		. = ..()
		RegisterSignal(user, COMSIG_MOB_MOUSEDROP, PROC_REF(tk_drag), override = TRUE)

	dropped(mob/user) // when staff is dropped, resets stuff
		. = ..()
		UnregisterSignal(user, COMSIG_MOB_MOUSEDROP)

// you can throw it like a boomerang, doesn't do anything but it's swag.
	throw_begin(atom/target)
		playsound(src.loc, "rustle", 50, 1)
		return ..(target)

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		if(hit_atom == usr)
			if(prob(prob_clonk))
				var/mob/living/carbon/human/user = usr
				src.pick_up_effect(user) // boastful wiznerds can get flung too
			else
				src.Attackhand(usr)
			return
		else
			if(ishuman(hit_atom))
				prob_clonk = min(prob_clonk + 5, 40)
				SPAWN(2 SECONDS)
					prob_clonk = max(prob_clonk - 5, 0)

		return ..(hit_atom)

	// click drag to throw mobs in that direction
	proc/tk_drag(mob/user, src_object, over_object, turf/src_location, turf/over_location, src_control, over_control, params)
		. = FALSE
		if (!istype(src_location) || !istype(over_location))
			return
		if (src != user.equipped())
			return
		if (!IN_RANGE(user, over_location, WIDE_TILE_WIDTH / 2) || !IN_RANGE(user, src_location, WIDE_TILE_WIDTH / 2))
			return
		if (!user.wizard_castcheck())
			return
		var/area/A = get_area(over_location)
		if (istype(A, /area/station/chapel))
			boutput(user, SPAN_ALERT("You cannot throw people on holy ground!"))
			return TRUE
		if (A?.sanctuary || istype(A, /area/wizard_station))
			boutput(user, SPAN_ALERT("You cannot throw people here!"))
			return TRUE
		if (src.charges <= 0)
			boutput(user, SPAN_ALERT("[src] is out of charges! Magically recall it to restore its power."))
			return TRUE

		var/list/mob/found_mobs	= list()
		var/list/turf/crossed_turfs = raytrace(src_location, over_location)

		for (var/turf/T as anything in crossed_turfs)
			for (var/mob/M in range(1, T))
				if (M == user || M.anchored || isintangible(M) || !isturf(M.loc))
					continue
				if (M.traitHolder?.hasTrait("training_chaplain"))
					M.visible_message(SPAN_ALERT("A divine light shields [M] from harm!"))
					continue
				if (iswizard(M))
					M.visible_message(SPAN_ALERT("A magical light shields [M] from harm!"))
					continue
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					if(H.shoes?.magnetic) // dependent on how balanced this is, should maybe add chance to go wrong so this isn't a 100% counter?
						H.visible_message(SPAN_ALERT("[M]'s magnetic shoes resist the telekinetic pull!"))
						continue
				found_mobs |= M

		if (!length(found_mobs))
			return

		src.charges -= 1
		playsound(user.loc, 'sound/impact_sounds/Energy_Hit_2.ogg', 50, TRUE)
		for (var/mob/M as anything in found_mobs)
			//try to maintain the relative offset of thrown mobs, ie throw them straight instead of at the center tile
			var/turf/throwable_turf = get_turf(M)
			var/turf/relative_turf = locate(over_location.x + (throwable_turf.x - src_location.x), over_location.y + (throwable_turf.y - src_location.y), over_location.z)
			//might be off the edge of a z level, default to throwing at the centerpoint in that event
			relative_turf ||= over_location
			M.changeStatus("telekinetic_grasp", 1 SECOND) // visual effect
			if(prob(super_throw_chance)) // rare chance to throw thru wall
				M.throw_at(get_edge_cheap(M, get_dir(M, relative_turf)), 30, 2, throw_type = THROW_THROUGH_WALL)
			else
				M.throw_at(relative_turf, 15, 2, throw_type = THROW_NORMAL)
			playsound(M.loc, "swing_hit", 50, 1)
			M.changeStatus("knockdown", 1 SECOND)
			M.force_laydown_standup()
			M.visible_message(SPAN_ALERT("<B>[M] is thrown by a mysterious force!</B>"))
		return TRUE

	pick_up_effect(mob/user)
		if(!user.anchored)
			var/turf/T = get_edge_target_turf(user, user.dir)
			playsound(user.loc, 'sound/impact_sounds/Energy_Hit_1.ogg', 50 , 1)
			user.throw_at(T, 8, 2)
			user.changeStatus("knockdown", 1 SECOND)
			user.force_laydown_standup()
			boutput(user, SPAN_ALERT("A powerful force throws you as you try to touch [name]!"))
		return

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
