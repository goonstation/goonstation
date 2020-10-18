/// material recipie definition
/datum/material_recipe
	var/name = ""
	/// ID of the result material. used as fallback or when you do not want to use a result item.
	var/result_id = null
	/// Path of the resulting material item.
	var/result_item = null

	/**
		* This checks if the recipe applies to the given result material.
		*
		* This is a proc so you can do practically anything for recipes.
		*
		* Want a recipe that only applies to wool + erebite composites and only if they have a high temperature resistance? You can.
		*
		* Try to keep these cheap if you can.
		*/
	proc/validate(var/datum/material/M)
		return null

	/// If no result id or result items are defined, this proc will be executed on the material. Do this if you want a recipe to just modifiy a material.
	proc/apply_to(var/datum/material/M)
		return M

/datum/material_recipe/spacelag
	name = "spacelag"
	result_id = "spacelag"
	result_item = /obj/item/material_piece/spacelag

	validate(var/datum/material/M)
		if(M.hasProperty("stability") && M.getProperty("stability") <= 1) return 1
		else return 0

/datum/material_recipe/dyneema
	name = "dyneema"
	result_id = "dyneema"
	result_item = /obj/item/material_piece/cloth/dyneema

	validate(var/datum/material/M)
		var/hasCarbon = 0
		var/hasSilk = 0

		for(var/datum/material/CM in M.parent_materials)
			if(CM.mat_id == "carbonfibre") hasCarbon = 1
			if(CM.mat_id == "spidersilk") hasSilk = 1

		if(M.mat_id == "carbonfibre") hasCarbon = 1
		if(M.mat_id == "spidersilk") hasSilk = 1

		if(hasCarbon && hasSilk) return 1
		else return 0

/datum/material_recipe/hauntium
	name = "hauntium"
	result_id = "hauntium"
	result_item = /obj/item/material_piece/cloth/hauntium

	validate(var/datum/material/M)
		var/hasSteel = 0
		var/hasKosh = 0

		for(var/datum/material/CM in M.parent_materials)
			if(CM.mat_id == "soulsteel") hasSteel = 1
			if(CM.mat_id == "koshmarite") hasKosh = 1

		if(M.mat_id == "soulsteel") hasSteel = 1
		if(M.mat_id == "koshmarite") hasKosh = 1

		if(hasSteel && hasKosh) return 1
		else return 0

/datum/material_recipe/soulsteel
	name = "soul steel"
	result_id = "soulsteel"

	validate(var/datum/material/M)
		var/hasSoul = 0
		var/hasSteel = 0

		for(var/datum/material/CM in M.parent_materials)
			if(CM.mat_id == "ectoplasm") hasSoul = 1
			if(CM.mat_id == "steel") hasSteel = 1

		if(M.mat_id == "ectoplasm") hasSoul = 1
		if(M.mat_id == "steel") hasSteel = 1

		if(hasSoul && hasSteel) return 1
		else return 0

/datum/material_recipe/steel
	name = "steel"
	result_id = "steel"

	validate(var/datum/material/M)
		var/one = 0
		var/two = 0

		for(var/datum/material/CM in M.parent_materials)
			if(CM.mat_id == "mauxite") one = 1
			if(CM.mat_id == "char") two = 1

		if(one && two) return 1
		else return 0

/datum/material_recipe/electrum
	name = "electrum"
	result_id = "electrum"

	validate(var/datum/material/M)
		var/one = 0
		var/two = 0

		for(var/datum/material/CM in M.parent_materials)
			if(CM.mat_id == "gold") one = 1
			if(CM.mat_id == "cobryl") two = 1

		if(one && two) return 1
		else return 0

/datum/material_recipe/plasmasteel
	name = "plasmasteel"
	result_id = "plasmasteel"

	validate(var/datum/material/M)
		var/one = 0
		var/two = 0

		for(var/datum/material/CM in M.parent_materials)
			if(CM.mat_id == "plasmastone") one = 1
			if(CM.mat_id == "steel") two = 1

		if(one && two) return 1
		else return 0

/datum/material_recipe/plasmaglass
	name = "plasmaglass"
	result_id = "plasmaglass"

	validate(var/datum/material/M)
		var/one = 0
		var/two = 0

		for(var/datum/material/CM in M.parent_materials)
			if(CM.mat_id == "plasmastone") one = 1
			if(CM.mat_id == "glass") two = 1

		if(one && two) return 1
		else return 0

/datum/material_recipe/neutronium
	name = "neutronium"
	result_id = "neutronium"

	validate(var/datum/material/M)
		return (M.getProperty("radioactive") >= 60 && M.getProperty("density") >= 60)
