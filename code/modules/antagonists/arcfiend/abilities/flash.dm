/// Super simple CC. Short-ranged elecflash.
/datum/targetable/arcfiend/elecflash
	name = "Flash"
	desc = "Charge up and release a burst of power around yourself, blasting nearby creatures back and disorienting them."
	icon_state = "flash"
	cooldown = 10 SECONDS
	pointCost = 25

	cast(atom/target)
		. = ..()
		playsound(holder.owner, 'sound/effects/power_charge.ogg', 100)
		actions.start(new/datum/action/bar/private/flash(), src.holder.owner)



/datum/action/bar/private/flash
	duration = 0.75 SECONDS
	interrupt_flags = INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_ACT
	///how far to knock mobs away from ourselves
	var/target_dist = 7
	///how fast to throw affected mobs away
	var/throw_speed = 1
	/// particle reference, just used to toggle the effects on and off
	var/particles/P
	/// the distance our attack reaches from us at the center
	var/area_of_effect = 2
	/// power of our elecflash, this maxes out at 6
	var/elec_flash_power = 4

	onStart()
		. = ..()
		P = owner.GetParticles("arcfiend")
		if (!P) // only need to create this on the mob once
			owner.UpdateParticles(new/particles/arcfiend, "arcfiend")
			P = owner.GetParticles("arcfiend")
		P.spawning = initial(P.spawning)

	onEnd()
		. = ..()
		elecflash(owner, area_of_effect, elec_flash_power)
		for (var/mob/living/L in viewers(area_of_effect, owner))
			if (isobserver(L) || isintangible(L))
				continue
			var/turf/T = get_ranged_target_turf(L, get_dir(owner, L), target_dist)
			if (T)
				var/falloff = GET_DIST(owner, L)
				L.throw_at(T, target_dist - falloff, throw_speed)

	onDelete()
		P.spawning = 0
		. = ..()
