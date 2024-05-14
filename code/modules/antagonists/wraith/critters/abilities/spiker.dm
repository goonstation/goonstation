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
				boutput(holder.owner, SPAN_NOTICE("You cannot use this while you're all squished up like that!"))
				return TRUE

		var/mob/living/critter/wraith/spiker/S = holder.owner
		var/obj/projectile/proj = initialize_projectile_pixel_spread(S, new/datum/projectile/special/tentacle, get_turf(target))
		while (!proj || proj.disposed)
			proj = initialize_projectile_pixel_spread(S, new/datum/projectile/special/tentacle, get_turf(target))

		proj.special_data["owner"] = holder.owner
		proj.targets = list(target)

		proj.launch()
		holder.owner.setStatus("slowed", 2 SECONDS)

	onAttach(datum/abilityHolder/holder)
		..()
		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")

// Spiker frenzy moved to frenzy.dm

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
			boutput(holder.owner, SPAN_NOTICE("You cannot use this ability."))
			return TRUE
		var/mob/living/critter/wraith/spiker/the_spiker = holder.owner
		if (the_spiker.shuffling)
			boutput(holder.owner, SPAN_NOTICE("You are already casting this ability!"))
			return TRUE
		. = ..()

		the_spiker.remove_stuns()
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

