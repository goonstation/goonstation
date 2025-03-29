// Added support for old-style grenades (Convair880).

#define HAS_TRIGGERABLE(x) (x.grenade || x.grenade_old || x.pipebomb || x.arm || x.signaler || x.butt || x.gimmickbomb)
/obj/item/mousetrap
	name = "mousetrap"
	desc = "A handy little spring-loaded trap for catching pesty rodents."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "mousetrap"
	item_state = "mousetrap"
	w_class = W_CLASS_TINY
	item_function_flags = OBVIOUS_INTERACTION_BAR //no hidden placement of armed mousetraps in other peoples backpacks
	force = null
	throwforce = null
	var/armed = FALSE
	var/obj/item/chem_grenade/grenade = null
	var/obj/item/old_grenade/grenade_old = null
	var/obj/item/pipebomb/bomb/pipebomb = null
	var/obj/item/device/radio/signaler/signaler = null
	var/obj/item/reagent_containers/food/snacks/pie/pie = null
	var/obj/item/parts/arm = null
	var/obj/item/clothing/head/butt/butt = null
	var/obj/item/gimmickbomb/gimmickbomb = null
	var/mob/armer = null
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 5
	event_handler_flags = USE_FLUID_ENTER

	armed
		icon_state = "mousetraparmed"
		armed = TRUE

		cleaner
			name = "cleantrap"

			New()
				..()
				src.UpdateOverlays(image('icons/obj/items/weapons.dmi', "trap-grenade"), "triggerable")
				src.grenade = new /obj/item/chem_grenade/cleaner(src)
				return

	New()
		..()
		RegisterSignal(src, COMSIG_MOVABLE_FLOOR_REVEALED, PROC_REF(triggered))

	examine()
		. = ..()
		if (src.armed)
			. += SPAN_ALERT("It looks like it's armed.")

	attack_self(mob/user as mob)
		if (!src.armed)
			icon_state = "mousetraparmed"
			user.show_text("You arm the mousetrap.", "blue")
			set_armer(user)
		else
			icon_state = "mousetrap"
			if ((user.get_brain_damage() >= 60 || user.bioHolder.HasEffect("clumsy")) && prob(50))
				var/which_hand = "l_arm"
				if (!user.hand)
					which_hand = "r_arm"
				src.triggered(user, which_hand)
				JOB_XP(user, "Clown", 1)
				user.visible_message(SPAN_ALERT("<B>[user] accidentally sets off the mousetrap, breaking their fingers.</B>"),\
				SPAN_ALERT("<B>You accidentally trigger the mousetrap!</B>"))
				return
			user.show_text("You disarm the mousetrap.", "blue")
			clear_armer()

		src.armed = !src.armed
		playsound(user.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -3)
		return

	proc/clear_armer()
		UnregisterSignal(armer, COMSIG_PARENT_PRE_DISPOSING)
		armer = null

	proc/set_armer(mob/user)
		RegisterSignal(user, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(clear_armer))
		armer = user

	disposing()
		clear_armer()
		UnregisterSignal(src, COMSIG_MOVABLE_FLOOR_REVEALED)
		. = ..()

	attack_hand(mob/user)
		if (ismobcritter(user))
			var/mob/living/critter/critter = user
			if (critter.ghost_spawned)
				critter.show_text(SPAN_ALERT("<b>Sensing the danger, you shy away from [src].</b>"))
				return
		if (src.armed)
			if ((user.get_brain_damage() >= 60 || user.bioHolder.HasEffect("clumsy")) && prob(50))
				var/which_hand = "l_arm"
				if (!user.hand)
					which_hand = "r_arm"
				src.triggered(user, which_hand)
				JOB_XP(user, "Clown", 1)
				user.visible_message(SPAN_ALERT("<B>[user] accidentally sets off the mousetrap, breaking their fingers.</B>"),\
				SPAN_ALERT("<B>You accidentally trigger the mousetrap!</B>"))
				return
		..()
		return

	pull(mob/living/critter/user)
		if (istype(user) && user.ghost_spawned)
			user.show_text(SPAN_ALERT("<b>Sensing the danger, you shy away from [src].</b>"))
			return TRUE
		return ..()

	attackby(obj/item/C, mob/user)
		if (istype(C, /obj/item/chem_grenade) && !HAS_TRIGGERABLE(src))
			var/obj/item/chem_grenade/CG = C
			var/grenade_ready = TRUE
			if(istype(CG, /obj/item/chem_grenade/custom))
				//we want to only fit custom grenades if they are ready to be applied
				var/obj/item/chem_grenade/custom/custom_grenade = CG
				if (custom_grenade.stage != 2)
					grenade_ready = FALSE

			if (grenade_ready && !CG.armed)
				if(!(src in user.equipped_list()))
					boutput(user, SPAN_ALERT("You need to be holding [src] in order to attach anything to it."))
					return

				user.u_equip(CG)
				CG.set_loc(src)
				user.show_text("You attach [CG]'s detonator to [src].", "blue")
				src.grenade = CG
				src.UpdateOverlays(image('icons/obj/items/weapons.dmi', "trap-grenade"), "triggerable")
				src.w_class = max(src.w_class, C.w_class)

				if(CG.is_dangerous)
					message_admins("[key_name(user)] rigs [src] with [CG] at [log_loc(user)].")
				logTheThing(LOG_BOMBING, user, "rigs [src] with [CG] at [log_loc(user)].")

		else if (istype(C, /obj/item/old_grenade/) && !HAS_TRIGGERABLE(src))
			var/obj/item/old_grenade/OG = C
			if (OG.not_in_mousetraps == 0 && !OG.armed)
				if(!(src in user.equipped_list()))
					boutput(user, SPAN_ALERT("You need to be holding [src] in order to attach anything to it."))
					return

				user.u_equip(OG)
				OG.set_loc(src)
				user.show_text("You attach [OG]'s detonator to [src].", "blue")
				src.grenade_old = OG
				src.UpdateOverlays(image('icons/obj/items/weapons.dmi', "trap-grenade"), "triggerable")
				src.w_class = max(src.w_class, C.w_class)

				if(OG.is_dangerous)
					message_admins("[key_name(user)] rigs [src] with [OG] at [log_loc(user)].")
				logTheThing(LOG_BOMBING, user, "rigs [src] with [OG] at [log_loc(user)].")

		else if (istype(C, /obj/item/pipebomb/bomb) && !HAS_TRIGGERABLE(src))
			var/obj/item/pipebomb/bomb/PB = C
			if (!PB.armed)
				if(!(src in user.equipped_list()))
					boutput(user, SPAN_ALERT("You need to be holding [src] in order to attach anything to it."))
					return

				user.u_equip(PB)
				PB.set_loc(src)
				user.show_text("You attach [PB]'s detonator to [src].", "blue")
				src.pipebomb = PB
				src.UpdateOverlays(image('icons/obj/items/weapons.dmi', "trap-pipebomb"), "triggerable")
				src.w_class = max(src.w_class, C.w_class)

				message_admins("[key_name(user)] rigs [src] with [PB] at [log_loc(user)].")
				logTheThing(LOG_BOMBING, user, "rigs [src] with [PB] at [log_loc(user)].")

		else if (istype(C, /obj/item/device/radio/signaler) && !HAS_TRIGGERABLE(src))
			if(!(src in user.equipped_list()))
				boutput(user, SPAN_ALERT("You need to be holding [src] in order to attach anything to it."))
				return

			var/obj/item/device/radio/signaler/S = C
			user.u_equip(S)
			S.set_loc(src)
			user.show_text("You attach [S]'s detonator to [src].", "blue")
			src.signaler = S
			src.UpdateOverlays(image('icons/obj/items/weapons.dmi', "trap-signaler"), "triggerable")
			src.w_class = max(src.w_class, C.w_class)

			message_admins("[key_name(user)] rigs [src] with [S] at [log_loc(user)].")
			logTheThing(LOG_BOMBING, user, "rigs [src] with [S] at [log_loc(user)].")

		else if (!src.arm && (istype(C, /obj/item/parts/robot_parts/arm) || istype(C, /obj/item/parts/human_parts/arm)) && !HAS_TRIGGERABLE(src))
			if(!(src in user.equipped_list()))
				boutput(user, SPAN_ALERT("You need to be holding [src] in order to attach anything to it."))
				return

			user.u_equip(C)
			src.arm = C
			C.set_loc(src)
			src.UpdateOverlays(image(C.icon, C.icon_state), "triggerable")
			user.show_text("You add [C] to [src].", "blue")
		//this check needs to exclude the arm one
		else if (istype(C, /obj/item/reagent_containers/food/snacks/pie) && !src.grenade && !src.grenade_old && !src.pipebomb  && !src.signaler && !src.butt && !src.gimmickbomb)
			if (src.pie)
				user.show_text("There's already a pie attached to [src]!", "red")
				return
			else if (!src.arm)
				user.show_text("You can't quite seem to get [C] to stay on [src]. Seems like it needs something to hold it in place.", "red")
				return
			else if (C.w_class > W_CLASS_TINY) // Transfer valve bomb pies are a thing. Shouldn't fit in a backpack, much less a box.
				user.show_text("[C] is way too large. You can't find any way to balance it on the arm.", "red")
				return
			if(!(src in user.equipped_list()))
				boutput(user, SPAN_ALERT("You need to be holding [src] in order to attach anything to it."))
				return

			user.u_equip(C)
			src.pie = C
			C.set_loc(src)
			src.UpdateOverlays(image(C.icon, C.icon_state), "triggerable")
			src.w_class = max(src.w_class, C.w_class)
			user.show_text("You carefully set [C] in [src]'s [src.arm].", "blue")

			logTheThing(LOG_BOMBING, user, "rigs [src] with [src.arm] and [C] at [log_loc(user)].")

		else if (istype(C, /obj/item/clothing/head/butt) && !HAS_TRIGGERABLE(src))
			if(!(src in user.equipped_list()))
				boutput(user, SPAN_ALERT("You need to be holding [src] in order to attach anything to it."))
				return

			var/obj/item/clothing/head/butt/B = C
			user.u_equip(B)
			B.set_loc(src)
			user.show_text("You attach [B] to [src].", "blue")
			src.butt = B
			src.UpdateOverlays(image('icons/obj/items/weapons.dmi', "trap-[src.butt.icon_state]"), "triggerable")

		else if (istype(C, /obj/item/gimmickbomb) && !HAS_TRIGGERABLE(src))
			if(!(src in user.equipped_list()))
				boutput(user, SPAN_ALERT("You need to be holding [src] in order to attach anything to it."))
				return

			var/obj/item/gimmickbomb/BB = C
			user.u_equip(BB)
			BB.set_loc(src)
			user.show_text("You attach [BB] to [src].", "blue")
			src.gimmickbomb = BB
			if (istype(BB, /obj/item/gimmickbomb/butt))
				src.UpdateOverlays(image('icons/obj/items/weapons.dmi', "trap-buttbomb"), "triggerable")
			else
				src.UpdateOverlays(image(BB.icon, BB.icon_state), "triggerable")

		else if (iswrenchingtool(C))
			if (src.grenade)
				user.show_text("You detach [src.grenade].", "blue")
				src.grenade.set_loc(get_turf(src))
				src.grenade = null
			else if (src.grenade_old)
				user.show_text("You detach [src.grenade_old].", "blue")
				src.grenade_old.set_loc(get_turf(src))
				src.grenade_old = null
			else if (src.pipebomb)
				user.show_text("You detach [src.pipebomb].", "blue")
				src.pipebomb.set_loc(get_turf(src))
				src.pipebomb = null
			else if (src.signaler)
				user.show_text("You detach [src.signaler].", "blue")
				src.signaler.set_loc(get_turf(src))
				src.signaler = null
			else if (src.pie)
				user.show_text("You remove [src.pie] from [src].", "blue")
				src.pie.layer = initial(src.pie.layer)
				src.pie.set_loc(get_turf(src))
				src.pie = null
			else if (src.arm)
				user.show_text("You remove [src.arm] from [src].", "blue")
				src.arm.layer = initial(src.arm.layer)
				src.arm.set_loc(get_turf(src))
				src.arm = null
			else if (src.butt)
				user.show_text("You remove [src.butt] from [src].", "blue")
				src.butt.layer = initial(src.butt.layer)
				src.butt.set_loc(get_turf(src))
				src.butt = null
			else if (src.gimmickbomb)
				user.show_text("You remove [src.gimmickbomb] from [src].", "blue")
				src.gimmickbomb.layer = initial(src.gimmickbomb.layer)
				src.gimmickbomb.set_loc(get_turf(src))
				src.gimmickbomb = null
			src.UpdateOverlays(null, "triggerable")
		else
			..()
		return

	Crossed(atom/movable/AM as mob|obj)
		if ((ishuman(AM)) && (src.armed))
			var/mob/living/carbon/H = AM
			if (H.m_intent == "run")
				src.triggered(H)
				H.visible_message(SPAN_ALERT("<B>[H] accidentally steps on the mousetrap.</B>"),\
				SPAN_ALERT("<B>You accidentally step on the mousetrap!</B>"))

		else if (istype(AM, /mob/living/critter/wraith/plaguerat/adult) && src.armed)
			var/mob/living/critter/wraith/plaguerat/P = AM
			playsound(src.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 50, 1)
			icon_state = "mousetrap"
			src.armed = FALSE
			clear_armer()
			src.visible_message(SPAN_ALERT("<b>[P] is caught in the trap and squeals in pain!</b>"))
			P.setStatus("stunned", 3 SECONDS)
			random_brute_damage(P, 20)

		else if (istype(AM, /mob/living/critter/wraith/plaguerat) && src.armed)
			var/mob/living/critter/wraith/plaguerat/P = AM
			playsound(src.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 50, 1)
			icon_state = "mousetrap"
			src.armed = FALSE
			clear_armer()
			src.visible_message(SPAN_ALERT("<b>[P] is caught in the trap and explodes violently into a rain of gibs!</b>"))
			P.gib()

		else if (istype(AM, /mob/living/critter/small_animal/mouse/weak/mentor/admin) && src.armed) //The admin mouse fears not your puny attempt to squish it.
			AM.visible_message(SPAN_ALERT("[src] blows up violently as soon as [AM] sets foot on it! [AM] looks amused at this poor attempt on it's life."))
			new/obj/effect/supplyexplosion(src.loc)
			playsound(src.loc, 'sound/effects/ExplosionFirey.ogg', 100, 1)
			qdel(src)

		else if (istype(AM, /mob/living/critter/small_animal/mouse) && (src.armed))
			var/mob/living/critter/small_animal/mouse/M = AM
			playsound(src.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 50, 1)
			icon_state = "mousetrap"
			src.armed = FALSE
			clear_armer()
			src.visible_message(SPAN_ALERT("<b>[M] is caught in the trap!</b>"))
			M.death()

		else if ((ismobcritter(AM)) && (src.armed))
			var/mob/living/critter/C = AM
			src.triggered(C)
			C.visible_message(SPAN_ALERT("<B>[C] accidentally triggers the mousetrap.</B>"),\
				SPAN_ALERT("<B>You accidentally trigger the mousetrap!</B>"))

		..()
		return

	hitby(atom/movable/A, datum/thrown_thing/thr)
		if (!src.armed)
			return ..()
		src.visible_message(SPAN_ALERT("<B>The mousetrap is triggered by [A].</B>"))
		src.triggered(null)
		return

	proc/triggered(mob/target as mob, var/type = "feet")
		if (!src || !src.armed)
			return

		var/zone = null
		if (target && ishuman(target))
			var/mob/living/carbon/human/H = target
			switch(type)
				if ("feet")
					if (!H.shoes && !H.mutantrace?.can_walk_on_shards)
						zone = pick("l_leg", "r_leg")
						H.changeStatus("knockdown", 3 SECONDS)
				if ("l_arm", "r_arm")
					if (!H.gloves)
						zone = type
						H.changeStatus("stunned", 3 SECONDS)
			var/damage = istype(H.mutantrace, /datum/mutantrace/roach) ? 10 : 1
			H.TakeDamage(zone, damage, 0, 0, DAMAGE_CRUSH)

		else if (ismobcritter(target))
			var/mob/living/critter/C = target
			if (C.ghost_spawned)
				C.TakeDamage("All", 5)
			else
				C.TakeDamage("All", 1)

		if (target)
			playsound(target.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 50, 1)
		src.icon_state = "mousetrap"
		src.armed = FALSE

		if (src.grenade)
			logTheThing(LOG_BOMBING, target, "triggers [src] (armed with: [src.grenade]) at [log_loc(src)]")
			src.grenade.explode()
			src.grenade = null

		else if (src.grenade_old)
			logTheThing(LOG_BOMBING, target, "triggers [src] (armed with: [src.grenade_old]) at [log_loc(src)]")
			src.grenade_old.detonate()
			src.grenade_old = null

		else if (src.pipebomb)
			logTheThing(LOG_BOMBING, target, "triggers [src] (armed with: [src.pipebomb]) at [log_loc(src)]")
			src.pipebomb.do_explode()
			src.pipebomb = null

		else if (src.signaler)
			logTheThing(LOG_BOMBING, target, "triggers [src] (armed with: [src.signaler]) at [log_loc(src)]")
			src.signaler.send_signal("ACTIVATE")

		else if (src.pie && src.arm)
			logTheThing(LOG_BOMBING, target, "triggers [src] (armed with: [src.arm] and [src.pie]) at [log_loc(src)]")
			target.visible_message(SPAN_ALERT("<b>[src]'s [src.arm] launches [src.pie] at [target]!</b>"),\
			SPAN_ALERT("<b>[src]'s [src.arm] launches [src.pie] at you!</b>"))
			src.pie.layer = initial(src.pie.layer)
			src.pie.set_loc(get_turf(target))
			var/datum/thrown_thing/thr = new
			thr.user = armer
			thr.thing = src.pie
			src.pie.throw_impact(target, thr)
			src.pie = null
			src.arm.set_loc(get_turf(src))
			src.arm = null
		else if (src.arm)
			src.arm.set_loc(get_turf(src))
			src.arm = null

		else if (src.butt)
			if (src.butt.sound_fart)
				playsound(target, src.butt.sound_fart, 50)
			else
				playsound(target, 'sound/voice/farts/poo2.ogg', 50)

		else if (src.gimmickbomb)
			src.gimmickbomb.detonate()
			qdel(src.gimmickbomb)
			src.gimmickbomb = null
		src.UpdateOverlays(null, "triggerable")
		clear_armer()
		return

// Added support for old-style grenades and pipe bombs (Convair880).
/obj/item/mousetrap_roller
	name = "mousetrap roller assembly"
	desc = "A mousetrap bomb attached to a set of wheels. Looks like the mousetrap going off would send it rolling. Huh."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "mousetrap_roller"
	item_state = "mousetrap"
	w_class = W_CLASS_TINY
	var/armed = FALSE
	var/obj/item/mousetrap/mousetrap = null
	var/obj/item/pipebomb/frame/frame = null
	var/payload = ""

	New(ourLoc, var/obj/item/mousetrap/newtrap, obj/item/pipebomb/frame/newframe)
		..()

		if (newtrap)
			newtrap.set_loc(src)
			src.mousetrap = newtrap
		else
			src.mousetrap = new /obj/item/mousetrap(src)

		// Fallback in case something goes wrong.
		if (!HAS_TRIGGERABLE(src.mousetrap))
			src.mousetrap.grenade = new /obj/item/chem_grenade/flashbang(src.mousetrap)
			src.mousetrap.UpdateOverlays(image('icons/obj/items/weapons.dmi', "trap-grenade"), "triggerable")

		if (src.mousetrap.grenade)
			src.payload = src.mousetrap.grenade.name
			src.name = "mousetrap/grenade/roller assembly"
		else if (src.mousetrap.grenade_old)
			src.payload = src.mousetrap.grenade_old.name
			src.name = "mousetrap/grenade/roller assembly"
		else if (src.mousetrap.pipebomb)
			src.payload = src.mousetrap.pipebomb.name
			src.name = "mousetrap/pipe bomb/roller assembly"
		else if (src.mousetrap.gimmickbomb)
			src.payload = src.mousetrap.gimmickbomb.name
			src.name = "mousetrap/bomb/roller assembly"
		else
			src.payload = "*unknown or null*"

		if (newframe)
			newframe.set_loc(src)
			src.frame = newframe
		else
			src.frame = new /obj/item/pipebomb/frame(src)

		return

	attackby(obj/item/C, mob/user)
		if (iswrenchingtool(C))
			if (!isturf(src.loc))
				user.show_text("Place the [src.name] on the ground first.", "red")
				return

			user.visible_message("<b>[user]</b> disassembles [src].","You disassemble [src].")

			if (src.mousetrap)
				src.mousetrap.set_loc(src.loc)
				src.mousetrap = null

			if (src.frame)
				src.frame.set_loc(src.loc)
				src.frame = null

			qdel(src)

		else
			..()
		return

	attack_hand(mob/user)
		if (src.armed)
			return

		return ..()

	attack_self(mob/user as mob)
		if (!isturf(user.loc))
			user.show_text("You can't release the [src.name] in a confined space.", "red")
			return

		if (src.armed)
			return

		user.visible_message(SPAN_ALERT("[user] starts up the [src.name]."), "You start up the [src.name]")
		message_admins("[key_name(user)] releases a [src] (Payload: [src.payload]) at [log_loc(user)]. Direction: [dir2text(user.dir)].")
		logTheThing(LOG_BOMBING, user, "releases a [src] (Payload: [src.payload]) at [log_loc(user)]. Direction: [dir2text(user.dir)].")

		src.armed = TRUE
		if (!(src.mousetrap?.armed))
			src.mousetrap.armed = TRUE // Must be armed or it won't work in mousetrap.triggered().
			src.mousetrap.set_armer(user)
		src.set_density(1)
		user.u_equip(src)
		src.set_loc(get_turf(user))

		src.layer = initial(src.layer)
		src.set_dir(user.dir)
		walk(src, src.dir, 3)

	bump(atom/movable/AM as mob|obj)
		if (src.armed && src.mousetrap)
			src.visible_message(SPAN_ALERT("[src] bumps against [AM]!"))
			walk(src, 0)
			SPAWN(0)
				src.mousetrap.triggered(AM && ismob(AM) ? AM : null)

				if (src.mousetrap)
					src.mousetrap.set_loc(src.loc)
					src.mousetrap = null
				if (src.frame)
					src.frame.set_loc(src.loc)
					src.frame = null

				qdel(src)

	Move(var/turf/new_loc,direction)
		if (istype(src.mousetrap.gimmickbomb, /obj/item/gimmickbomb/butt) && src.armed)
			playsound(src, 'sound/voice/farts/poo2.ogg', 30, FALSE, 0, 1.8)
		..()

#undef HAS_TRIGGERABLE
