/// material recipie definition
/datum/material_recipe
	var/name = ""
	/// typepath of the result material. used as fallback or when you do not want to use a result item.
	var/result_type = null
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

	/// called with the resultant item from the recipe as argument. Use this if you want to say, print a message when a recipe is made.
	proc/apply_to_obj(var/obj/O)
		return

// Metal

/datum/material_recipe/hauntium
	name = "hauntium"
	result_type = /datum/material/fabric/hauntium
	result_item = /obj/item/material_piece/cloth/hauntium

	validate(var/datum/material/M)
		var/hasSteel = FALSE
		var/hasKosh = FALSE

		for(var/datum/material/CM in M.getParentMaterials())
			if(CM.getID() == "soulsteel") hasSteel = TRUE
			if(CM.getID() == "koshmarite") hasKosh = TRUE

		if(M.getID() == "soulsteel") hasSteel = TRUE
		if(M.getID() == "koshmarite") hasKosh = TRUE

		if(hasSteel && hasKosh) return TRUE
		else return FALSE

/datum/material_recipe/soulsteel
	name = "soul steel"
	result_type = /datum/material/metal/soulsteel

	validate(var/datum/material/M)
		var/hasSoul = FALSE
		var/hasSteel = FALSE

		for(var/datum/material/CM in M.getParentMaterials())
			if(CM.getID() == "ectoplasm") hasSoul = TRUE
			if(CM.getID() == "steel") hasSteel = TRUE

		if(M.getID() == "ectoplasm") hasSoul = TRUE
		if(M.getID() == "steel") hasSteel = TRUE

		if(hasSoul && hasSteel) return TRUE
		else return FALSE

/datum/material_recipe/steel
	name = "steel"
	result_type = /datum/material/metal/steel

	validate(var/datum/material/M)
		var/one = FALSE
		var/two = FALSE

		for(var/datum/material/CM in M.getParentMaterials())
			if(CM.getID() == "mauxite") one = TRUE
			if(CM.getID() == "char") two = TRUE

		if(one && two) return TRUE
		else return FALSE

/datum/material_recipe/censorium
	name = "censorium"
	result_type = /datum/material/metal/censorium
	result_item = /obj/item/material_piece/metal/censorium

	validate(var/datum/material/M)
		var/hasChar = FALSE
		var/hasRock = FALSE

		for(var/datum/material/CM in M.getParentMaterials())
			if(CM.getID() == "char") hasChar = TRUE
			if(CM.getID() == "rock") hasRock = TRUE

		if(M.getID() == "char") hasChar = TRUE
		if(M.getID() == "rock") hasRock = TRUE

		if(hasChar && hasRock) return TRUE
		else return FALSE

/datum/material_recipe/copper // this doesn't REALLY make sense how steel recipe does but I don't care. Need a way to make copper for coroisum
	name = "copper"
	result_type = /datum/material/metal/copper

	validate(var/datum/material/M)
		var/one = FALSE
		var/two = FALSE

		for(var/datum/material/CM in M.getParentMaterials())
			if(CM.getID() == "pharosium") one = TRUE
			if(CM.getID() == "char") two = TRUE

		if(one && two) return TRUE
		else return FALSE

/datum/material_recipe/electrum
	name = "electrum"
	result_type = /datum/material/metal/electrum

	validate(var/datum/material/M)
		var/one = FALSE
		var/two = FALSE

		for(var/datum/material/CM in M.getParentMaterials())
			if(CM.getID() == "gold") one = TRUE
			if(CM.getID() == "cobryl") two = TRUE

		if(one && two) return TRUE
		else return FALSE

/datum/material_recipe/plasmasteel
	name = "plasmasteel"
	result_type = /datum/material/metal/plasmasteel

	validate(var/datum/material/M)
		var/one = FALSE
		var/two = FALSE

		for(var/datum/material/CM in M.getParentMaterials())
			if(CM.getID() == "plasmastone") one = TRUE
			if(CM.getID() == "steel") two = TRUE

		if(one && two) return TRUE
		else return FALSE

// Glass

/datum/material_recipe/plasmaglass
	name = "plasmaglass"
	result_type = /datum/material/crystal/plasmaglass

	validate(var/datum/material/M)
		var/one = FALSE
		var/two = FALSE

		for(var/datum/material/CM in M.getParentMaterials())
			if(CM.getID() == "plasmastone") one = TRUE
			if(CM.getID() == "glass") two = TRUE

		if(one && two) return TRUE
		else return FALSE

// Cloths // Organics // Leathers

/datum/material_recipe/dyneema
	name = "dyneema"
	result_type = /datum/material/fabric/dyneema
	result_item = /obj/item/material_piece/cloth/dyneema

	validate(var/datum/material/M)
		var/hasCarbon = FALSE
		var/hasSilk = FALSE

		for(var/datum/material/CM in M.getParentMaterials())
			if(CM.getID() == "carbonfibre") hasCarbon = TRUE
			if(CM.getID() == "spidersilk") hasSilk = TRUE

		if(M.getID() == "carbonfibre") hasCarbon = TRUE
		if(M.getID() == "spidersilk") hasSilk = TRUE

		if(hasCarbon && hasSilk) return TRUE
		else return FALSE

/datum/material_recipe/synthleather
	name = "synthleather"
	result_type = /datum/material/fabric/synthleather

	validate(var/datum/material/M)
		var/one = FALSE
		var/two = FALSE

		for(var/datum/material/CM in M.getParentMaterials())
			if(CM.getID() == "latex") one = TRUE
			if(CM.getID() == "cotton") two = TRUE

		if(one && two) return TRUE
		else return FALSE

/datum/material_recipe/synthblubber
	name = "synthblubber"
	result_type = /datum/material/rubber/synthblubber

	validate(var/datum/material/M)
		var/one = FALSE
		var/two = FALSE

		var/regex/R = regex("rubber")

		for(var/datum/material/CM in M.getParentMaterials())
			if(CM.getID() == "coral") one = TRUE
			if(R.Find(CM.getID())) two = TRUE

		if(one && two) return TRUE
		else return FALSE
