/datum/recipe_instructions/microwave
	var/cook_time = 8 SECONDS
	var/force_dirtiness = null // Sets the dirtiness when successfully cooked. Can be MW_CLEAN, MW_DIRTY_EGG, MW_DIRTY_SLIME, or null for no change
	var/force_breakage = FALSE
	var/delete_ingredient = TRUE
	var/post_cook_effect = FALSE // if true, the microwave will call post_cook_effect() on this recipe after all the cooking is completed and
								 // the items are ejected

	get_id()
		return RECIPE_ID_MICROWAVE

	//this should maybe be a structured as a callback if it gets used more widely, but for now there's not really a need for it to be more complex
	proc/post_cook_effect(var/obj/machinery/microwave/source)
		return

/// default microwave instructions for general cooking, used whenever no special instructions exist for a recipe
/datum/recipe_instructions/microwave/default_cook

/// default microwave instructions for use during sequential cooking, i.e. when heating up a list of ingredients instead of processing a
/// multi-ingredient recipe
/datum/recipe_instructions/microwave/default_heat_up
	delete_ingredient = FALSE


/datum/recipe_instructions/microwave/egg
	force_dirtiness = MW_DIRTY_EGG
	force_breakage = TRUE

/datum/recipe_instructions/microwave/cooked_slug
	force_dirtiness = MW_DIRTY_SLIME
	post_cook_effect = TRUE

	post_cook_effect(var/obj/machinery/microwave/source)
		if (!ON_COOLDOWN(source, "slug_message", 1) && prob(6))
			source.visible_message(SPAN_NOTICE("Nature is beautiful."))

