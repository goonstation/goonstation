/obj/item/robot_module/engineering
	name = "engineering cyborg module"
	desc = "A module designed to allow for station maintenance and repair work."
	icon_state = "engineering"
	mod_hudicon = "engineering"
	included_cosmetic = /datum/robot_cosmetic/engineering
	included_tools = /datum/robot/module_tool_creator/recursive/module/engineering
	radio_type = /obj/item/device/radio/headset/engineer
	mail_groups = list(MGD_ENGINEERING, MGT_REPAIR, MGT_SILICON, MSG_PARTY_LINE)
	mail_topics = list(MSG_TOPIC_DELIVERY, MSG_TOPIC_RADIO, MSG_TOPIC_ENGINE, MSG_TOPIC_CRISIS, MSG_TOPIC_RKIT)

/datum/robot_cosmetic/engineering
	fx = list(255, 255, 0)
	painted = 1
	paint = "#829600"
