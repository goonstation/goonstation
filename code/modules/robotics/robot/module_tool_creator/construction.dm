/*
 * - cable coil
 * - glass sheet
 * - steel rod
 * - steel sheet
 * - steel tile
 */

/datum/robot/module_tool_creator/item_type/amount/cable_coil
	name = "cable coil"
	amount = 500
	item_type = /obj/item/cable_coil

/datum/robot/module_tool_creator/item_type/amount/cable_coil/setup(obj/item/cable_coil/I)
	..()
	if (!isnull(I))
		I.UpdateIcon()
	return I

/datum/robot/module_tool_creator/item_type/amount/glass_sheet
	name = "glass sheets"
	amount = 500
	item_type = /obj/item/sheet/glass

/datum/robot/module_tool_creator/item_type/amount/steel_rod
	name = "steel rods"
	amount = 500
	item_type = /obj/item/rods/steel

/datum/robot/module_tool_creator/item_type/amount/steel_rod/setup(obj/item/rods/steel/I)
	..()
	if (!isnull(I))
		I.update_stack_appearance()
	return I

/datum/robot/module_tool_creator/item_type/amount/steel_sheet
	name = "steel sheets"
	amount = 500
	item_type = /obj/item/sheet/steel

/datum/robot/module_tool_creator/item_type/amount/steel_tile
	name = "steel tiles"
	amount = 500
	item_type = /obj/item/tile/steel
