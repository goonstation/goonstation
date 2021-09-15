obj/item/manudrive
	name = "Standard ManuDrive: Empty"
	desc = "A drive for data storage that can be inserted and removed from manufacturers to temporarily add recipes to a manufacturer."
	icon = 'icons/obj/items/manudrive.dmi'
	icon_state = "manudrivewhi"
	var/list/datum/manufacture/drivestored = list() // For making new drives, leave this untouched.
	var/list/datum/manufacture/temp_recipe_string = list() // Put the recipe string here and itll make em into instances.
	var/fablimit = -1 // Means it can be used unlimited time, its a lazy solution yet an effective one.

	New(var/loc)
		..()
		for (var/X in src.temp_recipe_string)
			src.drivestored += get_schematic_from_path(X)

obj/item/manudrive/eng
	name = "Engineering ManuDrive: Advanced Engineering Equipment"
	icon_state = "manudriveeng"
	temp_recipe_string = list(/datum/manufacture/heavy_firesuit,
	/datum/manufacture/indus_eng,
	/datum/manufacture/RCD,
	/datum/manufacture/RCDammo,
	/datum/manufacture/RCDammomedium,
	/datum/manufacture/RCDammolarge)
