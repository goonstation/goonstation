/// Super simple CC. Short-ranged elecflash.
/datum/targetable/grinch/evil_grin
	name = "Grinch Grin"
	desc = "Charge up and unleash your dastardly Grinch Grin!"
	icon_state = "grinchcloak"
	cooldown = 10 SECONDS
	grinch_only = 1

	cast(atom/target)
		. = ..()
		actions.start(new/datum/action/bar/private/evil_grin(), src.holder.owner)

/datum/action/bar/private/evil_grin
	duration = 0.75 SECONDS
	interrupt_flags = INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_ACT
	var/list/people_used_on

	onEnd()
		. = ..()
		playsound(src.owner, 'sound/effects/grunch.ogg', 100)
		LAZYLISTADD(src.people_used_on, src.owner)
		APPLY_ATOM_PROPERTY(owner, PROP_MOB_CANTMOVE, "stall")
		var/obj/effects/grinch_grin/grin = /obj/effects/grinch_grin
		new grin (get_turf(owner))
		SPAWN(0.1 SECONDS)
			src.throw_back()
			SPAWN(0.2 SECONDS)
				src.throw_back(2)
				SPAWN(0.2 SECONDS)
					src.throw_back(4)
					REMOVE_ATOM_PROPERTY(owner, PROP_MOB_CANTMOVE, "stall")
					src.people_used_on = null

	proc/throw_back(var/rangeinput = 1, var/damageon = FALSE)
		for (var/mob/living/carbon/human/H in range(rangeinput, src.owner))
			var/turf/targetTurf = get_edge_target_turf(src.owner, get_dir(src.owner, H))
			if (!targetTurf)
				return
			if (H in src.people_used_on)
				continue
			else
				H.throw_at(targetTurf, 2, 2)
				LAZYLISTADD(src.people_used_on, H)
				random_brute_damage(H, 12, 0)
				H.changeStatus("unconscious", 2 SECONDS)
				H.changeStatus("knockdown", 3 SECONDS)
				H.force_laydown_standup()
