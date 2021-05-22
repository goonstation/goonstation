/*
 * - cable coil
 * - glass sheet
 * - aluminum rod
 * - aluminum sheet
 * - aluminum tile
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

/datum/robot/module_tool_creator/item_type/amount/aluminum_rod
	name = "aluminum rods"
	amount = 500
	item_type = /obj/item/rods/aluminum

/datum/robot/module_tool_creator/item_type/amount/aluminum_rod/setup(obj/item/rods/aluminum/I)
	..()
	if (!isnull(I))
		I.update_stack_appearance()
	return I

/datum/robot/module_tool_creator/item_type/amount/aluminum_sheet
	name = "aluminum sheets"
	amount = 500
	item_type = /obj/item/sheet/aluminum

/datum/robot/module_tool_creator/item_type/amount/aluminum_tile
	name = "aluminum tiles"
	amount = 500
	item_type = /obj/item/tile/aluminum
