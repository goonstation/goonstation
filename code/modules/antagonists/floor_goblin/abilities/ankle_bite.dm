/datum/targetable/ankle_bite
	name = "Ankle Bite"
	desc = "Trip a target by biting at their ankles."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "clown_spider_bite"
	cooldown = 20 SECONDS
	targeted = 1
	target_anything = 1

	tryCast()
		if (is_incapacitated(holder.owner))
			boutput(holder.owner, "<span class='alert'>You cannot cast this ability while you are incapacitated.</span>")
			src.holder.locked = FALSE
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		. = ..()

	cast(atom/target)
		if(..())
			return 1
		if(target == holder.owner || !ishuman(target))
			return 1
		if(!(BOUNDS_DIST(holder.owner, target) == 0))
			boutput(holder.owner, "<span class='alert'>Target is too far away.</span>")
			return 1
		var/mob/living/carbon/human/target_human = target
		if(!target_human?.limbs?.l_leg || !target_human?.limbs?.r_leg)
			boutput(holder.owner, "<span class='alert'>[target_human] has no ankles to bite!</span>")
			return 1

		var/x_coeff = rand(0, 1)	// open the floor horizontally
		var/y_coeff = !x_coeff // or vertically but not both - it looks weird
		var/slide_amount = 22 // around 20-25 is just wide enough to show most of the person hiding underneath
		var/turf/floorturf = get_turf(holder.owner)

		if(holder.owner.layer == BETWEEN_FLOORS_LAYER)
			animate_slide(floorturf, x_coeff * -slide_amount, y_coeff * -slide_amount, 4)
			APPLY_ATOM_PROPERTY(holder.owner, PROP_MOB_CANTMOVE, "floorbiting")
			SPAWN(0.4 SECONDS)
				if(holder.owner && target_human && (BOUNDS_DIST(holder.owner, target) == 0))
					playsound(floorturf, 'sound/impact_sounds/Flesh_Tear_3.ogg', 50, 1, pitch = 1.3)
					target_human.changeStatus("weakened", 2 SECONDS)
					target_human.force_laydown_standup()
					holder.owner.visible_message("<span class='combat'><b>[holder.owner] bites at [target_human]'s ankles!</b></span>",\
					"<span class='combat'><b>You bite at [target_human]'s ankles!</b></span>")
					REMOVE_ATOM_PROPERTY(holder.owner, PROP_MOB_CANTMOVE, "floorbiting")
				else
					boutput(holder.owner, "<span class='alert'>[target_human] moved out of reach!</span>")
					REMOVE_ATOM_PROPERTY(holder.owner, PROP_MOB_CANTMOVE, "floorbiting")
				sleep(0.4 SECONDS)
				if(floorturf)
					animate_slide(floorturf, 0, 0, 4)
		else
			playsound(floorturf, 'sound/impact_sounds/Flesh_Tear_3.ogg', 50, 1, pitch = 1.3)
			target_human.changeStatus("weakened", 2 SECONDS)
			target_human.force_laydown_standup()
			holder.owner.visible_message("<span class='combat'><b>[holder.owner] bites at [target_human]'s ankles!</b></span>",\
			"<span class='combat'><b>You bite at [target_human]'s ankles!</b></span>")
		return 0
