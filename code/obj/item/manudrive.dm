/obj/item/disk/data/floppy/read_only/manudrive
	name = "Standard ManuDrive: Empty"
	desc = "A drive for data storage that can be inserted and removed from manufacturers to temporarily add recipes to a manufacturer."
	mats = 0
	random_color = 0
	icon_state = "datadiskwhi"
	var/list/drivestored = list() // It breaks if I delete this and idk why, this shouldnt effect things so
	/// Put the recipe string here and itll make em into instances.
	var/list/datum/manufacture/temp_recipe_string = list()
	/// Means it can be used unlimited time, its a lazy solution yet an effective one.
	var/fablimit = -1

	New(var/loc)
		..()
		src.root.add_file( new /datum/computer/file/manudrive(src))
		for (var/X in src.temp_recipe_string)
			var/datum/computer/file/manudrive/MD = src
			MD.drivestored += get_schematic_from_path(X)
			MD.fablimit = src.fablimit
		src.read_only = 1

/obj/item/disk/data/floppy/read_only/manudrive/test
	name = "test one aaaaa"
	fablimit = 10
	temp_recipe_string = list(/datum/manufacture/RCD,
	/datum/manufacture/RCDammo)

/datum/computer/file/manudrive
	name = "Manufacturer Recipe"
	extension = "MNUDR"
	size = 8
	var/list/drivestored = list()
	var/fablimit = -1 // Eh why not redundancy is good

	disposing()
		drivestored = null
		. = ..()
