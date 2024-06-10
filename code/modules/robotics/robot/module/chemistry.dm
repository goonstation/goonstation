/obj/item/robot_module/science
	name = "science cyborg module"
	desc = "Beakers, syringes and other tools to enable a cyborg to assist in the science department."
	icon_state = "science"
	mod_hudicon = "science"
	included_cosmetic = /datum/robot_cosmetic/science
	included_tools = /datum/robot/module_tool_creator/recursive/module/science
	radio_type = /obj/item/device/radio/headset/research
	mailgroups = list(MGD_SCIENCE, MGO_SILICON, MGD_PARTY)

/datum/robot_cosmetic/science
	ches_mod = "Lab Coat"
	fx = list(0, 0, 255)
	painted = 1
	paint = "#000064"
