/datum/targetable/grinch/poison
	name = "Poison food"
	desc = "Ruin a food item or drink by adding horrible poison to it."
	targeted = 1
	target_anything = 1
	target_nodamage_check = 1
	max_range = 1
	cooldown = 600
	start_on_cooldown = 0
	pointCost = 0
	when_stunned = 0
	not_when_handcuffed = 1
	var/list/the_poison = list("coniine", "cyanide", "curare")
	var/amount_per_poison = 7

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner

		if (!M || !target)
			return 1

		if (M == target)
			boutput(M, __red("Why would you want to poison yourself?"))
			return 1

		if (get_dist(M, target) > src.max_range)
			boutput(M, __red("[target] is too far away."))
			return 1

		// Written in such a way that adding other reagent containers (e.g. medicine) would be trivial.
		var/obj/item/reagent_containers/RC = null
		var/attempt_success = 0

		if (istype(target, /obj/item/reagent_containers/food)) // Food and drinking glass/bottle parent.
			RC = target
		else
			boutput(M, __red("You can't poison [target], only food items and drinks."))
			return 1

		if (RC && istype(RC))
			if (src.the_poison.len > 1)
				if (!RC.reagents)
					RC.reagents = new /datum/reagents(src.amount_per_poison * src.the_poison.len)
					RC.reagents.my_atom = RC

				if (RC.reagents)
					for (var/P in src.the_poison)
						if (RC.reagents.total_volume + src.amount_per_poison >= RC.reagents.maximum_volume)
							RC.reagents.maximum_volume += src.amount_per_poison
						RC.reagents.add_reagent(P, src.amount_per_poison)

					if (istype(RC, /obj/item/reagent_containers/food/))
						var/obj/item/reagent_containers/food/F = RC
						F.festivity -= 3

					RC.add_fingerprint(M)
					attempt_success = 1
				else
					attempt_success = 0
			else
				attempt_success = 0
		else
			attempt_success = 0

		if (attempt_success == 1)
			boutput(M, __blue("You successfully poisoned [target]."))
			logTheThing("combat", M, null, "poisons [target] [log_reagents(target)] at [log_loc(M)].")
			return 0
		else
			boutput(M, __red("You failed to poison [target]."))
			return 1
