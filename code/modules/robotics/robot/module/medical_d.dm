/obj/item/robot_module/medical_d
	name = "medsci drone module"
	desc = "Incorporates basic medical supplies alongside the bare essentials for research work."
	icon_state = "medical-d"
	mod_hudicon = "medical-d"
	moduletype = "drone"
	included_tools = /datum/robot/module_tool_creator/recursive/module/medical_d
	radio_type = /obj/item/device/radio/headset/medsci
	mailgroups = list(MGD_SCIENCE, MGD_MEDBAY, MGD_MEDRESEACH, MGO_SILICON, MGD_PARTY)
	alertgroups = list(MGA_MAIL, MGA_RADIO, MGA_DEATH, MGA_MEDCRIT, MGA_CLONER, MGA_CRISIS, MGA_SALES)
