/datum/targetable/brain_slug/restraining_spit
	name = "Restraining Spit"
	desc = "Horfs some movement impairing goo at someone next to you."
	icon_state = "slimeshot"
	cooldown = 50 SECONDS
	targeted = 1
	pointCost = 30

	onAttach(datum/abilityHolder/holder)
		if (istype(holder.owner, /mob/living/critter/adult_brain_slug))
			src.pointCost = null
		. = ..()

	cast(atom/target)
		if (!isturf(holder.owner.loc))
			boutput(holder.owner, "<span class='notice'>You cannot use that here!</span>")
			return TRUE
		if (target == holder.owner)
			return TRUE
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to restrain.</span>")
			return TRUE
		new /obj/machinery/brain_slug/restraining_goo(target.loc, target)
		//Todo add a sound
		holder.owner.visible_message("<span class='alert'>[holder.owner] spews a revolting stream of slime at [target]'s legs!</span>", "<span class='alert'>You spit restraining slime at [target] to hold them in place.</span>")
		return FALSE
