obj/item/manudrive
	name = "Standard ManuDrive: Empty"
	desc = "A drive for data storage that can be inserted and removed from manufacturers to temporarily add recipes to a manufacturer."
	icon = 'icons/obj/items/manudrive.dmi'
	icon_state = "manudrivewhi"
	/// For making new drives, leave this untouched.
	var/list/datum/manufacture/drivestored = list()
	/// Put the recipe string here and itll make em into instances.
	var/list/datum/manufacture/temp_recipe_string = list()
	/// Means it can be used unlimited time, its a lazy solution yet an effective one.
	var/fablimit = -1

	New(var/loc)
		..()
		for (var/X in src.temp_recipe_string)
			src.drivestored += get_schematic_from_path(X)

