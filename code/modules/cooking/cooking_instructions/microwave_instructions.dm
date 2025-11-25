/datum/recipe_instructions/microwave
	var/cook_time = 8 SECONDS
	var/force_dirtiness = null // Sets the dirtiness when successfully cooked. Can be MW_CLEAN, MW_DIRTY_EGG, MW_DIRTY_SLIME, or null for no change
	var/force_breakage = FALSE
	var/delete_ingredient = TRUE

	get_id()
		return RECIPE_ID_MICROWAVE


/// default microwave instructions for general cooking, used whenever no special instructions exist for a recipe
/datum/recipe_instructions/microwave/default_cook

/// default microwave instructions for use during sequential cooking, i.e. when heating up a list of ingredients instead of processing as a batch
/datum/recipe_instructions/microwave/default_heat_up
	delete_ingredient = FALSE


/datum/recipe_instructions/microwave/egg
	force_dirtiness = MW_DIRTY_EGG
	force_breakage = TRUE

/datum/recipe_instructions/microwave/cooked_slug
	force_dirtiness = MW_DIRTY_SLIME

