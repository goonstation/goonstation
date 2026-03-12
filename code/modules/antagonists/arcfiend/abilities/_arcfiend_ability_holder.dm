#define MAX_ARCFIEND_POINTS 2500

/// The ability holder used for arcfiends. Comes with no abilities on its own.
/datum/abilityHolder/arcfiend
	usesPoints = TRUE
	regenRate = 0
	tabName = "Arcfiend"

	/// The total number of points we've accumulated over our lifetime
	var/lifetime_energy = 0
	/// Number of hearts stopped with Jolt
	var/hearts_stopped = 0
	/// Total number of machines overloaded
	var/machines_overloaded = 0

	onAbilityStat()
		..()
		. = list()
		.["Energy:"] = round(src.points)
		var/total_display = round(src.lifetime_energy)
		if (total_display >= 10000)
			total_display = "[round(total_display / 1000, 1.1)]k"
		.["Total:"] = total_display

	addPoints(add_points, target_ah_type = src.type)
		var/points = min((MAX_ARCFIEND_POINTS - src.points), add_points)
		if (points > 0)
			src.lifetime_energy += points
			if (ishuman(src.owner))
				var/mob/living/carbon/human/H = src.owner
				if (H.sims)
					H.sims.affectMotive("Thirst", points * 0.1)
					H.sims.affectMotive("Hunger", points * 0.1)
		. = ..(points, target_ah_type)
		src.updateText()
		src.updateButtons()

	onLife()
		..()
		//failsafe to ensure arcfiends always have SMES human
		if (!src.owner.bioHolder.HasEffect("resist_electric"))
			src.owner.bioHolder.AddEffect("resist_electric", power = 2, magical = TRUE)
			src.owner.ClearSpecificOverlays("resist_electric")

ABSTRACT_TYPE(/datum/targetable/arcfiend)
/datum/targetable/arcfiend
	name = "base arcfiend ability (you should never see me)"
	icon = 'icons/mob/arcfiend.dmi'
	cooldown = 0
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/arcfiend

	/// Whether or not this ability can be cast from inside of things (locker, voltron, etc.)
	var/container_safety_bypass = FALSE

	castcheck(atom/target)
		var/area/A = get_area(holder.owner)
		if (A.sanctuary)
			boutput(holder.owner, SPAN_ALERT("You cannot use your abilities in a sanctuary."))
			return FALSE
		var/mob/living/M = src.holder.owner
		if (!container_safety_bypass && !isturf(M.loc))
			boutput(holder.owner, SPAN_ALERT("Interference from [M.loc] is preventing use of this ability!"))
			return FALSE
		if (!can_act(M) && target != holder.owner) // we can self cast while incapacitated
			boutput(holder.owner, SPAN_ALERT("Not while incapacitated."))
			return FALSE
		return TRUE

	cast(atom/target)
		. = ..()
		// updateButtons is already called automatically in the parent ability's tryCast
		src.holder.updateText()

#undef MAX_ARCFIEND_POINTS
