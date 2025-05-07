/datum/recipe_manager
	var/list/datum/cookingrecipe/oven/oven_recipes = list()
	var/list/datum/cookingrecipe/mixer/mixer_recipes = list()
	var/list/datum/cookingrecipe/oven/oven_recipes_by_ingredient = list() //TODO: merge these into one list after you make recipe flags a thing
	var/list/datum/cookingrecipe/mixer/mixer_recipes_by_ingredient = list()

	New()
		. = ..()
		src.build_recipe_lists()

	proc/build_recipe_lists()
		for(var/R in concrete_typesof(/datum/cookingrecipe/oven))
			var/datum/cookingrecipe/oven/recipe = new R
			src.oven_recipes += recipe

			for(var/ingredient in recipe.ingredients)
				if(!oven_recipes_by_ingredient[ingredient]) oven_recipes_by_ingredient[ingredient] = list()
				src.oven_recipes_by_ingredient[ingredient] += recipe
		sortList(oven_recipes_by_ingredient, /proc/cmp_text_asc)

		for(var/R in concrete_typesof(/datum/cookingrecipe/mixer))
			var/datum/cookingrecipe/mixer/recipe = new R
			src.mixer_recipes += recipe

			for(var/ingredient in recipe.ingredients)
				if(!mixer_recipes_by_ingredient[ingredient]) mixer_recipes_by_ingredient[ingredient] = list()
				src.mixer_recipes_by_ingredient[ingredient] += recipe
		sortList(mixer_recipes_by_ingredient, /proc/cmp_text_asc)


