ADMIN_INTERACT_PROCS(/obj/item/robot_module, proc/admin_add_tool, proc/admin_remove_tool)

/// Job/tool modules for cyborgs
/obj/item/robot_module
	name = "blank cyborg module"
	desc = "A blank cyborg module. It has minimal function in its current state."
	icon = 'icons/obj/items/cyborg_parts/modules.dmi'
	icon_state = "blank"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "electronic"
	w_class = W_CLASS_SMALL
	flags = TABLEPASS | CONDUCT
	var/list/tools = list()
	var/mod_hudicon = "unknown"
	var/cosmetic_mods = null
	var/included_tools = /datum/robot/module_tool_creator/recursive/module/common
	var/included_cosmetic = null
	var/radio_type = null
	var/obj/item/device/radio/headset/radio = null
	var/list/mailgroups = list(MGO_SILICON, MGD_PARTY)
	var/list/alertgroups = list(MGA_MAIL, MGA_RADIO, MGA_DEATH)

/obj/item/robot_module/New()
	..()
	src.add_contents(src.included_tools)
	// no need to keep the definition past initializing
	src.included_tools = null

	if (ispath(src.included_cosmetic, /datum/robot_cosmetic))
		src.cosmetic_mods = new included_cosmetic(src)

	if (src.radio_type != null)
		src.radio = new src.radio_type(src)

// handle various ways of adding tools to the module
/obj/item/robot_module/proc/add_contents(adding_contents)
	if (isnull(adding_contents))
		return
	if (istype(adding_contents, /obj/item))
		// handle adding single instance of tool
		var/obj/item/I = adding_contents
		I.cant_drop = TRUE
		I.set_loc(src)
		src.tools += I
		return I
	if (ispath(adding_contents, /obj/item))
		// handle adding tool by path (instantiate)
		var/obj/item/I = new adding_contents(src)
		// recurse here to avoid duplication; could optimize this call out
		return src.add_contents(I)
	if (istype(adding_contents, /datum/robot/module_tool_creator))
		// handle adding by definition
		var/datum/robot/module_tool_creator/MTC = adding_contents
		var/I = MTC.apply_to_module(src)
		return I
	if (ispath(adding_contents, /datum/robot/module_tool_creator))
		// handle adding by definition path (instantiate)
		var/datum/robot/module_tool_creator/MTC = new adding_contents
		// recurse here to avoid duplication; could optimize this call out
		return src.add_contents(MTC)
	if (islist(adding_contents))
		// handle adding a batch at once
		var/list/L = adding_contents
		var/list/added = list()
		for (var/member in L)
			var/resolved_member = src.add_contents(member)
			if (!isnull(resolved_member))
				// N.B. this will flatten lists, which is desired behavior here
				added += resolved_member
		return added

/// Admin interact menu for adding tools to the module
/obj/item/robot_module/proc/admin_add_tool()
	set name = "Add Tool"
	var/type = get_one_match(tgui_input_text(usr, "Item type", "Item type"), /obj/item)
	if (!type)
		return
	var/obj/item/I = new type(src)
	src.add_contents(I)
	boutput(usr, "Added [I] to [src].")

/// Admin interact menu for removing tools from the module
/obj/item/robot_module/proc/admin_remove_tool()
	set name = "Remove Tool"
	var/obj/item/I = tgui_input_list(usr, "Tool to remove", "Tool to remove", src.tools)
	if (!I)
		return
	src.tools -= I
	qdel(I)
	boutput(usr, "Removed [I] from [src].")
