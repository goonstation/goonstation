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
		RegisterSignal(src, COMSIG_ITEM_STORAGE_INTERACTION, PROC_REF(triggered))
		RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ACTIVATION, PROC_REF(assembly_activation))
		RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_MANIPULATION, PROC_REF(assembly_manipulation))
		RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP, PROC_REF(assembly_building))
		RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_ON_TARGET_ADDITION, PROC_REF(assembly_building))
		// Mousetrap + assembly-applier -> mousetrap/Applier-Assembly
		src.AddComponent(/datum/component/assembly/trigger_applier_assembly)

/// ----------- Assembly-Related Procs -----------

	proc/assembly_manipulation(var/manipulated_mousetrap, var/obj/item/assembly/complete/parent_assembly, var/mob/user)
		if(src.armed)
			src.toggle_armed(user)
			parent_assembly.trigger_icon_prefix = src.icon_state
			parent_assembly.UpdateIcon()
			logTheThing(LOG_BOMBING, usr, "deactivated the mousetrap on a [parent_assembly.name] at [log_loc(parent_assembly)].")
			//missing log about contents of beakers


	proc/assembly_activation(var/manipulated_mousetrap, var/obj/item/assembly/complete/parent_assembly, var/mob/user)
		if(!src.armed)
			src.toggle_armed(user)
			parent_assembly.trigger_icon_prefix = src.icon_state
			parent_assembly.UpdateIcon()
			logTheThing(LOG_BOMBING, usr, "activated the mousetrap on a [parent_assembly.name] at [log_loc(parent_assembly)].")
			//missing log about contents of beakers

	proc/assembly_building(var/manipulated_mousetrap, var/obj/item/assembly/complete/parent_assembly, var/mob/user, var/is_build_in)
		//once integrated in the assembly, we unarm the mousetrap
		src.armed = FALSE
		src.icon_state = "mousetrap"
		src.clear_armer()
		//mousetrap-assembly + pipebomb-frame -> mousetrap-roller-assembly
		parent_assembly.AddComponent(/datum/component/assembly, list(/obj/item/pipebomb/frame), TYPE_PROC_REF(/obj/item/assembly/complete, create_mousetrap_roller), TRUE)
/// ----------------------------------------------





	examine()
		. = ..()
		if (src.armed)
			. += SPAN_ALERT("It looks like it's armed.")

	attack_self(mob/user as mob)
		src.toggle_armed(user)

	proc/toggle_armed(var/mob/user)
		if (!src.armed)
			src.icon_state = "mousetraparmed"
			boutput(user, SPAN_NOTICE("You arm the [src.master ? "[src.master.name]" : "[src.name]"]."))
			src.set_armer(user)
		else
			src.icon_state = "mousetrap"
			if (user && (user.get_brain_damage() >= 60 || user.bioHolder.HasEffect("clumsy")) && prob(50))
				var/which_hand = "l_arm"
				if (!user.hand)
					which_hand = "r_arm"
				src.triggered(user, which_hand)
				JOB_XP(user, "Clown", 1)
				user.visible_message(SPAN_ALERT("<B>[user] accidentally sets off the [src.master ? "[src.master.name]" : "[src.name]"], breaking their fingers.</B>"),\
				SPAN_ALERT("<B>You accidentally trigger the [src.master ? "[src.master.name]" : "[src.name]"]!</B>"))
				return
			boutput(user, SPAN_NOTICE("You disarm the [src.master ? "[src.master.name]" : "[src.name]"]."))
			src.clear_armer()
		src.armed = !src.armed
		playsound(get_turf(src), 'sound/weapons/handcuffs.ogg', 30, 1, -3)

	proc/clear_armer()
		UnregisterSignal(armer, COMSIG_PARENT_PRE_DISPOSING)
		src.armer = null

	proc/set_armer(mob/user)
		RegisterSignal(user, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(clear_armer))
		src.armer = user

	disposing()
		clear_armer()
		UnregisterSignal(src, COMSIG_MOVABLE_FLOOR_REVEALED)
		UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_MANIPULATION)
		UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_ACTIVATION)
		UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP)
		UnregisterSignal(src, COMSIG_ITEM_STORAGE_INTERACTION)
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
		if (istype(C, /obj/item/old_grenade/) && !HAS_TRIGGERABLE(src))
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
			H.TakeDamage(zone, 1, 0, 0, DAMAGE_CRUSH)

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

		else if (src.master && istype(src.master, /obj/item/assembly/complete))
			var/obj/item/assembly/complete/parent_assembly = src.master
			parent_assembly.trigger_icon_prefix = src.icon_state
			parent_assembly.UpdateIcon()
			SPAWN( 0 )
				var/datum/signal/signal = get_free_signal()
				signal.source = src
				signal.data["message"] = "ACTIVATE"
				parent_assembly.receive_signal(signal)

		src.UpdateOverlays(null, "triggerable")
		clear_armer()
		return TRUE

// Added support for old-style grenades and pipe bombs (Convair880).
/obj/item/mousetrap_roller
	name = "mousetrap roller assembly"
	desc = "A mousetrap bomb attached to a set of wheels. Looks like the mousetrap going off would send it rolling. Huh."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "mousetrap_roller"
	item_state = "mousetrap"
	w_class = W_CLASS_TINY
	var/armed = FALSE
	var/obj/item/assembly/complete/payload = null
	var/obj/item/pipebomb/frame/frame = null
	var/buttbomb = FALSE

	New(ourLoc, var/obj/item/assembly/complete/new_payload, var/obj/item/pipebomb/frame/new_frame)
		..()

		if (new_payload)
			new_payload.set_loc(src)
			src.payload = new_payload
			//we scale down the assembly and resets its icon area to position it properly on the mousetrap roller
			src.payload.pixel_x = 0
			src.payload.pixel_y = 0
			src.payload.transform *= 0.75
			new_payload.vis_flags |= (VIS_INHERIT_ID | VIS_INHERIT_PLANE |  VIS_INHERIT_LAYER)
			src.vis_contents += new_payload
			if(istype(src.payload.applier, /obj/item/gimmickbomb/butt))
				src.buttbomb = TRUE


		if (new_frame)
			new_frame.set_loc(src)
			src.frame = new_frame
		else
			src.frame = new /obj/item/pipebomb/frame
			src.frame.set_loc(src)
		//else
		//	src.mousetrap = new /obj/item/mousetrap(src)

		// Fallback in case something goes wrong.
		//if (!HAS_TRIGGERABLE(src.mousetrap))
		//	src.mousetrap.grenade = new /obj/item/chem_grenade/flashbang(src.mousetrap)
		//	src.mousetrap.UpdateOverlays(image('icons/obj/items/weapons.dmi', "trap-grenade"), "triggerable")

	disposing()
		qdel(src.frame)
		src.frame = null
		qdel(src.payload)
		src.payload = null
		..()

	attackby(obj/item/C, mob/user)
		if (iswrenchingtool(C))
			user.visible_message("<b>[user]</b> disassembles [src].","You disassemble [src].")
			if (src.payload)
				src.payload.vis_flags &= ~(VIS_INHERIT_ID | VIS_INHERIT_PLANE |  VIS_INHERIT_LAYER)
				src.payload.set_loc(get_turf(src))
				src.payload.transform = null //we reset the transformation here
				src.payload = null
			if (src.frame)
				src.frame.set_loc(get_turf(src))
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
		message_admins("[key_name(user)] releases a [src] (Payload: [src.payload.name]) at [log_loc(user)]. Direction: [dir2text(user.dir)].")
		logTheThing(LOG_BOMBING, user, "releases a [src] (Payload: [src.payload.name]) at [log_loc(user)]. Direction: [dir2text(user.dir)].")

		src.armed = TRUE
		//we arm our assembly here
		SEND_SIGNAL(src.payload.trigger, COMSIG_ITEM_ASSEMBLY_ACTIVATION, payload, user)
		src.set_density(1)
		user.u_equip(src)
		src.set_loc(get_turf(user))

		src.layer = initial(src.layer)
		src.set_dir(user.dir)
		walk(src, src.dir, 3)

	bump(atom/movable/AM as mob|obj)
		if (src.armed && src.payload)
			src.visible_message(SPAN_ALERT("[src] bumps against [AM]!"))
			walk(src, 0)
			SPAWN(0)
				// we now trigger the assembly
				var/datum/signal/signal = get_free_signal()
				signal.source = src.payload.trigger
				signal.data["message"] = "ACTIVATE"
				payload.receive_signal(signal)
				//now, if the payload still exists, we leave it on the ground
				if (src.payload)
					src.payload.set_loc(src.loc)
					//we reset the transformation here
					src.payload.transform = null
					//this will deactivate the mousetrap
					SEND_SIGNAL(src.payload.trigger, COMSIG_ITEM_ASSEMBLY_MANIPULATION, payload)
					src.payload = null
				if (src.frame)
					src.frame.set_loc(src.loc)
					src.frame = null
				qdel(src)

	Move(var/turf/new_loc,direction)
		if (src.buttbomb && src.armed)
			playsound(src, 'sound/voice/farts/poo2.ogg', 30, FALSE, 0, 1.8)
		..()

#undef HAS_TRIGGERABLE
