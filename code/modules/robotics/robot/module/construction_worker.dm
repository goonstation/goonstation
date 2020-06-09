/obj/item/robot_module/construction_worker
	name = "construction worker cyborg module"
	desc = "Everything a construction worker requires."
	icon_state = "construction"
	mod_hudicon = "construction"
	included_cosmetic = /datum/robot_cosmetic/construction
	included_items = /datum/robot/module_item_creator/recursive/module/construction_worker
	radio_type = /obj/item/device/radio/headset/engineer

/datum/robot_cosmetic/construction
	fx = list(0,240,160)
	painted = 1
	paint = list(0,120,80)
