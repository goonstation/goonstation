/// Applies a magnetic aura to nearby humans, as with the bio-magnetic fields random event. All auras will be of the same polarity.
/datum/targetable/arcfiend/polarize
	name = "Polarize"
	desc = "Unleash a wave of charged particles, polarizing nearby mobs and giving them identical magnetic auras."
	icon_state = "polarize"
	cooldown = 12 SECONDS
	pointCost = 50
	container_safety_bypass = TRUE
	var/range = 4
	var/duration = 20 SECONDS

	cast(atom/target)
		. = ..()
		var/charge = pick("magnets_pos", "magnets_neg")
		playsound(src.holder.owner, 'sound/impact_sounds/Energy_Hit_2.ogg', 65, TRUE)
		for (var/mob/living/carbon/human/H in range(src.range, get_turf(src.holder.owner)))
			if (H == src.holder.owner)
				continue
			H.changeStatus("magnetized", src.duration, charge)
