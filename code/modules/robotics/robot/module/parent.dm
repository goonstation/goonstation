/obj/item/robot_module
	name = "blank cyborg module"
	desc = "A blank cyborg module. It has minimal function in its current state."
	icon = 'icons/obj/items/cyborg_parts/modules.dmi'
	icon_state = "blank"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "electronic"
	w_class = 2.0
	flags = FPRINT | TABLEPASS | CONDUCT
	var/list/modules = list()
	var/mod_hudicon = "unknown"
	var/cosmetic_mods = null
	var/includes_common_items = 1
	var/included_items = null
	var/included_cosmetic = null
	var/radio_type = null
	var/obj/item/device/radio/radio = null

/obj/item/robot_module/New()
	// add item contents
	if (src.includes_common_items)
		src.add_contents(/datum/robot/module_item_creator/recursive/module/common)
	src.add_contents(src.included_items)
	// no need to keep the definition past initializing
	src.included_items = null

	// add cosmetics
	if (ispath(src.included_cosmetic, /datum/robot_cosmetic))
		src.cosmetic_mods = new included_cosmetic(src)

	if (src.radio_type != null)
		src.radio = new src.radio_type(src)

// handle various ways of adding items to the module
/obj/item/robot_module/proc/add_contents(adding_contents)
	if (isnull(adding_contents))
		return
	if (istype(adding_contents, /obj/item))
		// handle adding single instance of item
		var/obj/item/I = adding_contents
		I.cant_drop = 1
		I.set_loc(src)
		src.modules += I
		return I
	if (ispath(adding_contents, /obj/item))
		// handle adding item by path (instantiate)
		var/obj/item/I = new adding_contents(src)
		// recurse here to avoid duplication; could optimize this call out
		return src.add_contents(I)
	if (istype(adding_contents, /datum/robot/module_item_creator))
		// handle adding by definition
		var/datum/robot/module_item_creator/MIC = adding_contents
		var/I = MIC.apply_to_module(src)
		return I
	if (ispath(adding_contents, /datum/robot/module_item_creator))
		// handle adding by definition path (instantiate)
		var/datum/robot/module_item_creator/MIC = new adding_contents
		// recurse here to avoid duplication; could optimize this call out
		return src.add_contents(MIC)
	if (islist(adding_contents))
		// handle adding a batch at once
		var/list/L = adding_contents
		var/list/added = list()
		for (var/member in L)
			var/resolved_member = src.add_contents(member)
			if (!isnull(resolved_member))
				// note this will flatten lists, which is desired behavior here
				added += resolved_member
		return added
