/obj/item/robot_module/medical
	name = "medical cyborg module"
	desc = "Incorporates medical tools intended for use to save and preserve human life."
	icon_state = "medical"
	mod_hudicon = "medical"
	included_cosmetic = /datum/robot_cosmetic/medical
	included_items = /datum/robot/module_item_creator/recursive/module/medical
	radio_type = /obj/item/device/radio/headset/medical

/datum/robot_cosmetic/medical
	head_mod = "Medical Mirror"
	ches_mod = "Medical Insignia"
	fx = list(0, 255, 0)
	painted = 1
	paint = list(150, 150, 150)
