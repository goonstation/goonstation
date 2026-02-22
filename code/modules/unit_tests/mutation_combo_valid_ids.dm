/datum/unit_test/mutation_combo_valid_ids/Run()
	for(var/recipe in concrete_typesof(/datum/geneticsrecipe))
		var/datum/geneticsrecipe/G = new recipe
		for(var/part in G.required_effects)
			if(!(part in bioEffectList))
				Fail("Combo recipe [G.type] has invalid required effect [part]")
		var/datum/bioEffect/R = G.result
		if (IS_ABSTRACT(R) || !(R::id in bioEffectList))
			Fail("Combo recipe [G.type] has invalid result [R]")
