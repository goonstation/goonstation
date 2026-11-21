/datum/robot/module_tool_creator/item_type/beaker
	name = "beaker"
	item_type = /obj/item/reagent_containers/glass/beaker

/datum/robot/module_tool_creator/item_type/beaker/setup(obj/item/reagent_containers/glass/beaker/I, atom/proxy_loc)
	var/obj/item/reagent_containers/glass/beaker/setup_beaker = ..(I, proxy_loc)
	setup_beaker.shatter_immune = TRUE
	return setup_beaker

/datum/robot/module_tool_creator/item_type/beaker/large
	name = "large beaker"
	item_type = /obj/item/reagent_containers/glass/beaker/large
