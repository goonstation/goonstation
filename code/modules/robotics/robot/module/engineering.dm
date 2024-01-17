/obj/item/robot_module/engineering
	name = "engineering cyborg module"
	desc = "A module designed to allow for station maintenance and repair work."
	icon_state = "engineering"
	mod_hudicon = "engineering"
	included_cosmetic = /datum/robot_cosmetic/engineering
	included_tools = /datum/robot/module_tool_creator/recursive/module/engineering
	radio_type = /obj/item/device/radio/headset/engineer
	mailgroups = list(MGO_ENGINEER, MGD_STATIONREPAIR, MGO_SILICON, MGD_PARTY)
	alertgroups = list(MGA_MAIL, MGA_RADIO, MGA_ENGINE, MGA_CRISIS, MGA_RKIT)

/datum/robot_cosmetic/engineering
	fx = list(255, 255, 0)
	painted = 1
	paint = "#829600"
