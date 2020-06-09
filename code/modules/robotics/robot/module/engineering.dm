/obj/item/robot_module/engineering
	name = "engineering cyborg module"
	desc = "A module designed to allow for station maintenance and repair work."
	icon_state = "engineering"
	mod_hudicon = "engineering"
	included_cosmetic = /datum/robot_cosmetic/engineering
	included_items = /datum/robot/module_item_creator/recursive/module/engineering
	radio_type = /obj/item/device/radio/headset/engineer

/datum/robot_cosmetic/engineering
	fx = list(255, 255, 0)
	painted = 1
	paint = list(130, 150, 0)
