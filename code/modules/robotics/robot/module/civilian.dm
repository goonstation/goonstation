/obj/item/robot_module/civilian
	name = "civilian cyborg module"
	desc = "A module suitable for many of the menial tasks covered by the civilian department."
	icon_state = "civilian"
	mod_hudicon = "civilian"
	included_cosmetic = /datum/robot_cosmetic/civilian
	included_tools = /datum/robot/module_tool_creator/recursive/module/civilian
	radio_type = /obj/item/device/radio/headset/civilian
	mail_groups = list(MGT_HYDROPONICS, MGJ_JANITOR, MGT_REPAIR, MGT_SILICON, MSG_PARTY_LINE)

/datum/robot_cosmetic/civilian
	fx = list(255, 0, 0)
	painted = 1
	paint = "#000000"
