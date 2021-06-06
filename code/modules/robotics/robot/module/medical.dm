/obj/item/robot_module/medical
	name = "medical cyborg module"
	desc = "Incorporates medical tools intended for use to save and preserve human life."
	icon_state = "medical"
	mod_hudicon = "medical"
	included_cosmetic = /datum/robot_cosmetic/medical
	included_tools = /datum/robot/module_tool_creator/recursive/module/medical
	radio_type = /obj/item/device/radio/headset/medical
	mailgroups = list(MGD_MEDBAY, MGD_MEDRESEACH, MGO_SILICON, MGD_PARTY)
	alertgroups = list(MGA_MAIL, MGA_RADIO, MGA_DEATH, MGA_MEDCRIT, MGA_CLONER, MGA_CRISIS, MGA_SALES)

/datum/robot_cosmetic/medical
	head_mod = "Medical Mirror"
	ches_mod = "Medical Insignia"
	fx = list(0, 255, 0)
	painted = 1
	paint = "#969696"
