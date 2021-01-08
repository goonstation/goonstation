/obj/item/robot_module/mining
	name = "mining cyborg module"
	desc = "Tools for use in the excavation and transportation of valuable minerals."
	icon_state = "mining"
	mod_hudicon = "mining"
	included_cosmetic = /datum/robot_cosmetic/mining
	included_tools = /datum/robot/module_tool_creator/recursive/module/mining
	radio_type = /obj/item/device/radio/headset/engineer
	mailgroups = list(MGO_MINING, MGO_SILICON, MGD_PARTY)
	alertgroups = list(MGA_MAIL, MGA_RADIO, MGA_SALES, MGA_DEATH)

/datum/robot_cosmetic/mining
	head_mod = "Hard Hat"
	fx = list(0, 255, 255)
	painted = 1
	paint = list(130, 90, 0)
