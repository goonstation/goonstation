//attempts to make each cooking recipe, to ensure they are all reachable
TEST_FOCUS(/datum/unit_test/recipe_picker)
/datum/unit_test/recipe_picker/Run()
	var/obj/machinery/cookingmachine/oven/test_oven = new /obj/machinery/cookingmachine/oven
	var/datum/recipe_manager/RM = get_singleton(/datum/recipe_manager)
	for(var/datum/cookingrecipe/R in RM.oven_recipes)
		for(var/ingredient in R.ingredients)
			for(var/i = 0; i<R.ingredients[ingredient]; i++)
				var/obj/item/I = new ingredient
				test_oven.load_item(I)
		var/obj/item/test_output = test_oven.finish_cook()
		if(!istype(test_output, R.output))
			Fail("Cooking recipe [R] not reachable, made [test_output.type] instead (expecting [R.output])")
		test_oven.contents = list()
		test_oven.possible_recipes = list()
	var/obj/machinery/cookingmachine/mixer/test_mixer = new /obj/machinery/cookingmachine/mixer
	for(var/datum/cookingrecipe/R in RM.mixer_recipes)
		for(var/ingredient in R.ingredients)
			for(var/i = 0; i<R.ingredients[ingredient]; i++)
				var/obj/item/I = new ingredient
				test_mixer.load_item(I)
		var/obj/item/test_output = test_mixer.finish_cook()
		if(!istype(test_output, R.output))
			Fail("Cooking recipe [R] not reachable, made [test_output.type] instead (expecting [R.output])")
		test_mixer.contents = list()
		test_mixer.possible_recipes = list()
