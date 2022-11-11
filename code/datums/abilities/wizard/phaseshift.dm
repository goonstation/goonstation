/datum/targetable/spell/phaseshift
	name = "Phase Shift"
	desc = "Become incorporeal and move through walls."
	icon_state = "phaseshift"
	targeted = 0
	cooldown = 300
	requires_robes = 1
	cooldown_staff = 1
	restricted_area_check = 1
	voice_grim = 'sound/voice/wizard/MistFormGrim.ogg'
	voice_fem = 'sound/voice/wizard/MistFormFem.ogg'
	voice_other = 'sound/voice/wizard/MistFormLoud.ogg'
	maptext_colors = list("#24639a", "#24bdc6", "#55eec2", "#24bdc6")

	cast()
		if(!holder)
			return
		if (spell_invisibility(holder.owner, 1, 0, 1, 1) != 1) // Dry run. Can we phaseshift?
			return 1

		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("PHEE CABUE", FALSE, maptext_style, maptext_colors)
		..()

		var/SPtime = 35
		if(holder.owner.wizard_spellpower(src))
			SPtime = 50
		else
			boutput(holder.owner, "<span class='alert'>Your spell doesn't last as long without a staff to focus it!</span>")
		playsound(holder.owner.loc, 'sound/effects/mag_phase.ogg', 25, 1, -1)
		spell_invisibility(holder.owner, SPtime, 0, 1)

// Merged some stuff from wizard and vampire phaseshift for easy of use (Convair880).
/proc/spell_invisibility(var/mob/H, var/time, var/check_for_watchers = 0, var/stop_burning = 0, var/dry_run_only = 0)
	if (!H || !ismob(H))
		return
	if (!isturf(H.loc))
		H.show_text("You can't seem to turn incorporeal here.", "red")
		return
	if (H.stat || H.getStatusDuration("paralysis") > 0)
		H.show_text("You can't turn incorporeal when you are incapacitated.", "red")
		return

	var/turf/T = get_turf(H)
	if (T && isrestrictedz(T.z))
		H.show_text("You can't seem to turn incorporeal here.", "red")
		return

	if (check_for_watchers == 1)
		if (H.client)
			for (var/mob/living/L in view(H.client.view, H))
				if (isalive(L) && L.sight_check(1) && L.ckey != H.ckey)
					H.show_text("You can only use that when nobody can see you!", "red")
					return

	if (dry_run_only)
		return 1 // Return 1 if we got this far in the test run.

	if (stop_burning == 1)
		if (H.getStatusDuration("burning"))
			boutput(H, "<span class='notice'>The flames sputter out as you phase shift.</span>")
			H.delStatus("burning")

	SPAWN(0)
		var/start_loc
		var/mobloc = get_turf(H.loc)
		start_loc = H.loc
		var/obj/dummy/spell_invis/holder = new /obj/dummy/spell_invis( mobloc )
		var/atom/movable/overlay/animation = new /atom/movable/overlay( mobloc )
		animation.name = "water"
		animation.set_density(0)
		animation.anchored = 1
		animation.icon = 'icons/mob/mob.dmi'
		animation.icon_state = "liquify"
		animation.layer = EFFECTS_LAYER_BASE
		animation.master = holder
		flick("liquify",animation)
		H.set_loc(holder)
		var/datum/effects/system/steam_spread/steam = new /datum/effects/system/steam_spread
		steam.set_up(10, 0, mobloc)
		steam.start()
		sleep(time)
		mobloc = get_turf(H.loc)
		animation.set_loc(mobloc)
		steam.location = mobloc
		steam.start()
		H.canmove = 0
		H.restrain_time = TIME + 40
		holder.canmove = 0
		sleep(2 SECONDS)
		flick("reappear",animation)
		sleep(0.5 SECONDS)
		H.set_loc(mobloc)
		logTheThing(LOG_COMBAT, H, "used phaseshift to move from [log_loc(start_loc)] to [log_loc(H.loc)].")
		H.canmove = 1
		H.restrain_time = 0
		qdel(animation)
		for (var/obj/junk_to_dump in holder.contents)
			junk_to_dump.set_loc(mobloc)

		qdel(holder)

/obj/dummy/spell_invis
	name = "water"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	invisibility = INVIS_ALWAYS
	var/canmove = 1 // can be used to completely stop movement
	var/movecd = 0 // used in relaymove, so people don't move too quickly
	density = 0
	anchored = 1

/obj/dummy/spell_invis/relaymove(var/mob/user, direction, delay)
	if (!src.canmove || src.movecd)
		return
	switch(direction)
		if(NORTH)
			src.y++
		if(SOUTH)
			src.y--
		if(EAST)
			src.x++
		if(WEST)
			src.x--
		if(NORTHEAST)
			src.y++
			src.x++
		if(NORTHWEST)
			src.y++
			src.x--
		if(SOUTHEAST)
			src.y--
			src.x++
		if(SOUTHWEST)
			src.y--
			src.x--
	src.movecd = 1
	SPAWN(0.2 SECONDS) src.movecd = 0

/obj/dummy/spell_invis/ex_act(blah)
	return

/obj/dummy/spell_invis/bullet_act(blah,blah)
	return



/proc/spell_batpoof(var/mob/H, var/cloak = 0)
	if (!H || !ismob(H))
		return
	if (!isturf(H.loc))
		H.show_text("You can't seem to transform in here.", "red")
		return
	if (isdead(H))
		return
	if (!H.canmove)
		return
	if(isrestrictedz(H.loc.z))
		return

	if (isliving(H))
		var/mob/living/owner = H
		if (owner.stamina < STAMINA_SPRINT)
			return


	//usecloak == check abilityholder
	new /obj/dummy/spell_batpoof( get_turf(H), H , cloak)

/proc/spell_firepoof(var/mob/H)
	if (!H || !ismob(H))
		return
	if (!isturf(H.loc))
		H.show_text("You can't seem to transform in here.", "red")
		return
	if (isdead(H))
		return
	if (!H.canmove)
		return

	if (isliving(H))
		var/mob/living/owner = H
		if (owner.stamina < STAMINA_SPRINT)
			return

	new /obj/dummy/spell_batpoof/firepoof( get_turf(H), H , 0)

/obj/dummy/spell_batpoof
	name = "bat"
	icon = 'icons/misc/critter.dmi'
	icon_state = "vampbat"
	density = 0
	flags = TABLEPASS | DOORPASS

	var/stamina_mult = 0.88

	var/mob/living/carbon/owner = 0
	var/datum/abilityHolder/vampire/vampholder = 0
	//var/image/overlay_image
	var/use_cloakofdarkness = 0

	New(loc,ownermob,cloak)
		..()

		if(ownermob)
			src.owner = ownermob
			src.owner.set_loc(src)
			src.owner.remove_stamina(5)

		use_cloakofdarkness = cloak

		if (isvampire(owner))
			vampholder = owner.get_ability_holder(/datum/abilityHolder/vampire)

		var/obj/itemspecialeffect/poof/P = new /obj/itemspecialeffect/poof
		P.setup(src.loc)
		playsound(src.loc, 'sound/effects/poff.ogg', 50, 1, pitch = 1)

		//overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "aurapulse", layer = MOB_LIMB_LAYER)
		//overlay_image.color = "#333333"


		if (use_cloakofdarkness)
			processing_items |= src

		SPAWN(-1)
			var/reduc_count = 0
			while(src && !src.qdeled && owner && owner.stamina >= STAMINA_SPRINT && owner.client && owner.client.check_key(KEY_RUN))
				reduc_count++
				if (reduc_count >= 4)
					reduc_count = 0
					owner.remove_stamina(1)
				sleep(0.1 SECONDS)

			if (src && !src.qdeled)
				dispel()

	disposing()
		if(owner)
			owner.set_loc(src.loc)
			owner = 0
		//overlay_image = 0
		if (use_cloakofdarkness)
			processing_items.Remove(src)
		..()

	proc/process()
		update_cloak_status()

	proc/update_cloak_status()
		var/turf/T = get_turf(owner)
		if (T)
			var/area/A = get_area(T)
			if (T.turf_flags & CAN_BE_SPACE_SAMPLE || A.name == "Emergency Shuttle" || A.name == "Space" || A.name == "Ocean")
				src.set_cloaked(0)

			else
				if (T.RL_GetBrightness() < 0.2 && can_act(owner))
					src.set_cloaked(1)
				else
					src.set_cloaked(0)
		else
			src.set_cloaked(0)


	proc/set_cloaked(var/cloaked = 1)
		if (use_cloakofdarkness)
			if (cloaked == 1)
				src.invisibility = INVIS_INFRA
				src.alpha = 120
				//src.UpdateOverlays(overlay_image, "batpoof_cloak")
			else
				src.invisibility = INVIS_NONE
				src.alpha = 250
				//src.UpdateOverlays(null, "batpoof_cloak")

	proc/dispel(var/forced = 0)
		if (forced && owner)
			owner.stamina = max(owner.stamina - 40, STAMINA_SPRINT)

		var/obj/itemspecialeffect/poof/P = new /obj/itemspecialeffect/poof
		P.setup(src.loc, forced)

		playsound(src.loc, 'sound/effects/poff.ogg', 50, 1, pitch = 1.3)

		qdel(src)

	relaymove(var/mob/user, direction, delay)//all relaymove should accept delay
		delay = max(delay,1)			//0.75 sprint 1.25 run
		if (direction & (direction-1))
			delay *= DIAG_MOVE_DELAY_MULT

		var/glide = ((32 / delay) * world.tick_lag)
		src.glide_size = glide
		src.animate_movement = SLIDE_STEPS

		user.animate_movement = SYNC_STEPS
		user.glide_size = glide

		var/turf/last_turf = get_turf(src)

		step(src, direction)

		src.glide_size = glide
		src.animate_movement = SLIDE_STEPS

		user.glide_size = glide

		owner.remove_stamina(round(STAMINA_COST_SPRINT*stamina_mult))

		update_cloak_status()

		if (isturf(src.loc) && src.loc != last_turf)
			var/i = 0
			for (var/atom in src.loc)
				if (vampholder)
					if (ishuman(atom) && vampholder.can_bite(atom, is_pointblank = 0))
						vampholder.do_bite(atom, mult = 0.25)
						playsound(src.loc, 'sound/impact_sounds/Flesh_Crush_1.ogg', 35, 1, pitch = 1.3)
						break
				if (istype(atom,/obj/machinery/door))
					var/obj/machinery/door/D = atom
					//D.bumpopen(owner)
					D.try_force_open(owner)
				i++
				if (i > 20)
					break

		actions.interrupt(user, INTERRUPT_MOVE)

		.= delay

	mob_flip_inside(mob/user)
		animate_spin(src, pick("L", "R"), 1, FALSE)

	ex_act(severity)
		dispel(1)
		if(owner) owner.ex_act(severity)

	bullet_act()
		.= owner
		dispel(1)

	attackby(obj/item/W, mob/M)
		dispel(1)
		if(owner) owner.Attackby(W,M)

	attack_hand(mob/M)
		dispel(1)
		if(owner) owner.Attackby(M)


	firepoof
		name = "fireball"
		icon_state = "fireball"
		icon = 'icons/obj/wizard.dmi'
		flags = TABLEPASS
		stamina_mult = 1.1

		New()
			..()
			playsound(src.loc, 'sound/effects/mag_fireballlaunch.ogg', 15, 1, pitch = 1.8)

		relaymove()
			..()
			tfireflash(get_turf(owner), 0, 100)


		dispel()
			playsound(src.loc, 'sound/effects/mag_fireballlaunch.ogg', 15, 1, pitch = 2)
			..()
