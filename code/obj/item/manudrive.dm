/datum/computer/file/manudrive
	name = "Manufacturer Recipes"
	extension = "MNUDR"
	size = 20
	var/list/drivestored = list()
	var/fablimit = -1 //This fablimit gets replaced so just ignore this one and dont worry about it.

	disposing()
		drivestored = null
		. = ..()

/datum/computer/file/manudrive/restricted // This is for manudrives that actually have a fabrication limit. Only difference is there file cant be copied.
	name = "Restricted Manufacturer Recipes"
	dont_copy = 1
/obj/item/disk/data/floppy/manudrive // This one should be the parent of manudrives that dont have a fabrication limit.
	name = "Standard ManuDrive: Empty"
	desc = "A drive for data storage that can be inserted and removed from manufacturers to temporarily add recipes to a manufacturer."
	mats = 0 // These things arent intended to be reproducible (god I butchered that) due to things like fablimits.
	random_color = 0
	icon_state = "datadiskwhi"
	/// Put the recipe string here and itll make em into instances.
	var/list/datum/manufacture/temp_recipe_string = list()
	/// -1 Means it can be used unlimited time, its a lazy solution yet an effective one, numbers above 0 can only have things fabricated from those manudrives x amount of times.
	var/fablimit = -1

	New(var/loc)
		..()
		if(src.fablimit <= 0)
			src.root.add_file( new /datum/computer/file/manudrive(src))
		else
			src.root.add_file( new /datum/computer/file/manudrive/restricted(src))
		for (var/X in src.temp_recipe_string)
			for (var/datum/computer/file/manudrive/MD in src.root.contents)
				MD.drivestored += get_schematic_from_path(X)
				MD.fablimit = src.fablimit
		src.read_only = 1
