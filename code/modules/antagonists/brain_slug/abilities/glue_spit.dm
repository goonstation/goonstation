/datum/targetable/brain_slug/glue_spit
	name = "Adhesive Spit"
	desc = "Cover something in a glue-like substance and render it adhesive."
	icon_state = "slimeshot"
	cooldown = 40 SECONDS
	targeted = 1
	target_anything = 1
	pointCost = 40

	cast(atom/target)
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to restrain.</span>")
			return TRUE
		var/datum/reagents/temp_reagents = new /datum/reagents(15)
		temp_reagents.add_reagent("spaceglue",15)
		temp_reagents.reaction(target, TOUCH, 15)
		qdel(temp_reagents)
		boutput(holder.owner, "<span class='notice'>You drool some mucus on [target], making it unpleasantly sticky.</span>")
		return FALSE
