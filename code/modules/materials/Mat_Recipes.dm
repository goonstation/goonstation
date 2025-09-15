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

	/// called with the resultant item from the recipe as argument. Use this if you want to say, print a message when a recipe is made.
	proc/apply_to_obj(var/obj/O)
		return

// Metal

/datum/material_recipe/hauntium
	name = "hauntium"
	result_id = "hauntium"
	result_item = /obj/item/material_piece/cloth/hauntium

	validate(var/datum/material/M)
		var/hasSteel = 0
		var/hasKosh = 0

		for(var/datum/material/CM in M.getParentMaterials())
			if(CM.getID() == "soulsteel") hasSteel = 1
			if(CM.getID() == "koshmarite") hasKosh = 1

		if(M.getID() == "soulsteel") hasSteel = 1
		if(M.getID() == "koshmarite") hasKosh = 1

		if(hasSteel && hasKosh) return 1
		else return 0

/datum/material_recipe/soulsteel
	name = "soul steel"
	result_id = "soulsteel"

	validate(var/datum/material/M)
		var/hasSoul = 0
		var/hasSteel = 0

		for(var/datum/material/CM in M.getParentMaterials())
			if(CM.getID() == "ectoplasm") hasSoul = 1
			if(CM.getID() == "steel") hasSteel = 1

		if(M.getID() == "ectoplasm") hasSoul = 1
		if(M.getID() == "steel") hasSteel = 1

		if(hasSoul && hasSteel) return 1
		else return 0

/datum/material_recipe/steel
	name = "steel"
	result_id = "steel"

	validate(var/datum/material/M)
		var/one = 0
		var/two = 0

		for(var/datum/material/CM in M.getParentMaterials())
			if(CM.getID() == "mauxite") one = 1
			if(CM.getID() == "char") two = 1

		if(one && two) return 1
		else return 0

/datum/material_recipe/copper // this doesn't REALLY make sense how steel recipe does but I don't care. Need a way to make copper for coroisum
	name = "copper"
	result_id = "copper"

	validate(var/datum/material/M)
		var/one = 0
		var/two = 0

		for(var/datum/material/CM in M.getParentMaterials())
			if(CM.getID() == "pharosium") one = 1
			if(CM.getID() == "char") two = 1

		if(one && two) return 1
		else return 0

/datum/material_recipe/glass // yeah whatever sure char and molitz makes glass who gives a shit
	name = "glass"
	result_id = "glass"

	validate(datum/material/M)
		var/one = FALSE
		var/two = FALSE

		for(var/datum/material/CM in M.getParentMaterials())
			if(CM.getID() == "molitz") one = TRUE
			if(CM.getID() == "char") two = TRUE

		if(one && two) return TRUE
		else return FALSE

/datum/material_recipe/electrum
	name = "electrum"
	result_id = "electrum"

	validate(var/datum/material/M)
		var/one = 0
		var/two = 0

		for(var/datum/material/CM in M.getParentMaterials())
			if(CM.getID() == "gold") one = 1
			if(CM.getID() == "cobryl") two = 1

		if(one && two) return 1
		else return 0

/datum/material_recipe/voltite
	name = "voltite"
	result_id = "voltite"

	validate(datum/material/M)
		var/has_electrum = FALSE
		var/has_veranium = FALSE

		for (var/datum/material/mat in M.getParentMaterials())
			if (mat.getID() == "electrum")
				has_electrum = TRUE
			else if (mat.getID() == "veranium")
				has_veranium = TRUE

		return has_electrum && has_veranium

/datum/material_recipe/plasmasteel
	name = "plasmasteel"
	result_id = "plasmasteel"

	validate(var/datum/material/M)
		var/one = 0
		var/two = 0

		for(var/datum/material/CM in M.getParentMaterials())
			if(CM.getID() == "plasmastone") one = 1
			if(CM.getID() == "steel") two = 1

		if(one && two) return 1
		else return 0

/datum/material_recipe/neutrite
	name = "neutrite"
	result_id = "neutrite"

	validate(datum/material/M)
		var/has_yuranite = FALSE
		var/has_plutonium = FALSE

		for (var/datum/material/mat in M.getParentMaterials())
			if (mat.getID() == "yuranite")
				has_yuranite = TRUE
			else if (mat.getID() == "plutonium")
				has_plutonium = TRUE

		return has_yuranite && has_plutonium

/datum/material_recipe/neutronium
	name = "neutronium"
	result_id = "neutronium"

	validate(datum/material/M)
		var/has_neutrite = FALSE
		var/has_erebite = FALSE

		for (var/datum/material/mat in M.getParentMaterials())
			if (mat.getID() == "neutrite")
				has_neutrite = TRUE
			else if (mat.getID() == "erebite")
				has_erebite = TRUE

		return has_neutrite && has_erebite

// Glass

/datum/material_recipe/plasmaglass
	name = "plasmaglass"
	result_id = "plasmaglass"

	validate(var/datum/material/M)
		var/one = 0
		var/two = 0

		for(var/datum/material/CM in M.getParentMaterials())
			if(CM.getID() == "plasmastone") one = 1
			if(CM.getID() == "glass") two = 1

		if(one && two) return 1
		else return 0

// Cloths // Organics // Leathers

/datum/material_recipe/dyneema
	name = "dyneema"
	result_id = "dyneema"
	result_item = /obj/item/material_piece/cloth/dyneema

	validate(var/datum/material/M)
		var/hasCarbon = 0
		var/hasSilk = 0

		for(var/datum/material/CM in M.getParentMaterials())
			if(CM.getID() == "carbonfibre") hasCarbon = 1
			if(CM.getID() == "spidersilk") hasSilk = 1

		if(M.getID() == "carbonfibre") hasCarbon = 1
		if(M.getID() == "spidersilk") hasSilk = 1

		if(hasCarbon && hasSilk) return 1
		else return 0

/datum/material_recipe/synthleather
	name = "synthleather"
	result_id = "synthleather"

	validate(var/datum/material/M)
		var/one = 0
		var/two = 0

		for(var/datum/material/CM in M.getParentMaterials())
			if(CM.getID() == "latex") one = 1
			if(CM.getID() == "cotton") two = 1

		if(one && two) return 1
		else return 0

/datum/material_recipe/synthblubber
	name = "synthblubber"
	result_id = "synthblubber"

	validate(var/datum/material/M)
		var/one = 0
		var/two = 0

		var/regex/R = regex("rubber")

		for(var/datum/material/CM in M.getParentMaterials())
			if(CM.getID() == "coral") one = 1
			if(R.Find(CM.getID())) two = 1

		if(one && two) return 1
		else return 0
