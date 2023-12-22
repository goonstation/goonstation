/datum/targetable/grinch/poison
	name = "Poison food"
	desc = "Ruin a food item or drink by adding horrible poison to it."
	icon_state = "grinchpoison"
	targeted = TRUE
	target_non_mobs = TRUE
	target_self = FALSE
	cooldown = 60 SECONDS
	var/list/the_poison = list("coniine", "cyanide", "curare")
	var/amount_per_poison = 7

	cast(obj/item/reagent_containers/target)
		. = ..()
		var/mob/living/M = src.holder.owner

		for (var/P in src.the_poison)
			if (target.reagents.total_volume + src.amount_per_poison >= target.reagents.maximum_volume)
				target.reagents.maximum_volume += src.amount_per_poison
			target.reagents.add_reagent(P, src.amount_per_poison)

		if (istype(target, /obj/item/reagent_containers/food/))
			var/obj/item/reagent_containers/food/F = RC
			F.festivity -= 3

		RC.add_fingerprint(M)

		boutput(M, SPAN_SUCCESS("You poison [target]."))
		logTheThing(LOG_COMBAT, M, "poisons [target] [log_reagents(target)] at [log_loc(M)].")

	castcheck(atom/target)
		. = ..()
		var/mob/living/M = src.holder.owner
		if (!istype(target, /obj/item/reagent_containers/food)) // Food and drinking glass/bottle parent.
			boutput(M, SPAN_ALERT("You can't poison [target], only food items and drinks."))
			return FALSE

		if (M == target)
			boutput(M, SPAN_ALERT("Why would you want to poison yourself?"))
			return FALSE
