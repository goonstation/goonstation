/datum/robot/module_tool_creator/item_type/beaker
	name = "beaker"
	item_type = /obj/item/reagent_containers/glass/beaker

/datum/robot/module_tool_creator/item_type/beaker/setup(obj/item/reagent_containers/glass/beaker/I)
	..()
	I.shatter_immune = TRUE
	return I

/datum/robot/module_tool_creator/item_type/beaker/large
	name = "large beaker"
	item_type = /obj/item/reagent_containers/glass/beaker/large
