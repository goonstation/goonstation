/datum/targetable/wraithAbility/poison
	name = "Defile"
	desc = "Manifest some horrible poison inside a food item or a container."
	icon_state = "wraithpoison"
	targeted = 1
	target_anything = 1
	target_nodamage_check = 1
	cooldown = 50 SECONDS
	pointCost = 50
	var/list/the_poison = list("Rat Spit", "Grave Dust", "Cyanide", "Loose Screws", "Rotting", "Bee", "Mucus")
	var/amount_per_poison = 10

	cast(mob/target)
		if (!holder)
			return 1
		if(..())
			return 1
		var/mob/living/intangible/wraith/W = holder.owner

		if (!W || !target)
			return 1

		if (W == target)
			boutput(W, SPAN_ALERT("Why would you want to poison yourself?"))
			return 1

		var/obj/item/reagent_containers/current_container = null
		var/attempt_success = 0

		if (istype(target, /obj/item/reagent_containers/food))
			current_container = target
		else
			boutput(W, SPAN_ALERT("You can't poison [target], only food items, drinks and glass containers."))
			return 1

		var/poison_name = tgui_input_list(holder.owner, "Select the target poison: ", "Target Poison", the_poison)
		if(!poison_name)
			return 1

		var/poison_id = null
		switch(poison_name)
			if ("Rat Spit")
				poison_id = "rat_spit"
			if ("Grave Dust")
				poison_id = "grave dust"
			if ("Cyanide")
				poison_id = "cyanide"
			if ("Loose Screws")
				poison_id = "loose_screws"
			if ("Rotting")
				poison_id = "rotting"
			if ("Bee")
				poison_id = "bee"
			if ("Mucus")
				poison_id = "mucus"
			else
				return 1


		if (current_container && istype(current_container))
			if (length(src.the_poison) > 1)
				if (!current_container.reagents)
					current_container.reagents = new /datum/reagents(src.amount_per_poison)
					current_container.reagents.my_atom = current_container

				if (current_container.reagents)
					if (current_container.reagents.total_volume + src.amount_per_poison >= current_container.reagents.maximum_volume)
						current_container.reagents.remove_any(current_container.reagents.total_volume + src.amount_per_poison - current_container.reagents.maximum_volume)
					current_container.reagents.add_reagent(poison_id, src.amount_per_poison)


					attempt_success = 1
				else
					attempt_success = 0
			else
				attempt_success = 0
		else
			attempt_success = 0

		if (attempt_success == 1)
			boutput(W, SPAN_NOTICE("You successfully poisoned [target]."))
			logTheThing(LOG_COMBAT, W, "poisons [target] [log_reagents(target)] at [log_loc(W)].")
			return 0
		else
			boutput(W, SPAN_ALERT("You failed to poison [target]."))
			return 1
