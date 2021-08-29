obj/item/fabdisk
	name = "ManuDisk: Empty"
	desc = "A cartridge for data storage that can be inserted and removed from manufacturers to temporarily add recipes to a manufacturer."
	icon = 'icons/obj/items/fabdisk.dmi'
	icon_state = "fabdiskblu"
	var/list/datum/manufacture/diskstored = list()
	var/list/datum/manufacture/disktemp = list()
	var/fablimit = inf

	New(var/loc,var/schematic = null)
		..()
		for (var/X in src.disktemp)
			src.diskstored += get_schematic_from_path(X)

obj/item/fabdisk/debug // just for testing purposes.
	name = "Standard ManuDisk: Debug"
	desc = "Hey how did you get this! Give it back!"
	disktemp = list(/datum/manufacture/id_card_gold,
	/datum/manufacture/implant_access_infinite,
	/datum/manufacture/breathmask,
	/datum/manufacture/patch,
	/datum/manufacture/hat_ltophat)

obj/item/fabdisk/debug2 // just for testing purposes.
	name = "Standard ManuDisk: Debug the Sequel"
	desc = "Hey how did you get this! Give it back!"
	fablimit = 5
	disktemp = list(/datum/manufacture/screwdriver,
		/datum/manufacture/wirecutters)
