// ------
// Tackle
// ------
/datum/targetable/critter/tackle
	name = "Tackle"
	desc = "Tackle a mob, making them fall over."
	cooldown = 15 SECONDS
	icon_state = "tackle"
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
				boutput(holder.owner, SPAN_ALERT("Nothing to tackle there."))
				return 1
		if (target == holder.owner)
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, SPAN_ALERT("That is too far away to tackle."))
			return 1
		playsound(target, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, TRUE, -1)
		var/mob/MT = target
		MT.changeStatus("knockdown", 3 SECONDS)
		holder.owner.visible_message(SPAN_ALERT("<b>[holder.owner] tackles [MT]!</b>"), SPAN_ALERT("You tackle [MT]!"))
		return FALSE

// weaker tackle, usually stuns but sometimes knocks down
/datum/targetable/critter/weak_tackle
	name = "Weak Tackle"
	desc = "Tackle a mob, stunning them."
	cooldown = 7 SECONDS
	icon_state = "tackle"
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
				boutput(holder.owner, SPAN_ALERT("Nothing to tackle there."))
				return 1
		if (target == holder.owner)
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, SPAN_ALERT("That is too far away to tackle."))
			return 1
		playsound(target, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, TRUE, -1)
		var/mob/MT = target
		MT.changeStatus("stunned", 1 SECOND)
		if (prob(25))
			MT.changeStatus("knockdown", 2 SECONDS)
		holder.owner.visible_message(SPAN_ALERT("<b>[holder.owner] tackles [MT]!</b>"), SPAN_ALERT("You tackle [MT]!"))
		return FALSE
