/datum/targetable/critter/spiker/hook	//Projectile is referenced in spiker.dm
	name = "Tentacle hook"
	desc = "Launch a tentacle at your target and drag it to you"
	icon_state = "hook"
	cooldown = 30 SECONDS
	targeted = 1
	target_anything = 1
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = "harbinger_frame"

	cast(atom/target)
		if (..())
			return 1

		if (istype(holder.owner, /mob/living/critter/wraith/spiker))
			var/mob/living/critter/wraith/spiker/the_spiker = holder.owner
			if (the_spiker.shuffling)
				boutput(holder.owner, "<span class='notice'>You cannot use this while you're all squished up like that!</span>")
				return TRUE

		var/mob/living/critter/wraith/spiker/S = holder.owner
		var/obj/projectile/proj = initialize_projectile_ST(S, new/datum/projectile/special/tentacle, get_turf(target))
		while (!proj || proj.disposed)
			proj = initialize_projectile_ST(S, new/datum/projectile/special/tentacle, get_turf(target))

		proj.special_data["owner"] = holder.owner
		proj.targets = list(target)

		proj.launch()
		holder.owner.setStatus("slowed", 2 SECONDS)

	onAttach(datum/abilityHolder/holder)
		..()
		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")

/datum/targetable/critter/spiker/lash	//Combo it with the tentacle throw to slap someone silly
	name = "Lash"
	desc = "Go into a bloody frenzy on a weakened target and rip them to shreds."
	cooldown = 50 SECONDS
	targeted = TRUE
	target_anything = TRUE
	icon_state = "lash"
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = "harbinger_frame"

	cast(atom/target)
		if (istype(holder.owner, /mob/living/critter/wraith/spiker))
			var/mob/living/critter/wraith/spiker/the_spiker = holder.owner
			if (the_spiker.shuffling)
				boutput(holder.owner, "<span class='notice'>You cannot use this while you're all squished up like that!</span>")
				return TRUE
		if (disabled && TIME > last_cast)
			disabled = 0
		if (disabled)
			return 1
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			for (var/mob/living/M in target)
				if (is_incapacitated(M))
					target = M
					break
		if (target == holder.owner)
			return 1
		if (!ismob(target))
			boutput(holder.owner, "<span class='alert'>Nothing to lash at there.</span>")
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to lash at.</span>")
			return 1
		var/mob/M = target
		if (!is_incapacitated(M))
			boutput(holder.owner, "<span class='alert'>That is moving around far too much to immobilize.</span>")
			return 1
		playsound(holder.owner, 'sound/impact_sounds/Flesh_Stab_1.ogg', 80, 1)
		disabled = 1
		SPAWN(0)
			var/frenz = 5
			holder.owner.canmove = 0
			holder.owner.set_loc(M.loc)
			while (frenz > 0 && M && !M.disposed)
				M.setStatus("weakened", 1.5 SECONDS)
				M.canmove = 0
				if (M.loc && holder.owner.loc != M.loc)
					break
				if (is_incapacitated(holder?.owner))
					break
				playsound(holder.owner, pick("sound/impact_sounds/Flesh_Tear_3.ogg", "sound/impact_sounds/Flesh_Stab_1.ogg"), 80, 1)
				holder.owner.visible_message("<span class='alert'><b>[holder.owner] [pick("lashes at", "whips", "slashes", "tears at", "lacerates")] [M]!</b></span>")
				holder.owner.set_dir((cardinal))
				holder.owner.pixel_x = rand(-5, 5)
				holder.owner.pixel_y = rand(-5, 5)
				random_brute_damage(M, 7, 1)
				take_bleeding_damage(M, null, 15, DAMAGE_CUT, 0, get_turf(M))
				if(prob(33))
					bleed(M, 5, 5, get_step(get_turf(M), pick(alldirs)), 1)
				sleep(0.8 SECONDS)
				frenz--
			if (M)
				M.canmove = 1
			doCooldown()
			disabled = 0
			holder.owner.pixel_x = 0
			holder.owner.pixel_y = 0
			holder.owner.canmove = 1

	onAttach(datum/abilityHolder/holder)
		..()
		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")

/datum/targetable/critter/spiker/shuffle
	name = "Shuffle"
	desc = "Squish yourself down to cancel stuns, squeeze through doors and escape assailants."
	cooldown = 50 SECONDS
	targeted = FALSE
	icon_state = "shuffle"
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = "harbinger_frame"

	cast(atom/target)

		if (!istype(holder.owner, /mob/living/critter/wraith/spiker))
			boutput(holder.owner, "<span class='notice'>You cannot use this ability.</span>")
			return TRUE
		var/mob/living/critter/wraith/spiker/the_spiker = holder.owner
		if (the_spiker.shuffling)
			boutput(holder.owner, "<span class='notice'>You are already casting this ability!</span>")
			return TRUE

		the_spiker.delStatus("stunned")
		the_spiker.delStatus("weakened")
		the_spiker.delStatus("paralysis")
		the_spiker.delStatus("slowed")
		the_spiker.delStatus("disorient")
		the_spiker.change_misstep_chance(-INFINITY)
		the_spiker.stuttering = 0
		the_spiker.delStatus("drowsy")
		the_spiker.delStatus("resting")
		the_spiker.flags |= DOORPASS | TABLEPASS
		the_spiker.unequip_all()
		the_spiker.shuffling = TRUE
		the_spiker.icon_state = "shuffling_spiker"
		playsound(holder.owner, 'sound/impact_sounds/Slimy_Hit_4.ogg', 80, 1)
		SPAWN(10 SECONDS)
			if (!the_spiker) return
			the_spiker.flags &= ~(DOORPASS | TABLEPASS)
			the_spiker.shuffling = FALSE
			if (!isdead(the_spiker))
				the_spiker.icon_state = "spiker"
		return FALSE

	incapacitationCheck()
		return FALSE

	onAttach(datum/abilityHolder/holder)
		..()
		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")

