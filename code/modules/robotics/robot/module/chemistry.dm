/obj/item/robot_module/research
	name = "research cyborg module"
	desc = "Beakers, syringes and other tools to enable a cyborg to assist in the research department."
	icon_state = "chemistry"
	mod_hudicon = "chemistry"
	included_cosmetic = /datum/robot_cosmetic/research
	included_tools = /datum/robot/module_tool_creator/recursive/module/research
	radio_type = /obj/item/device/radio/headset/research
	mailgroups = list(MGD_SCIENCE, MGO_SILICON, MGD_PARTY)

/datum/robot_cosmetic/research
	ches_mod = "Lab Coat"
	fx = list(0, 0, 255)
	painted = 1
	paint = "#000064"
