/obj/item/disk/data/floppy/read_only/manudrive
	name = "Standard ManuDrive: Empty"
	desc = "A drive for data storage that can be inserted and removed from manufacturers to temporarily add recipes to a manufacturer."
	mats = 0 // These things arent intended to be reproducible (god I butchered that) due to things like fablimits.
	random_color = 0
	icon_state = "datadiskwhi"
	/// Put the recipe string here and itll make em into instances.
	var/list/datum/manufacture/temp_recipe_string = list()
	/// -1 Means it can be used unlimited time, its a lazy solution yet an effective one.
	var/fablimit = -1

	New(var/loc)
		..()
		src.root.add_file( new /datum/computer/file/manudrive(src))
		for (var/X in src.temp_recipe_string)
			for (var/datum/computer/file/manudrive/MD in src.root.contents)
				MD.drivestored += get_schematic_from_path(X)
				MD.fablimit = src.fablimit
		src.read_only = 1

/datum/computer/file/manudrive
	name = "Manufacturer Recipe"
	extension = "MNUDR"
	size = 8
	var/list/drivestored = list()
	var/fablimit = -1 // Eh why not redundancy is good

	disposing()
		drivestored = null
		. = ..()

/obj/item/disk/data/floppy/read_only/manudrive/test
	name = "test one aaaaa"
	fablimit = 10
	temp_recipe_string = list(/datum/manufacture/RCD,
	/datum/manufacture/RCDammo)


