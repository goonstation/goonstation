/// material recipie definition
/datum/material_recipe
	var/name = ""
	/// Path of the result material. Used for setting the material of a generic item if the recipe doesnt specify an item to make.
	var/result_mat = null
	/// Path of the resulting material item.
	var/result_item = null

	//Materials to use as ingredients
	//currently only supports 2 ingredients in equal proportion
	//better solution would be to have an assoc list of materials and their amounts
	var/datum/material/ingredient1 = null
	var/datum/material/ingredient2 = null

	///checks if the requirements are met for the recipe. Try to keep it performant
	proc/validate(var/datum/material/mat1, var/datum/material/mat2)
		if(!(src.ingredient1 && src.ingredient2))
			return FALSE //this didnt get initialized correctly somehow
		if(!(mat1 && mat2))
			return FALSE //somehow we got passed null materials
		if(!(istype(mat1, src.ingredient1) || istype(mat2, src.ingredient1)))
			return FALSE //neither material is ingredient 1
		if(!(istype(mat1, src.ingredient2) || istype(mat2, src.ingredient2)))
			return FALSE //neither material is ingredient 2
		return TRUE //ingredient 1 and 2 are accounted for

	/// If no result id or result items are defined, this proc will be executed on the material. Do this if you want a recipe to just modifiy a material.
	proc/apply_to(var/datum/material/M)
		return M
	/// called with the resultant item from the recipe as argument. Use this if you want to say, print a message when a recipe is made.
	proc/apply_to_obj(var/obj/O)
		return

/datum/material_recipe/hauntium
	name = "hauntium"
	result_mat = /datum/material/textile/hauntium
	result_item = /obj/item/material/cloth/hauntium
	ingredient1 = /datum/material/metal/soulsteel
	ingredient2 = /datum/material/ceramic/crystal/koshmarite

/datum/material_recipe/soulsteel
	name = "soul steel"
	result_mat = /datum/material/metal/soulsteel
	ingredient1 = /datum/material/metal/steel
	ingredient2 = /datum/material/blobby/ectoplasm

/datum/material_recipe/steel
	name = "steel"
	result_mat = /datum/material/metal/steel
	ingredient1 = /datum/material/metal/mauxite
	ingredient2 = /datum/material/ceramic/char

/datum/material_recipe/censorium
	name = "censorium"
	result_mat = /datum/material/ceramic/censorium
	result_item = /obj/item/material/metal/censorium
	ingredient1 = /datum/material/ceramic/rock
	ingredient2 = /datum/material/ceramic/char

/datum/material_recipe/copper //this doesn't REALLY make sense how steel recipe does but I don't care. Need a way to make copper for coroisum
//wtf is "coroisum" --Cherman0
	name = "copper"
	result_mat = /datum/material/metal/copper
	ingredient1 = /datum/material/metal/pharosium
	ingredient2 = /datum/material/ceramic/char

/datum/material_recipe/glass // yeah whatever sure char and molitz makes glass who gives a shit
	name = "glass"
	result_mat = /datum/material/ceramic/glass
	ingredient1 = /datum/material/ceramic/crystal/molitz
	ingredient2 = /datum/material/ceramic/char

/datum/material_recipe/electrum
	name = "electrum"
	result_mat = /datum/material/metal/electrum
	ingredient1 = /datum/material/metal/gold
	ingredient2 = /datum/material/metal/cobryl

/datum/material_recipe/plasmasteel
	name = "plasmasteel"
	result_mat = /datum/material/metal/plasmasteel
	ingredient1 = /datum/material/ceramic/plasmastone
	ingredient2 = /datum/material/metal/steel

/datum/material_recipe/plasmaglass
	name = "plasmaglass"
	result_mat = /datum/material/ceramic/plasmaglass
	ingredient1 = /datum/material/ceramic/plasmastone
	ingredient2 = /datum/material/ceramic/glass

/datum/material_recipe/dyneema
	name = "dyneema"
	result_mat = /datum/material/textile/dyneema
	result_item = /obj/item/material/cloth/dyneema
	ingredient1 = /datum/material/textile/carbonfibre
	ingredient2 = /datum/material/textile/silk/spider

/datum/material_recipe/synthleather
	name = "synthleather"
	result_mat = /datum/material/leathery/synthleather
	ingredient1 = /datum/material/rubbery/latex
	ingredient2 = /datum/material/textile/cotton

/datum/material_recipe/synthblubber
	name = "synthblubber"
	result_mat = /datum/material/rubbery/synthblubber
	ingredient1 = /datum/material/rubbery/synthrubber
	ingredient2 = /datum/material/ceramic/coral
