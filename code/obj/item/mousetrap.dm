// Added support for old-style grenades (Convair880).
/obj/item/mousetrap
	name = "mousetrap"
	desc = "A handy little spring-loaded trap for catching pesty rodents."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "mousetrap"
	item_state = "mousetrap"
	w_class = W_CLASS_TINY
	force = null
	throwforce = null
	var/armed = 0
	var/obj/item/chem_grenade/grenade = null
	var/obj/item/old_grenade/grenade_old = null
	var/obj/item/pipebomb/bomb/pipebomb = null
	var/obj/item/device/radio/signaler/signaler = null
	var/obj/item/reagent_containers/food/snacks/pie/pie = null
	var/obj/item/parts/arm = null
	var/obj/item/clothing/head/butt/butt = null
	var/obj/item/gimmickbomb/butt/buttbomb = null
	var/mob/armer = null
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 5
	event_handler_flags = USE_FLUID_ENTER

	armed
		icon_state = "mousetraparmed"
		armed = 1

		cleaner
			name = "cleantrap"

			New()
				..()
				src.overlays += image('icons/obj/items/weapons.dmi', "trap-grenade")
				src.grenade = new /obj/item/chem_grenade/cleaner(src)
				return

	examine()
		. = ..()
		if (src.armed)
			. += "<span class='alert'>It looks like it's armed.</span>"

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
				user.visible_message("<span class='alert'><B>[user] accidentally sets off the mousetrap, breaking their fingers.</B></span>",\
				"<span class='alert'><B>You accidentally trigger the mousetrap!</B></span>")
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
		RegisterSignal(user, COMSIG_PARENT_PRE_DISPOSING, .proc/clear_armer)
		armer = user

	disposing()
		clear_armer()
		. = ..()

	attack_hand(mob/user)
		if (src.armed)
			if ((user.get_brain_damage() >= 60 || user.bioHolder.HasEffect("clumsy")) && prob(50))
				var/which_hand = "l_arm"
				if (!user.hand)
					which_hand = "r_arm"
				src.triggered(user, which_hand)
				JOB_XP(user, "Clown", 1)
				user.visible_message("<span class='alert'><B>[user] accidentally sets off the mousetrap, breaking their fingers.</B></span>",\
				"<span class='alert'><B>You accidentally trigger the mousetrap!</B></span>")
				return
		..()
		return

	attackby(obj/item/C, mob/user)
		if (istype(C, /obj/item/chem_grenade) && !src.grenade && !src.grenade_old && !src.pipebomb && !src.arm && !src.signaler && !src.butt && !src.buttbomb)
			var/obj/item/chem_grenade/CG = C
			if (CG.stage == 2 && !CG.state)
				if(!(src in user.equipped_list()))
					boutput(user, "<span class='alert'>You need to be holding [src] in order to attach anything to it.</span>")
					return

				user.u_equip(CG)
				CG.set_loc(src)
				user.show_text("You attach [CG]'s detonator to [src].", "blue")
				src.grenade = CG
				src.overlays += image('icons/obj/items/weapons.dmi', "trap-grenade")
				src.w_class = max(src.w_class, C.w_class)

				if(CG.is_dangerous)
					message_admins("[key_name(user)] rigs [src] with [CG] at [log_loc(user)].")
				logTheThing(LOG_BOMBING, user, "rigs [src] with [CG] at [log_loc(user)].")

		else if (istype(C, /obj/item/old_grenade/) && !src.grenade && !src.grenade_old && !src.pipebomb && !src.arm && !src.signaler && !src.butt && !src.buttbomb)
			var/obj/item/old_grenade/OG = C
			if (OG.not_in_mousetraps == 0 && !OG.state)
				if(!(src in user.equipped_list()))
					boutput(user, "<span class='alert'>You need to be holding [src] in order to attach anything to it.</span>")
					return

				user.u_equip(OG)
				OG.set_loc(src)
				user.show_text("You attach [OG]'s detonator to [src].", "blue")
				src.grenade_old = OG
				src.overlays += image('icons/obj/items/weapons.dmi', "trap-grenade")
				src.w_class = max(src.w_class, C.w_class)

				if(OG.is_dangerous)
					message_admins("[key_name(user)] rigs [src] with [OG] at [log_loc(user)].")
				logTheThing(LOG_BOMBING, user, "rigs [src] with [OG] at [log_loc(user)].")

		else if (istype(C, /obj/item/pipebomb/bomb) && !src.grenade && !src.grenade_old && !src.pipebomb && !src.arm && !src.signaler && !src.butt && !src.buttbomb)
			var/obj/item/pipebomb/bomb/PB = C
			if (!PB.armed)
				if(!(src in user.equipped_list()))
					boutput(user, "<span class='alert'>You need to be holding [src] in order to attach anything to it.</span>")
					return

				user.u_equip(PB)
				PB.set_loc(src)
				user.show_text("You attach [PB]'s detonator to [src].", "blue")
				src.pipebomb = PB
				src.overlays += image('icons/obj/items/weapons.dmi', "trap-pipebomb")
				src.w_class = max(src.w_class, C.w_class)

				message_admins("[key_name(user)] rigs [src] with [PB] at [log_loc(user)].")
				logTheThing(LOG_BOMBING, user, "rigs [src] with [PB] at [log_loc(user)].")

		else if (istype(C, /obj/item/device/radio/signaler) && !src.grenade && !src.grenade_old && !src.pipebomb && !src.arm && !src.signaler && !src.butt && !src.buttbomb)
			if(!(src in user.equipped_list()))
				boutput(user, "<span class='alert'>You need to be holding [src] in order to attach anything to it.</span>")
				return

			var/obj/item/device/radio/signaler/S = C
			user.u_equip(S)
			S.set_loc(src)
			user.show_text("You attach [S]'s detonator to [src].", "blue")
			src.signaler = S
			src.overlays += image('icons/obj/items/weapons.dmi', "trap-signaler")
			src.w_class = max(src.w_class, C.w_class)

			message_admins("[key_name(user)] rigs [src] with [S] at [log_loc(user)].")
			logTheThing(LOG_BOMBING, user, "rigs [src] with [S] at [log_loc(user)].")

		else if (istype(C, /obj/item/pipebomb/frame))
			var/obj/item/pipebomb/frame/PF = C
			if(!(src in user.equipped_list()))
				boutput(user, "<span class='alert'>You need to be holding [src] to do this.</span>")
				return

			if (PF.state > 2)
				user.show_text("[PF] needs to be empty to be used.", "red")
				return

			// Pies won't do, they require a mob as the target. Obviously, the mousetrap roller is much more
			// likely to bump into an inanimate object.
			if (!src.grenade && !src.grenade_old && !src.pipebomb && !src.buttbomb)
				user.show_text("[src] must have a grenade or pipe bomb attached first.", "red")
				return

			user.u_equip(src)
			user.u_equip(PF)
			new /obj/item/mousetrap_roller(get_turf(src), src, PF)
			return

		else if (!src.arm && (istype(C, /obj/item/parts/robot_parts/arm) || istype(C, /obj/item/parts/human_parts/arm)) && !src.grenade && !src.grenade_old && !src.pipebomb  && !src.signaler && !src.butt && !src.buttbomb)
			if(!(src in user.equipped_list()))
				boutput(user, "<span class='alert'>You need to be holding [src] in order to attach anything to it.</span>")
				return

			user.u_equip(C)
			src.arm = C
			C.set_loc(src)
			src.overlays += image(C.icon, C.icon_state)
			user.show_text("You add [C] to [src].", "blue")

		else if (istype(C, /obj/item/reagent_containers/food/snacks/pie) && !src.grenade && !src.grenade_old && !src.pipebomb  && !src.signaler && !src.butt && !src.buttbomb)
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
				boutput(user, "<span class='alert'>You need to be holding [src] in order to attach anything to it.</span>")
				return

			user.u_equip(C)
			src.pie = C
			C.set_loc(src)
			src.overlays += image(C.icon, C.icon_state)
			src.w_class = max(src.w_class, C.w_class)
			user.show_text("You carefully set [C] in [src]'s [src.arm].", "blue")

			logTheThing(LOG_BOMBING, user, "rigs [src] with [src.arm] and [C] at [log_loc(user)].")

		else if (istype(C, /obj/item/clothing/head/butt) && !src.grenade && !src.grenade_old && !src.pipebomb  && !src.signaler && !src.butt && !src.buttbomb)
			if(!(src in user.equipped_list()))
				boutput(user, "<span class='alert'>You need to be holding [src] in order to attach anything to it.</span>")
				return

			var/obj/item/clothing/head/butt/B = C
			user.u_equip(B)
			B.set_loc(src)
			user.show_text("You attach [B] to [src].", "blue")
			src.butt = B
			src.overlays += image('icons/obj/items/weapons.dmi', "trap-[src.butt.icon_state]")

		else if (istype(C, /obj/item/gimmickbomb/butt) && !src.grenade && !src.grenade_old && !src.pipebomb  && !src.signaler && !src.butt && !src.buttbomb)
			if(!(src in user.equipped_list()))
				boutput(user, "<span class='alert'>You need to be holding [src] in order to attach anything to it.</span>")
				return

			var/obj/item/gimmickbomb/BB = C
			user.u_equip(BB)
			BB.set_loc(src)
			user.show_text("You attach [BB] to [src].", "blue")
			src.buttbomb = BB
			src.overlays += image('icons/obj/items/weapons.dmi', "trap-buttbomb")

		else if (iswrenchingtool(C))
			if (src.grenade)
				user.show_text("You detach [src.grenade].", "blue")
				src.grenade.set_loc(get_turf(src))
				src.grenade = null
				src.overlays -= image('icons/obj/items/weapons.dmi', "trap-grenade")
			else if (src.grenade_old)
				user.show_text("You detach [src.grenade_old].", "blue")
				src.grenade_old.set_loc(get_turf(src))
				src.grenade_old = null
				src.overlays -= image('icons/obj/items/weapons.dmi', "trap-grenade")
			else if (src.pipebomb)
				user.show_text("You detach [src.pipebomb].", "blue")
				src.pipebomb.set_loc(get_turf(src))
				src.pipebomb = null
				src.overlays -= image('icons/obj/items/weapons.dmi', "trap-pipebomb")
			else if (src.signaler)
				user.show_text("You detach [src.signaler].", "blue")
				src.signaler.set_loc(get_turf(src))
				src.signaler = null
				src.overlays -= image('icons/obj/items/weapons.dmi', "trap-signaler")
			else if (src.pie)
				user.show_text("You remove [src.pie] from [src].", "blue")
				src.overlays -= image(src.pie.icon, src.pie.icon_state)
				src.pie.layer = initial(src.pie.layer)
				src.pie.set_loc(get_turf(src))
				src.pie = null
			else if (src.arm)
				user.show_text("You remove [src.arm] from [src].", "blue")
				src.overlays -= image(src.arm.icon, src.arm.icon_state)
				src.arm.layer = initial(src.arm.layer)
				src.arm.set_loc(get_turf(src))
				src.arm = null
			else if (src.butt)
				user.show_text("You remove [src.butt] from [src].", "blue")
				src.overlays -= image('icons/obj/items/weapons.dmi', "trap-[src.butt.icon_state]")
				src.butt.layer = initial(src.butt.layer)
				src.butt.set_loc(get_turf(src))
				src.butt = null
			else if (src.buttbomb)
				user.show_text("You remove [src.buttbomb] from [src].", "blue")
				src.overlays -= image('icons/obj/items/weapons.dmi', "trap-buttbomb")
				src.buttbomb.layer = initial(src.buttbomb.layer)
				src.buttbomb.set_loc(get_turf(src))
				src.buttbomb = null
		else
			..()
		return

	Crossed(atom/movable/AM as mob|obj)
		if ((ishuman(AM)) && (src.armed))
			var/mob/living/carbon/H = AM
			if (H.m_intent == "run")
				src.triggered(H)
				H.visible_message("<span class='alert'><B>[H] accidentally steps on the mousetrap.</B></span>",\
				"<span class='alert'><B>You accidentally step on the mousetrap!</B></span>")

		else if (istype(AM, /mob/living/critter/wraith/plaguerat/adult) && src.armed)
			var/mob/living/critter/wraith/plaguerat/P = AM
			playsound(src.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 50, 1)
			icon_state = "mousetrap"
			src.armed = 0
			clear_armer()
			src.visible_message("<span class='alert'><b>[P] is caught in the trap and squeals in pain!</b></span>")
			P.setStatus("stunned", 3 SECONDS)
			random_brute_damage(P, 20)

		else if (istype(AM, /mob/living/critter/wraith/plaguerat) && src.armed)
			var/mob/living/critter/wraith/plaguerat/P = AM
			playsound(src.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 50, 1)
			icon_state = "mousetrap"
			src.armed = 0
			clear_armer()
			src.visible_message("<span class='alert'><b>[P] is caught in the trap and explodes violently into a rain of gibs!</b></span>")
			P.gib()

		else if ((ismobcritter(AM)) && (src.armed))
			var/mob/living/critter/C = AM
			src.triggered(C)
			C.visible_message("<span class='alert'><B>[C] accidentally triggers the mousetrap.</B></span>",\
				"<span class='alert'><B>You accidentally trigger the mousetrap!</B></span>")

		else if (istype(AM, /obj/critter/mouse) && (src.armed))
			var/obj/critter/mouse/M = AM
			playsound(src.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 50, 1)
			icon_state = "mousetrap"
			src.armed = 0
			clear_armer()
			src.visible_message("<span class='alert'><b>[M] is caught in the trap!</b></span>")
			M.CritterDeath()
		..()
		return

	hitby(atom/movable/A, datum/thrown_thing/thr)
		if (!src.armed)
			return ..()
		src.visible_message("<span class='alert'><B>The mousetrap is triggered by [A].</B></span>")
		src.triggered(null)
		return

	proc/triggered(mob/target as mob, var/type = "feet")
		if (!src || !src.armed)
			return

		var/obj/item/affecting = null
		if (target && ishuman(target))
			var/mob/living/carbon/human/H = target
			switch(type)
				if ("feet")
					if (!H.shoes && !H.mutantrace?.can_walk_on_shards)
						affecting = H.organs[pick("l_leg", "r_leg")]
						H.changeStatus("weakened", 3 SECONDS)
				if ("l_arm", "r_arm")
					if (!H.gloves)
						affecting = H.organs[type]
						H.changeStatus("stunned", 3 SECONDS)
			if (affecting)
				affecting.take_damage(1, 0)
				H.UpdateDamageIcon()

		else if (ismobcritter(target))
			var/mob/living/critter/C = target
			C.TakeDamage("All", 1)

		if (target)
			playsound(target.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 50, 1)
		src.icon_state = "mousetrap"
		src.armed = 0

		if (src.grenade)
			logTheThing(LOG_BOMBING, target, "triggers [src] (armed with: [src.grenade]) at [log_loc(src)]")
			src.grenade.explode()
			src.grenade = null
			src.overlays -= image('icons/obj/items/weapons.dmi', "trap-grenade")

		else if (src.grenade_old)
			logTheThing(LOG_BOMBING, target, "triggers [src] (armed with: [src.grenade_old]) at [log_loc(src)]")
			src.grenade_old.prime()
			src.grenade_old = null
			src.overlays -= image('icons/obj/items/weapons.dmi', "trap-grenade")

		else if (src.pipebomb)
			logTheThing(LOG_BOMBING, target, "triggers [src] (armed with: [src.pipebomb]) at [log_loc(src)]")
			src.overlays -= image('icons/obj/items/weapons.dmi', "trap-pipebomb")
			src.pipebomb.do_explode()
			src.pipebomb = null

		else if (src.signaler)
			logTheThing(LOG_BOMBING, target, "triggers [src] (armed with: [src.signaler]) at [log_loc(src)]")
			src.signaler.send_signal("ACTIVATE")

		else if (src.pie && src.arm)
			logTheThing(LOG_BOMBING, target, "triggers [src] (armed with: [src.arm] and [src.pie]) at [log_loc(src)]")
			target.visible_message("<span class='alert'><b>[src]'s [src.arm] launches [src.pie] at [target]!</b></span>",\
			"<span class='alert'><b>[src]'s [src.arm] launches [src.pie] at you!</b></span>")
			src.overlays -= image(src.pie.icon, src.pie.icon_state)
			src.pie.layer = initial(src.pie.layer)
			src.pie.set_loc(get_turf(target))
			var/datum/thrown_thing/thr = new
			thr.user = armer
			thr.thing = src.pie
			src.pie.throw_impact(target, thr)
			src.pie = null

		else if (src.butt)
			if (src.butt.sound_fart)
				playsound(target, src.butt.sound_fart, 50)
			else
				playsound(target, 'sound/voice/farts/poo2.ogg', 50)

		else if (src.buttbomb)
			src.overlays -= image('icons/obj/items/weapons.dmi', "trap-buttbomb")
			var/obj/effects/explosion/E = new /obj/effects/explosion(get_turf(src.loc))
			E.fingerprintslast = src.fingerprintslast
			playsound(src.loc, 'sound/voice/farts/superfart.ogg', 100, 1)
			qdel(src.buttbomb)
			src.buttbomb = null
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
	var/armed = 0
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
		if (!src.mousetrap.grenade && !src.mousetrap.grenade_old && !src.mousetrap.pipebomb && !src.mousetrap.buttbomb)
			src.mousetrap.grenade = new /obj/item/chem_grenade/flashbang(src.mousetrap)
			src.mousetrap.overlays += image('icons/obj/items/weapons.dmi', "trap-grenade")

		if (src.mousetrap.grenade)
			src.payload = src.mousetrap.grenade.name
			src.name = "mousetrap/grenade/roller assembly"
		else if (src.mousetrap.grenade_old)
			src.payload = src.mousetrap.grenade_old.name
			src.name = "mousetrap/grenade/roller assembly"
		else if (src.mousetrap.pipebomb)
			src.payload = src.mousetrap.pipebomb.name
			src.name = "mousetrap/pipe bomb/roller assembly"
		else if (src.mousetrap.buttbomb)
			src.payload = src.mousetrap.buttbomb.name
			src.name = "mousetrap/butt bomb/roller assembly"
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

		user.visible_message("<span class='alert'>[user] starts up the [src.name].</span>", "You start up the [src.name]")
		message_admins("[key_name(user)] releases a [src] (Payload: [src.payload]) at [log_loc(user)]. Direction: [dir2text(user.dir)].")
		logTheThing(LOG_BOMBING, user, "releases a [src] (Payload: [src.payload]) at [log_loc(user)]. Direction: [dir2text(user.dir)].")

		src.armed = 1
		if (!(src.mousetrap?.armed))
			src.mousetrap.armed = 1 // Must be armed or it won't work in mousetrap.triggered().
			src.mousetrap.set_armer(user)
		src.set_density(1)
		user.u_equip(src)

		src.layer = initial(src.layer)
		src.set_dir(user.dir)
		walk(src, src.dir, 3)

	bump(atom/movable/AM as mob|obj)
		if (src.armed && src.mousetrap)
			src.visible_message("<span class='alert'>[src] bumps against [AM]!</span>")
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
		if (src.mousetrap.buttbomb && src.armed)
			playsound(src, 'sound/voice/farts/poo2.ogg', 30, 0, 0, 1.8)
		..()
