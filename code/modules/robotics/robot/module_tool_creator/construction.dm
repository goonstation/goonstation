/*
 * - cable coil
 * - glass sheet
 * - iron rod
 * - iron sheet
 * - iron tile
 */

/datum/robot/module_tool_creator/item_type/amount/cable_coil
	name = "cable coil"
	amount = 500
	item_type = /obj/item/cable_coil

/datum/robot/module_tool_creator/item_type/amount/cable_coil/setup(obj/item/cable_coil/I)
	..()
	if (!isnull(I))
		I.updateicon()
	return I

/datum/robot/module_tool_creator/item_type/amount/glass_sheet
	name = "glass sheets"
	amount = 500
	item_type = /obj/item/sheet/glass

/datum/robot/module_tool_creator/item_type/amount/iron_rod
	name = "iron rods"
	amount = 500
	item_type = /obj/item/rods/iron

/datum/robot/module_tool_creator/item_type/amount/iron_rod/setup(obj/item/rods/iron/I)
	..()
	if (!isnull(I))
		I.update_stack_appearance()
	return I

/datum/robot/module_tool_creator/item_type/amount/iron_sheet
	name = "iron sheets"
	amount = 500
	item_type = /obj/item/sheet/iron

/datum/robot/module_tool_creator/item_type/amount/iron_tile
	name = "iron tiles"
	amount = 500
	item_type = /obj/item/tile/iron
