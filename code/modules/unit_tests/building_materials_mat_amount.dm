/datum/unit_test/building_materials_mat_amount

/datum/unit_test/building_materials_mat_amount/Run()
	for(var/datum/sheet_crafting_recipe/sheet_crafting_recipe_type_dummy as anything in concrete_typesof(/datum/sheet_crafting_recipe))
		var/mats_per_sheet = 10
		var/mats_per_created = initial(sheet_crafting_recipe_type_dummy.sheet_cost) / initial(sheet_crafting_recipe_type_dummy.yield) / mats_per_sheet
		var/atom/crafteed_type_dummy = initial(sheet_crafting_recipe_type_dummy.craftedType)
		var/material_amt = initial(crafteed_type_dummy.material_amt)
		if(material_amt > mats_per_created)
			Fail("In [sheet_crafting_recipe_type_dummy] crafting of [crafteed_type_dummy] requires [mats_per_created] but it can be reclaimed for [material_amt]. Set `material_amt = [mats_per_created]` on it.")


