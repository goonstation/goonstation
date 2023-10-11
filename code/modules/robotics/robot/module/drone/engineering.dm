/obj/item/robot_module/drone/engineering
	name = "engineering drone module"
	desc = "A module designed to allow for simple maintenance work around station."
	icon_state = "engineering-d"
	mod_hudicon = "engineering-d"
	moduletype = "drone"
	included_tools = /datum/robot/module_tool_creator/recursive/module/engineering_d
	radio_type = /obj/item/device/radio/headset/engineer
	mailgroups = list(MGO_ENGINEER, MGD_STATIONREPAIR, MGD_MINING, MGO_SILICON, MGD_PARTY)
	alertgroups = list(MGA_MAIL, MGA_RADIO, MGA_ENGINE, MGA_CRISIS, MGA_RKIT, MGA_CARGOREQUEST, MGA_DEATH)
