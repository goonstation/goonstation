/// Super simple CC. Short-ranged elecflash.
/datum/targetable/grinch/evil_grin
	name = "Grinch Grin"
	desc = "Charge up and unleash your dastardly Grinch Grin!"
	icon_state = "grinchcloak"
	cooldown = 10 SECONDS
	grinch_only = 1

	cast(atom/target)
		. = ..()
		playsound(holder.owner, 'sound/effects/power_charge.ogg', 100)
		actions.start(new/datum/action/bar/private/evil_grin(), src.holder.owner)

/datum/action/bar/private/evil_grin
	duration = 0.75 SECONDS
	interrupt_flags = INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_ACT

	onEnd()
		. = ..()
		APPLY_ATOM_PROPERTY(owner, PROP_MOB_CANTMOVE, "stall")
		var/obj/effects/grinch_grin/grin = /obj/effects/grinch_grin
		new grin (get_turf(owner))
		SPAWN(0.1 SECONDS)
			src.throw_back()
			SPAWN(0.2 SECONDS)
				src.throw_back(4)
				SPAWN(0.2 SECONDS)
					src.throw_back(8, TRUE)
					REMOVE_ATOM_PROPERTY(owner, PROP_MOB_CANTMOVE, "stall")

	proc/throw_back(var/rangeinput = 2, var/damageon = FALSE)
		for (var/mob/living/carbon/human/H in range(rangeinput, src.owner))
			var/turf/targetTurf = get_edge_target_turf(src.owner, get_dir(src.owner, H))
			if (targetTurf)
				H.throw_at(targetTurf, 2, 2)
				if (damageon)
					random_brute_damage(H, 7, 0)
					H.changeStatus("unconscious", 2 SECONDS)
					H.changeStatus("knockdown", 3 SECONDS)
					H.force_laydown_standup()
