/// the base type for cooking recipe instructions
ABSTRACT_TYPE(/datum/recipe_instructions/cooking)
/datum/recipe_instructions/cooking
	var/useshumanmeat = 0 // used for naming of human meat dishes after their victims.

	proc/output_post_process(list/input_list, list/output_list, atom/cook_source = null, mob/user = null)
		if (!src.useshumanmeat)
			return
		// naming of food after human products.
		// TODO this should perhaps work off components and/or infer from the input list instead of an explicit flag
		for(var/obj/item/reagent_containers/food/snacks/F in output_list)
			var/foodname = F.name
			for (var/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat/M in input_list)
				F.name = "[M.subjectname] [foodname]"
				F.desc += " It sort of smells like [M.subjectjob ? M.subjectjob : "pig"]s."
				if(!isnull(F.unlock_medal_when_eaten))
					continue
				else if (M.subjectjob && M.subjectjob == "Clown")
					F.unlock_medal_when_eaten = "That tasted funny"
				else
					F.unlock_medal_when_eaten = "Space Ham" //replace the old fat person method
