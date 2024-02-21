// -----------------
// Simple bite skill
// -----------------
/datum/targetable/critter/cauterize
	name = "Cauterize"
	desc = "Cauterize a mob, stopping all bleeding immediately but inflicting mild fire damage."
	icon_state = "fire_e_cauterize"
	cooldown = 15 SECONDS
	targeted = TRUE
	target_anything = TRUE

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, SPAN_ALERT("Nothing to cauterize there."))
				return 1
		if (target == holder.owner)
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, SPAN_ALERT("That is too far away to cauterize."))
			return 1
		var/mob/MT = target
		if (MT.is_heat_resistant())
			boutput(holder.owner, SPAN_ALERT("[MT] cannot be cauterized."))
			return 1
		MT.TakeDamage("All", 0, 8, 0, DAMAGE_BURN)
		holder.owner.visible_message(SPAN_NOTICE("<b>[holder.owner] cauterizes [MT]!</b>"), SPAN_NOTICE("You cauterize [MT]!"))
		return 0
