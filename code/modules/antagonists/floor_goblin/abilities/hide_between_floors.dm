/datum/targetable/hide_between_floors
	name = "Toggle Reveal"
	desc = "Toggle your ability to hide between the floor tiles."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "floorgoblin_hide"
	targeted = FALSE
	cooldown = 0

	tryCast()
		if (is_incapacitated(holder.owner))
			boutput(holder.owner, SPAN_ALERT("You cannot cast this ability while you are incapacitated."))
			src.holder.locked = FALSE
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		. = ..()

	cast(atom/T)
		var/mob/M = src.holder.owner
		if (!M) return
		var/turf/floorturf = get_turf(M)
		var/x_coeff = rand(0, 1)	// open the floor horizontally
		var/y_coeff = !x_coeff // or vertically but not both - it looks weird
		var/slide_amount = 22 // around 20-25 is just wide enough to show most of the person hiding underneath

		. = ..()
		if(M.layer == BETWEEN_FLOORS_LAYER)
			APPLY_ATOM_PROPERTY(M, PROP_MOB_HIDE_ICONS, "underfloor")
			M.flags &= ~(NODRIFT | DOORPASS | TABLEPASS)
			APPLY_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, "floorswitching")
			REMOVE_ATOM_PROPERTY(M, PROP_MOB_NO_MOVEMENT_PUFFS, "floorswitching")
			REMOVE_ATOM_PROPERTY(M, PROP_ATOM_NEVER_DENSE, "floorswitching")
			M.set_density(initial(M.density))
			if (floorturf.intact)
				animate_slide(floorturf, x_coeff * -slide_amount, y_coeff * -slide_amount, 4)
			SPAWN(0.4 SECONDS)
				if(M)
					M.layer = MOB_LAYER
					M.plane = PLANE_DEFAULT
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, "floorswitching")
				if(floorturf?.intact)
					animate_slide(floorturf, 0, 0, 4)

		else
			REMOVE_ATOM_PROPERTY(M, PROP_MOB_HIDE_ICONS, "underfloor")
			APPLY_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, "floorswitching")
			if (floorturf.intact)
				animate_slide(floorturf, x_coeff * -slide_amount, y_coeff * -slide_amount, 4)
			SPAWN(0.4 SECONDS)
				if(M)
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, "floorswitching")
					APPLY_ATOM_PROPERTY(M, PROP_MOB_NO_MOVEMENT_PUFFS, "floorswitching")
					APPLY_ATOM_PROPERTY(M, PROP_ATOM_NEVER_DENSE, "floorswitching")
					M.flags |= NODRIFT | DOORPASS | TABLEPASS
					M.set_density(0)
					M.layer = BETWEEN_FLOORS_LAYER
					M.plane = PLANE_FLOOR
				if(floorturf?.intact)
					animate_slide(floorturf, 0, 0, 4)
