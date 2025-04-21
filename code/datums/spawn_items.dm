#define POCKETS SLOT_L_STORE, SLOT_R_STORE

ABSTRACT_TYPE(/datum/spawnItem)
/datum/spawnItem
	///The path of the default item to spawn
	var/path = null
	///The slots to try to place that item in, in order
	var/list/slots = list()
	///A list of types this can replace, the original will be stored if possible
	var/list/replaces = list()

	///Can return something different depending on the person's traits/job
	proc/get_path(mob/living/carbon/human/target)
		return src.path

	proc/apply_to(mob/living/carbon/human/target)
		var/path = src.get_path(target)
		for (var/slot in src.slots)
			var/obj/item/existing_item = target.get_slot(slot)
			if (istypes(existing_item, src.replaces))
				target.u_equip(existing_item)
				target.stow_in_available(existing_item)
			if (target.equip_new_if_possible(path, slot))
				return TRUE

/datum/spawnItem/zippo
	path = /obj/item/device/light/zippo
	slots = list(POCKETS, SLOT_IN_BACKPACK)

/datum/spawnItem/visor
	path = /obj/item/clothing/glasses/visor
	slots = list(SLOT_GLASSES)
	replaces = list(/obj/item/clothing/glasses)
