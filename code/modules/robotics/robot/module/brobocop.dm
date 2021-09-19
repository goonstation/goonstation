/obj/item/robot_module/brobocop
	name = "brobocop cyborg module"
	desc = "Become the life of the party, and also the scourge of fun."
	icon_state = "brobocop"
	mod_hudicon = "brobocop"
	included_cosmetic = /datum/robot_cosmetic/brobocop
	included_tools = /datum/robot/module_tool_creator/recursive/module/brobocop
	radio_type = /obj/item/device/radio/headset/security
	mailgroups = list(MGD_SECURITY, MGD_KITCHEN, MGO_SILICON, MGD_PARTY)
	alertgroups = list(MGA_MAIL, MGA_RADIO, MGA_CHECKPOINT, MGA_ARREST, MGA_DEATH, MGA_MEDCRIT, MGA_CRISIS)

/datum/robot_cosmetic/brobocop
	head_mod = "Afro and Shades"
	fx = list(90, 0, 90)
	painted = 0
